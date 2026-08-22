import '../entities/media_item.dart';
import '../repositories/media_repository.dart';

class GetHistoryUseCase {
  final MediaRepository _repository;

  GetHistoryUseCase(this._repository);

  Future<List<MediaItem>> call() async {
    return await _repository.getDownloadHistory();
  }
}
