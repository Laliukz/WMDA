import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/media_item.dart';
import 'history_provider.dart';
import 'repository_providers.dart';

class DownloadState {
  final Map<String, double> progressMap;
  final Set<String> downloadingIds;
  final Map<String, MediaItem> downloadingItems;
  final Map<String, String> errorMap;

  const DownloadState({
    this.progressMap = const {},
    this.downloadingIds = const {},
    this.downloadingItems = const {},
    this.errorMap = const {},
  });

  DownloadState copyWith({
    Map<String, double>? progressMap,
    Set<String>? downloadingIds,
    Map<String, MediaItem>? downloadingItems,
    Map<String, String>? errorMap,
  }) {
    return DownloadState(
      progressMap: progressMap ?? this.progressMap,
      downloadingIds: downloadingIds ?? this.downloadingIds,
      downloadingItems: downloadingItems ?? this.downloadingItems,
      errorMap: errorMap ?? this.errorMap,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  final Ref _ref;

  DownloadNotifier(this._ref) : super(const DownloadState());

  Future<void> download(MediaItem item) async {
    // Registra el item como activo y progreso en 0
    state = state.copyWith(
      downloadingIds: {...state.downloadingIds, item.id},
      downloadingItems: {...state.downloadingItems, item.id: item},
      progressMap: {...state.progressMap, item.id: 0.0},
    );

    try {
      final downloadUseCase = _ref.read(downloadMediaUseCaseProvider);

      await downloadUseCase(
        item,
        onProgress: (progress) {
          state = state.copyWith(
            progressMap: {...state.progressMap, item.id: progress},
          );
        },
      );

      // Al terminar con éxito, se retira de descargas activas
      final updatedDownloading = Set<String>.from(state.downloadingIds)
        ..remove(item.id);
      final updatedItems = Map<String, MediaItem>.from(state.downloadingItems)
        ..remove(item.id);
      final updatedProgress = Map<String, double>.from(state.progressMap)
        ..remove(item.id);

      state = state.copyWith(
        downloadingIds: updatedDownloading,
        downloadingItems: updatedItems,
        progressMap: updatedProgress,
      );

      // Refresca el historial automáticamente
      _ref.read(historyProvider.notifier).loadHistory();
    } catch (e) {
      final updatedDownloading = Set<String>.from(state.downloadingIds)
        ..remove(item.id);
      final updatedItems = Map<String, MediaItem>.from(state.downloadingItems)
        ..remove(item.id);
      final updatedProgress = Map<String, double>.from(state.progressMap)
        ..remove(item.id);

      if (e is CancelledFailure) {
        state = state.copyWith(
          downloadingIds: updatedDownloading,
          downloadingItems: updatedItems,
          progressMap: updatedProgress,
        );
      } else {
        debugPrint('Error en descarga: $e');
        state = state.copyWith(
          downloadingIds: updatedDownloading,
          downloadingItems: updatedItems,
          progressMap: updatedProgress,
          errorMap: {...state.errorMap, item.id: e.toString()},
        );
      }
    }
  }

  void cancel(String id) {
    _ref.read(downloadMediaUseCaseProvider).cancel(id);
    final updatedDownloading = Set<String>.from(state.downloadingIds)
      ..remove(id);
    final updatedItems = Map<String, MediaItem>.from(state.downloadingItems)
      ..remove(id);
    final updatedProgress = Map<String, double>.from(state.progressMap)
      ..remove(id);
    final updatedErrors = Map<String, String>.from(state.errorMap)
      ..remove(id);

    state = state.copyWith(
      downloadingIds: updatedDownloading,
      downloadingItems: updatedItems,
      progressMap: updatedProgress,
      errorMap: updatedErrors,
    );
  }

  void cancelAll() {
    _ref.read(downloadMediaUseCaseProvider).cancelAll();
    state = state.copyWith(
      downloadingIds: {},
      downloadingItems: {},
      progressMap: {},
    );
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>(
  (ref) => DownloadNotifier(ref),
);
