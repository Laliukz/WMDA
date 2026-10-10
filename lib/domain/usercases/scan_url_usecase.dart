import '../entities/scan_result.dart';
import '../repositories/media_repository.dart';

class ScanUrlUsecase {
  final MediaRepository _repository;

  ScanUrlUsecase(this._repository);

  Future<ScanResult> call(String url) async {
    return await _repository.scanURL(url);
  }
}
