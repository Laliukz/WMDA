import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/media_item.dart';
import 'repository_providers.dart';

enum ScanStatus { initial, loading, success, error }

class ScanState {
  final ScanStatus status;
  final List<MediaItem> items;
  final String? errorMessage;

  const ScanState({
    this.status = ScanStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  ScanState copyWith({
    ScanStatus? status,
    List<MediaItem>? items,
    String? errorMessage,
  }) {
    return ScanState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  final Ref _ref;

  ScanNotifier(this._ref) : super(const ScanState());

  Future<void> scan(String url) async {
    if (url.trim().isEmpty) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Por favor ingresa una URL valida',
      );
      return;
    }

    state = state.copyWith(status: ScanStatus.loading, errorMessage: null);

    try {
      final scanUseCase = _ref.read(scanUrlUseCaseProvider);
      final results = await scanUseCase(url);
      state = state.copyWith(status: ScanStatus.success, items: results);
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clear() {
    state = const ScanState();
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref);
});
