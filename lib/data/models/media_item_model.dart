import '../../domain/entities/media_item.dart';

class MediaItemModel extends MediaItem {
  const MediaItemModel({
    required super.id,
    required super.url,
    super.previewUrl,
    super.title,
    required super.type,
    super.extension,
    super.localPath,
    super.downloadedAt,
    super.isDownloaded,
    super.referer,
  });

  //modelo a partir de una entidad de dominio
  factory MediaItemModel.fromEntity(MediaItem entity) {
    return MediaItemModel(
      id: entity.id,
      url: entity.url,
      previewUrl: entity.previewUrl,
      title: entity.title,
      type: entity.type,
      extension: entity.extension,
      localPath: entity.localPath,
      downloadedAt: entity.downloadedAt,
      isDownloaded: entity.isDownloaded,
      referer: entity.referer,
    );
  }

  //convertir un JSON a MediaItemModel
  factory MediaItemModel.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String? ?? '';
    final url = map['url'] as String? ?? '';
    if (id.isEmpty || url.isEmpty) throw const FormatException('Media corrupto');
    return MediaItemModel(
      id: id,
      url: url,
      previewUrl: map['previewUrl'] as String?,
      title: map['title'] as String?,
      type: MediaType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MediaType.image,
      ),
      extension: map['extension'] as String?,
      localPath: map['localPath'] as String?,
      downloadedAt: map['downloadedAt'] != null
          ? DateTime.tryParse(map['downloadedAt'] as String)
          : null,
      isDownloaded: map['isDownloaded'] as bool? ?? false,
      referer: map['referer'] as String?,
    );
  }
  //convierte el modelo a un JSON para guardarlo local
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'previewUrl': previewUrl,
      'title': title,
      'type': type.name,
      'extension': extension,
      'localPath': localPath,
      'downloadedAt': downloadedAt?.toIso8601String(),
      'isDownloaded': isDownloaded,
      'referer': referer,
    };
  }
}
