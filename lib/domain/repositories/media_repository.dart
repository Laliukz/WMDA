import '../entities/media_item.dart';
import '../entities/scan_result.dart';

abstract class MediaRepository {
  //escanea la URL y devuelve archivos + enlaces internos
  Future<ScanResult> scanURL(String url);

  //descarga el archivo
  //[onProgress] //barra de progreso

  Future<MediaItem> downloadMedia(
    MediaItem item, {
    void Function(double progress)? onProgress,
  });

  //Historial de descargas
  Future<List<MediaItem>> getDownloadHistory();
  //Eliminar elemento del historial
  Future<void> deleteFromHistory(String id);

  // Cancelar descargas
  void cancelDownload(String id);
  void cancelAllDownloads();
}
