import 'media_item.dart';

// Enlace interno al mismo host con vista previa: no es descargable,
// al abrirlo se escanea su contenido
class SubpageLink {
  final String title;
  final String url;
  final String? previewUrl;

  const SubpageLink({
    required this.title,
    required this.url,
    this.previewUrl,
  });
}

// Resultado completo de un escaneo: archivos + enlaces internos
class ScanResult {
  final List<MediaItem> items;
  final List<SubpageLink> subpages;

  const ScanResult({this.items = const [], this.subpages = const []});
}
