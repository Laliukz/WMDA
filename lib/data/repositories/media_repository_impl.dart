import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/media_item.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/media_repository.dart';
import '../models/media_item_model.dart';
import '../services/download_service.dart';
import '../services/scraper_service.dart';

class MediaRepositoryImpl implements MediaRepository {
  final ScraperService _scraperService;
  final DownloadService _downloadService;

  static const String _historyKey = 'media_downloads_history';
  // ponytail: tope 200, SharedPreferences crece sin límite
  static const int _maxHistory = 200;

  MediaRepositoryImpl({
    ScraperService? scraperService,
    DownloadService? downloadService,
  }) : _scraperService = scraperService ?? ScraperService(),
       _downloadService = downloadService ?? DownloadService();

  @override
  Future<ScanResult> scanURL(String url) async {
    return await _scraperService.scrapeFull(url);
  }

  @override
  Future<MediaItem> downloadMedia(
    MediaItem item, {
    void Function(double progress)? onProgress,
  }) async {
    final localPath = await _downloadService.downloadFile(
      item,
      onProgress: onProgress,
    );

    final downloadedItem = item.copyWith(
      localPath: localPath,
      downloadedAt: DateTime.now(),
      isDownloaded: true,
    );

    await _saveToHistory(downloadedItem);
    return downloadedItem;
  }

  @override
  Future<List<MediaItem>> getDownloadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];

    // Entradas corruptas se descartan en vez de tumbar el historial
    final items = <MediaItem>[];
    for (final jsonStr in jsonList) {
      try {
        items.add(MediaItemModel.fromMap(jsonDecode(jsonStr)));
      } catch (_) {
        continue;
      }
    }
    return items;
  }

  @override
  Future<void> deleteFromHistory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getDownloadHistory();

    final removed = history.where((item) => item.id == id);
    for (final item in removed) {
      final path = item.localPath;
      if (path != null && path.isNotEmpty) {
        try {
          final f = File(path);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }

    final updatedHistory = history.where((item) => item.id != id).toList();
    final jsonList = updatedHistory
        .map((item) => jsonEncode(MediaItemModel.fromEntity(item).toMap()))
        .toList();

    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<void> _saveToHistory(MediaItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getDownloadHistory();

    // Reemplaza si ya existía o agrega al inicio
    final updatedHistory = [
      item,
      ...history.where((element) => element.id != item.id),
    ].take(_maxHistory).toList();

    final jsonList = updatedHistory
        .map((e) => jsonEncode(MediaItemModel.fromEntity(e).toMap()))
        .toList();

    await prefs.setStringList(_historyKey, jsonList);
  }

  @override
  void cancelDownload(String id) {
    _downloadService.cancelDownload(id);
  }

  @override
  void cancelAllDownloads() {
    _downloadService.cancelAll();
  }
}

