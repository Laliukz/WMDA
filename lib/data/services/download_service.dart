import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/media_item.dart';
import '../../core/utils/permission_helper.dart';

class DownloadService {
  final http.Client _client;

  DownloadService({http.Client? client}) : _client = client ?? http.Client();

  // Descarga el medio y devuelve la ruta del archivo
  Future<String> downloadFile(
    MediaItem item, {
    void Function(double progress)? onProgress,
  }) async {
    //verificar permisos
    final hasPermission = await PermissionHelper.requestStoragePermission();
    if (!hasPermission) {
      throw const StorageFailure('Permiso de almacenamiento denegado.');
    }
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

      return file.path;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error al guardar el archivo: $e');
    }
  }

  Future<Directory> _getStorageDirectory() async {
    if (Platform.isAndroid) {
      //ruta descargas
      final publicDownloadDir = Directory('/storage/emulated/0/Download/MWDA');
      if (!await publicDownloadDir.exists()) {
        await publicDownloadDir.create(recursive: true);
      }
      return publicDownloadDir;
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
