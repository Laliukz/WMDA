import '../entities/media_item.dart';
import '../repositories/media_repository.dart';

class ScanUrlUsecase {
  final MediaRepository _repository;

  ScanUrlUsecase(this._repository);

  Future<List<MediaItem>> call(String url) async {
    return await _repository.scanURL(url);
  }
}
