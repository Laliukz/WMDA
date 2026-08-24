import 'dart:io';

import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/media_item.dart';

class DownloadService {
  final http.Client _client;

  DownloadService({http.Client? client}) : _client = client ?? http.Client();

  // Descarga el medio y devuelve la ruta del archivo
  Future<String> downloadFile(
    MediaItem item, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(item.url));
      final response = await _client.send(request);

      if (response.statusCode != 200) {
        throw ServerFailure('Error HTTP ${response.statusCode} al descargar');
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
      final file = File(filePath);
      final sink = file.openWrite();

      await response.stream.listen((chunk) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress(receivedBytes / totalBytes);
        }
      }).asFuture();

      await sink.flush();
      await sink.close();

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
      if (e is Failure) rethrow;
      throw ServerFailure('Error al guardar el archivo: $e');
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
