import '../repositories/media_repository.dart';

class DeleteHistoryUseCase {
  final MediaRepository _repository;

  DeleteHistoryUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteFromHistory(id);
  }
}
