import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/media_item.dart';
import 'history_provider.dart';
import 'repository_providers.dart';

class DownloadState {
  //progreso del 0 a 100
  final Map<String, double> progressMap;
  //id del elemento
  final Set<String> downloadingIds;

  final Map<String, String> errorMap;

  const DownloadState({
    this.progressMap = const {},
    this.downloadingIds = const {},
    this.errorMap = const {},
  });

  DownloadState copyWith({
    Map<String, double>? progressMap,
    Set<String>? downloadingIds,
    Map<String, String>? errorMap,
  }) {
    return DownloadState(
      progressMap: progressMap ?? this.progressMap,
      downloadingIds: downloadingIds ?? this.downloadingIds,
      errorMap: errorMap ?? this.errorMap,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  final Ref _ref;

  DownloadNotifier(this._ref) : super(const DownloadState());

  Future<void> download(MediaItem item) async {
    //marca como descargado
    state = state.copyWith(
      downloadingIds: {...state.downloadingIds, item.id},
      progressMap: {...state.progressMap, item.id: 0.0},
    );
    try {
      final downloadUseCase = _ref.read(downloadMediaUseCaseProvider);

      await downloadUseCase(
        item,
        onProgress: (progress) {
          //actualiza el progreso del archivo
          state = state.copyWith(
            progressMap: {...state.progressMap, item.id: progress},
          );
        },
      );

      //si descarga correctamente removemos de descargando
      final updatedDownloading = Set<String>.from(state.downloadingIds)
        ..remove(item.id);
      state = state.copyWith(downloadingIds: updatedDownloading);
      //refrescamos historial automaticamente
      _ref.read(historyProvider.notifier).loadHistory();
    } catch (e) {
      final updatedDownloading = Set<String>.from(state.downloadingIds)
        ..remove(item.id);
      state = state.copyWith(
        downloadingIds: updatedDownloading,
        errorMap: {...state.errorMap, item.id: e.toString()},
      );
    }
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>(
  (ref) {
    return DownloadNotifier(ref);
  },
);
