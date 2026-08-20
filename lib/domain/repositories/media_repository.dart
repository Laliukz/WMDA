import '../entities/media_item.dart';

abstract class MediaRepository {
  //escanea la URL y devuelve los archivos encontrados
  Future<List<MediaItem>> scanURL(String url);

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
}
