import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/media_item.dart';

class DownloadService {
  final http.Client _client;
  final Map<String, void Function()> _cancelTokens = {};

  DownloadService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders(MediaItem item, Uri uri) {
    // ponytail: varios CDNs devuelven 404 si el Referer no es la URL
    // de origen; sin referer conocido se usa el host del archivo
    final page =
        (item.referer != null && item.referer!.isNotEmpty)
            ? Uri.parse(item.referer!)
            : Uri.parse('${uri.scheme}://${uri.host}/');
    return {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9,es;q=0.8',
      'Referer': page.toString(),
      'Origin': '${page.scheme}://${page.host}',
      'Sec-Fetch-Dest': item.type == MediaType.video ? 'video' : 'image',
      'Sec-Fetch-Mode': 'no-cors',
      'Sec-Fetch-Site': 'cross-site',
    };
  }

  // Descarga el medio y devuelve la ruta del archivo
  Future<String> downloadFile(
    MediaItem item, {
    void Function(double progress)? onProgress,
  }) async {
    File? file;
    IOSink? sink;
    StreamSubscription<List<int>>? subscription;
    bool isCancelled = false;
    // ponytail: asFuture() no siempre completa tras cancel(); Completer propio sí
    final done = Completer<void>();

    void cancelCallback() {
      isCancelled = true;
      subscription?.cancel();
      if (!done.isCompleted) done.complete();
      // ponytail: close best-effort; borrado real ocurre en catch tras close
      try {
        sink?.close();
      } catch (_) {}
    }

    _cancelTokens[item.id] = cancelCallback;

    try {
      final uri = Uri.parse(item.url);
      http.StreamedResponse? response;

      // Intentos con diferentes combinaciones de cabeceras para sortear bloqueos 403 / anti-hotlink
      final headerAttempts = [
        _buildHeaders(item, uri),
        {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
          'Accept': '*/*',
        },
        <String, String>{},
      ];

      for (final headers in headerAttempts) {
        if (isCancelled) throw const CancelledFailure();
        final request = http.Request('GET', uri);
        if (headers.isNotEmpty) {
          request.headers.addAll(headers);
        }
        final res = await _client
            .send(request)
            .timeout(const Duration(seconds: 30));
        if (res.statusCode >= 200 && res.statusCode < 300) {
          response = res;
          break;
        } else if (res.statusCode != 403 && res.statusCode != 401) {
          response = res;
          break;
        }
      }

      if (isCancelled) {
        throw const CancelledFailure();
      }

      if (response == null ||
          response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw ServerFailure(
          'Error HTTP ${response?.statusCode ?? 403} al descargar',
        );
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      //obtener el directorio para almacenar el archivo
      final directory = await _getStorageDirectory();
      final extension =
          item.extension ?? (item.type == MediaType.video ? 'mp4' : 'jpg');
      final baseName = _sanitizeFileName(
        item.title ?? 'media_${item.id.hashCode}',
      );

      final savedFile = _uniqueFile(directory, baseName, extension);
      file = savedFile;
      sink = savedFile.openWrite();

      subscription = response.stream.listen(
        (chunk) {
          if (isCancelled) return;
          sink?.add(chunk);
          receivedBytes += chunk.length;
          // Sin content-length el progreso es indeterminado (-1): la UI
          // muestra barra animada en vez de un 0% congelado
          if (onProgress != null) {
            onProgress(totalBytes > 0 ? receivedBytes / totalBytes : -1);
          }
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
        onError: (Object e, StackTrace st) {
          if (!done.isCompleted) done.completeError(e, st);
        },
        cancelOnError: true,
      );

      await done.future;

      if (isCancelled) {
        throw const CancelledFailure();
      }

      // El stream puede cerrar sin error con bytes faltantes: eso es
      // descarga corrupta, no éxito
      if (totalBytes > 0 && receivedBytes < totalBytes) {
        throw const ServerFailure('Descarga incompleta del archivo');
      }

      await sink.flush();
      await sink.close();
      sink = null;

      // Copia a la galería vía MediaStore (única vía en Android 11+).
      // ponytail: si falla, el archivo queda en el dir de la app; para URI
      // exacta del MediaStore haría falta media_store_plus.
      try {
        if (await Gal.requestAccess()) {
          if (item.type == MediaType.video) {
            await Gal.putVideo(savedFile.path, album: 'WMDA');
          } else {
            await Gal.putImage(savedFile.path, album: 'WMDA');
          }
        } else {
          debugPrint(
            'WMDA: sin acceso a galería, archivo solo en ${savedFile.path}',
          );
        }
      } catch (e) {
        debugPrint('WMDA: fallo al copiar a galería: $e');
      }

      return savedFile.path;
    } catch (e) {
      if (isCancelled || e is CancelledFailure) {
        // Cierra sink antes de borrar (deleteSync con handle abierto falla en Windows)
        try {
          await sink?.close();
        } catch (_) {}
        sink = null;
        final partial = file;
        file = null;
        if (partial != null && partial.existsSync()) {
          try {
            await partial.delete();
          } catch (deleteError) {
            debugPrint('WMDA: fallo al borrar archivo parcial: $deleteError');
          }
        }
        throw const CancelledFailure();
      }
      if (e is TimeoutException) {
        throw const ServerFailure('Tiempo de espera agotado en descarga');
      }
      if (e is Failure) {
        try {
          await sink?.close();
        } catch (_) {}
        rethrow;
      }
      throw ServerFailure('Error al guardar el archivo: $e');
    } finally {
      _cancelTokens.remove(item.id);
    }
  }

  void cancelDownload(String id) {
    _cancelTokens[id]?.call();
    _cancelTokens.remove(id);
  }

  void cancelAll() {
    final tokens = List<void Function()>.from(_cancelTokens.values);
    _cancelTokens.clear();
    for (final cancel in tokens) {
      cancel();
    }
  }

  Future<Directory> _getStorageDirectory() async {
    if (Platform.isAndroid) {
      // Directorio externo de la app: escribible sin permisos en cualquier API
      final externalDirs = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (externalDirs != null && externalDirs.isNotEmpty) {
        return externalDirs.first;
      }
    }
    return await getApplicationDocumentsDirectory();
  }

  String _sanitizeFileName(String name) {
    //quitamos caracteres no validos
    var clean = name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    if (clean.isEmpty) clean = 'media';
    // ponytail: tope 100 chars, FS falla en 255
    if (clean.length > 100) clean = clean.substring(0, 100);
    return clean;
  }

  // Nombre único: evita sobrescribir si dos títulos colisionan
  File _uniqueFile(Directory dir, String base, String ext) {
    var candidate = File('${dir.path}/$base.$ext');
    var i = 1;
    while (candidate.existsSync()) {
      candidate = File('${dir.path}/${base}_$i.$ext');
      if (++i > 1000) break;
    }
    return candidate;
  }
}
