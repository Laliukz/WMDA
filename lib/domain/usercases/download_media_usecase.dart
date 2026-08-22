import '../entities/media_item.dart';
import '../repositories/media_repository.dart';

class DownloadMediaUsecase {
  final MediaRepository _repository;

  DownloadMediaUsecase(this._repository);

  Future<MediaItem> call(
    MediaItem item, {
    void Function(double progress)? onProgress,
  }) async {
    return await _repository.downloadMedia(item, onProgress: onProgress);
  }
}
