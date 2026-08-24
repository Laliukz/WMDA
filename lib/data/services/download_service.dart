import 'dart:async';
import 'dart:io';

import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/media_item.dart';

class DownloadService {
  final http.Client _client;
  final Map<String, void Function()> _cancelTokens = {};

  DownloadService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders(Uri uri, MediaType type) {
    return {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9,es;q=0.8',
      'Referer': '${uri.scheme}://${uri.host}/',
      'Origin': '${uri.scheme}://${uri.host}',
      'Sec-Fetch-Dest': type == MediaType.video ? 'video' : 'image',
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

    void cancelCallback() {
      isCancelled = true;
      subscription?.cancel();
      try {
        sink?.close();
      } catch (_) {}
      if (file != null && file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
    }

    _cancelTokens[item.id] = cancelCallback;

    try {
      final uri = Uri.parse(item.url);
      http.StreamedResponse? response;

      // Intentos con diferentes combinaciones de cabeceras para sortear bloqueos 403 / anti-hotlink
      final headerAttempts = [
        _buildHeaders(uri, item.type),
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
        final res = await _client.send(request);
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
      final fileName =
          '${_sanitizeFileName(item.title ?? 'media_${item.id.hashCode}')}.$extension';

      final filePath = '${directory.path}/$fileName';
      file = File(filePath);
      sink = file.openWrite();

      subscription = response.stream.listen((chunk) {
        if (isCancelled) return;
        sink?.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress(receivedBytes / totalBytes);
        }
      });

      await subscription.asFuture();

      if (isCancelled) {
        throw const CancelledFailure();
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
            await Gal.putVideo(filePath, album: 'WMDA');
          } else {
            await Gal.putImage(filePath, album: 'WMDA');
          }
        }
      } catch (_) {}

      return file.path;
    } catch (e) {
      if (isCancelled || e is CancelledFailure) {
        if (file != null && file.existsSync()) {
          try {
            file.deleteSync();
          } catch (_) {}
        }
        throw const CancelledFailure();
      }
      if (e is Failure) rethrow;
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
    //quitqamos caracteres no validos
    return name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }
}
