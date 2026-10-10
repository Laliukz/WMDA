import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/media_item.dart';

class SelectedMediaNotifier extends StateNotifier<List<MediaItem>> {
  SelectedMediaNotifier() : super([]);

  void toggleSelection(MediaItem item) {
    if (state.any((e) => e.id == item.id)) {
      state = state.where((e) => e.id != item.id).toList();
    } else {
      state = [...state, item];
    }
  }

  void clearSelection() {
    state = [];
  }
}

final selectedMediaProvider =
    StateNotifierProvider<SelectedMediaNotifier, List<MediaItem>>((ref) {
      return SelectedMediaNotifier();
    });
