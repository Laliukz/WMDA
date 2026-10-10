import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/media_item.dart';
import '../../domain/entities/scan_result.dart';
import 'repository_providers.dart';

enum ScanStatus { initial, loading, success, error }

class ScanState {
  final ScanStatus status;
  final List<MediaItem> items;
  final List<SubpageLink> subpages;
  final String? currentUrl;
  final List<String> history;
  final String? errorMessage;

  const ScanState({
    this.status = ScanStatus.initial,
    this.items = const [],
    this.subpages = const [],
    this.currentUrl,
    this.history = const [],
    this.errorMessage,
  });

  bool get canGoBack => history.isNotEmpty;

  ScanState copyWith({
    ScanStatus? status,
    List<MediaItem>? items,
    List<SubpageLink>? subpages,
    String? currentUrl,
    List<String>? history,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ScanState(
      status: status ?? this.status,
      items: items ?? this.items,
      subpages: subpages ?? this.subpages,
      currentUrl: currentUrl ?? this.currentUrl,
      history: history ?? this.history,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  final Ref _ref;
  final List<String> _history = [];
  String? _currentUrl;

  ScanNotifier(this._ref) : super(const ScanState());

  Future<void> scan(String url) async {
    if (url.trim().isEmpty) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Por favor ingresa una URL valida',
      );
      return;
    }

    _history.clear();
    await _load(url);
  }

  // Abrir un enlace interno: guarda el actual para poder volver
  Future<void> openSubpage(String url) async {
    if (url == _currentUrl) return;
    if (_currentUrl != null) _history.add(_currentUrl!);
    await _load(url);
  }

  Future<void> goBack() async {
    if (_history.isEmpty) return;
    await _load(_history.removeLast());
  }

  Future<void> _load(String url) async {
    state = state.copyWith(status: ScanStatus.loading, clearErrorMessage: true);

    try {
      final scanUseCase = _ref.read(scanUrlUseCaseProvider);
      final result = await scanUseCase(url);
      _currentUrl = url;
      state = state.copyWith(
        status: ScanStatus.success,
        items: result.items,
        subpages: result.subpages,
        currentUrl: url,
        history: List.of(_history),
        clearErrorMessage: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        history: List.of(_history),
        errorMessage: e.toString(),
      );
    }
  }

  void clear() {
    _history.clear();
    _currentUrl = null;
    state = const ScanState();
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref);
});
