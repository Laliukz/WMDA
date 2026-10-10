import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/media_item.dart';
import 'repository_providers.dart';

class HistoryNotifier extends StateNotifier<AsyncValue<List<MediaItem>>> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    // ponytail: solo spinner inicial; refrescos conservan datos visibles
    if (state.valueOrNull == null && state is! AsyncError) {
      state = const AsyncValue.loading();
    }
    try {
      final getHistory = _ref.read(getHistoryUseCaseProvider);
      final items = await getHistory();
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final deleteHistory = _ref.read(deleteHistoryUseCaseProvider);
      await deleteHistory(id);
      await loadHistory();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, AsyncValue<List<MediaItem>>>((ref) {
      return HistoryNotifier(ref);
    });
