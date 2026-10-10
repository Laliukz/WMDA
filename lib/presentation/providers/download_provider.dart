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
  final Map<String, MediaItem> failedItems;

  const DownloadState({
    this.progressMap = const {},
    this.downloadingIds = const {},
    this.downloadingItems = const {},
    this.errorMap = const {},
    this.failedItems = const {},
  });

  DownloadState copyWith({
    Map<String, double>? progressMap,
    Set<String>? downloadingIds,
    Map<String, MediaItem>? downloadingItems,
    Map<String, String>? errorMap,
    Map<String, MediaItem>? failedItems,
  }) {
    return DownloadState(
      progressMap: progressMap ?? this.progressMap,
      downloadingIds: downloadingIds ?? this.downloadingIds,
      downloadingItems: downloadingItems ?? this.downloadingItems,
      errorMap: errorMap ?? this.errorMap,
      failedItems: failedItems ?? this.failedItems,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  final Ref _ref;

  DownloadNotifier(this._ref) : super(const DownloadState());

  /// Saca el item de las descargas activas (ids, items y progreso).
  /// También limpia su error previo: un reintento exitoso no debe
  /// conservar el error anterior.
  void _removeActive(String id) {
    state = state.copyWith(
      downloadingIds: Set<String>.from(state.downloadingIds)..remove(id),
      downloadingItems:
          Map<String, MediaItem>.from(state.downloadingItems)..remove(id),
      progressMap: Map<String, double>.from(state.progressMap)..remove(id),
      errorMap: Map<String, String>.from(state.errorMap)..remove(id),
      failedItems: Map<String, MediaItem>.from(state.failedItems)..remove(id),
    );
  }

  Future<void> download(MediaItem item) async {
    // Registra el item como activo y progreso en 0 (limpia error previo)
    state = state.copyWith(
      downloadingIds: {...state.downloadingIds, item.id},
      downloadingItems: {...state.downloadingItems, item.id: item},
      progressMap: {...state.progressMap, item.id: 0.0},
      errorMap: Map<String, String>.from(state.errorMap)..remove(item.id),
      failedItems: Map<String, MediaItem>.from(state.failedItems)
        ..remove(item.id),
    );

    try {
      final downloadUseCase = _ref.read(downloadMediaUseCaseProvider);

      await downloadUseCase(
        item,
        onProgress: (progress) {
          // ponytail: throttle, rebuild solo si avanza ≥1% o termina;
          // -1 = indeterminado (sin content-length), se queda en 0.0
          final p = progress < 0 ? 0.0 : progress.clamp(0.0, 1.0);
          final current = state.progressMap[item.id] ?? 0.0;
          if (p >= 1.0 || p - current >= 0.01) {
            state = state.copyWith(
              progressMap: {...state.progressMap, item.id: p},
            );
          }
        },
      );

      // Al terminar con éxito, se retira de descargas activas
      _removeActive(item.id);

      // Refresca el historial automáticamente
      _ref.read(historyProvider.notifier).loadHistory();
    } catch (e) {
      if (e is CancelledFailure) {
        // Cancelada: sin error visible
        _removeActive(item.id);
      } else {
        debugPrint('Error en descarga: $e');
        // Fallida: sale de activas pero queda visible con reintento
        state = state.copyWith(
          downloadingIds: Set<String>.from(state.downloadingIds)
            ..remove(item.id),
          downloadingItems:
              Map<String, MediaItem>.from(state.downloadingItems)
                ..remove(item.id),
          progressMap: Map<String, double>.from(state.progressMap)
            ..remove(item.id),
          errorMap: {...state.errorMap, item.id: e.toString()},
          failedItems: {...state.failedItems, item.id: item},
        );
      }
    }
  }

  void clearError(String id) {
    state = state.copyWith(
      errorMap: Map<String, String>.from(state.errorMap)..remove(id),
      failedItems: Map<String, MediaItem>.from(state.failedItems)..remove(id),
    );
  }

  void cancel(String id) {
    _ref.read(downloadMediaUseCaseProvider).cancel(id);
    _removeActive(id);
    state = state.copyWith(
      errorMap: Map<String, String>.from(state.errorMap)..remove(id),
    );
  }

  void cancelAll() {
    _ref.read(downloadMediaUseCaseProvider).cancelAll();
    state = state.copyWith(
      downloadingIds: {},
      downloadingItems: {},
      progressMap: {},
      errorMap: {},
      failedItems: {},
    );
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>(
  (ref) => DownloadNotifier(ref),
);
