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

  void setSelected(List<MediaItem> items) {
    state = items;
  }

  void selectAll(List<MediaItem> items) {
    state = List.from(items);
  }

  void clearSelection() {
    state = [];
  }

  bool isSelected(String id) {
    return state.any((e) => e.id == id);
  }
}

final selectedMediaProvider =
    StateNotifierProvider<SelectedMediaNotifier, List<MediaItem>>((ref) {
      return SelectedMediaNotifier();
    });
