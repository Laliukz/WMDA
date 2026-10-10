enum MediaType { image, video }

class MediaItem {
  final String id;
  final String url;
  final String? previewUrl;
  final String? title;
  final MediaType type;
  final String? extension;
  final String? localPath;
  final DateTime? downloadedAt;
  final bool isDownloaded;
  // URL de origen del escaneo: varios CDNs exigen ese Referer al descargar
  final String? referer;

  const MediaItem({
    required this.id,
    required this.url,
    this.previewUrl,
    this.title,
    required this.type,
    this.extension,
    this.localPath,
    this.downloadedAt,
    this.isDownloaded = false,
    this.referer,
  });
  MediaItem copyWith({
    String? id,
    String? url,
    String? previewUrl,
    String? title,
    MediaType? type,
    String? extension,
    String? localPath,
    DateTime? downloadedAt,
    bool? isDownloaded,
    String? referer,
  }) {
    return MediaItem(
      id: id ?? this.id,
      url: url ?? this.url,
      previewUrl: previewUrl ?? this.previewUrl,
      title: title ?? this.title,
      type: type ?? this.type,
      extension: extension ?? this.extension,
      localPath: localPath ?? this.localPath,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      referer: referer ?? this.referer,
    );
  }
}
