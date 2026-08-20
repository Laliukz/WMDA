class UrlHelper {
  //asegura que la url tenga el protocolo http o https
  static String format(String url) {
    var trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }

  //resuelve la url relativa o absoluta usando la base del sitio
  static String? resolve(Uri baseUri, String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('data:')) return null; //ignora data Uri

    final resolved = baseUri.resolve(trimmed);
    return resolved.hasScheme ? resolved.toString() : null;
  }

  //Obtenemos la extencion del archivo
  static String? getExtension(String path) {
    final lasDot = path.lastIndexOf('.');
    if (lasDot != -1 && lasDot < path.length - 1) {
      final ext = path.substring(lasDot + 1).toLowerCase();
      if (ext.length <= 5 && RegExp(r'^[a-z0-9]+$').hasMatch(ext)) {
        return ext;
      }
    }
    return null;
  }
}
