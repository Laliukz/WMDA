import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/media_repository_impl.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/usercases/delete_history_usecase.dart';
import '../../domain/usercases/download_media_usecase.dart';
import '../../domain/usercases/get_history_usecase.dart';
import '../../domain/usercases/scan_url_usecase.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepositoryImpl();
});

final scanUrlUseCaseProvider = Provider<ScanUrlUsecase>((ref) {
  return ScanUrlUsecase(ref.watch(mediaRepositoryProvider));
});

final downloadMediaUseCaseProvider = Provider<DownloadMediaUsecase>((ref) {
  return DownloadMediaUsecase(ref.watch(mediaRepositoryProvider));
});

final getHistoryUseCaseProvider = Provider<GetHistoryUseCase>((ref) {
  return GetHistoryUseCase(ref.watch(mediaRepositoryProvider));
});

final deleteHistoryUseCaseProvider = Provider<DeleteHistoryUseCase>((ref) {
  return DeleteHistoryUseCase(ref.watch(mediaRepositoryProvider));
});
