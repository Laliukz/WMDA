class UrlHelper {
  //asegura que la url tenga el protocolo http o https
  static String format(String url) {
    var trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }

  //resuelve la url relativa o absoluta usando la URL base
  static String? resolve(Uri baseUri, String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('data:')) return null; //ignora data Uri

    final resolved = baseUri.resolve(trimmed);
    return resolved.hasScheme ? resolved.toString() : null;
  }

  //Obtenemos la extencion del archivo
  static String? getExtension(String path) {
    // URLs tipo .../video_preview.mp4/ (barra final) también valen
    final clean = path.replaceAll(RegExp(r'/+$'), '');
    final lastDot = clean.lastIndexOf('.');
    if (lastDot != -1 && lastDot < clean.length - 1) {
      final ext = clean.substring(lastDot + 1).toLowerCase();
      if (ext.length <= 5 && RegExp(r'^[a-z0-9]+$').hasMatch(ext)) {
        return ext;
      }
    }
    return null;
  }
}
