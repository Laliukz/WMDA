import 'package:html/dom.dart';

import '../../core/utils/url_helper.dart';
import '../../domain/entities/media_item.dart';

class ScraperExtractors {
  static String extractTitle(Document doc) {
    //extrae el titulo de la pagina
    final ogTitle = doc
        .querySelector('meta[property="og:title"]')
        ?.attributes['content'];
    if (ogTitle != null && ogTitle.trim().isNotEmpty) return ogTitle.trim();

    final titleTag = doc.querySelector('title')?.text;
    if (titleTag != null && titleTag.trim().isNotEmpty) return titleTag.trim();

    return 'Sin titulo';
  }

  //extrae open graph
  static List<MediaItem> extractOpenGraph(
    Document doc,
    Uri baseUri,
    String title,
  ) {
    final images = doc
        .querySelectorAll(
          'meta[property="og:image"], meta[name="twitter:image"]',
        )
        .map((meta) {
          final url = UrlHelper.resolve(baseUri, meta.attributes['content']);
          return url != null ? _createItem(url, title, MediaType.image) : null;
        })
        .whereType<MediaItem>();

    final videos = doc
        .querySelectorAll(
          'meta[property="og:video"], meta[property="og:video:url"]',
        )
        .map((meta) {
          final url = UrlHelper.resolve(baseUri, meta.attributes['content']);
          return url != null ? _createItem(url, title, MediaType.video) : null;
        })
        .whereType<MediaItem>();

    return [...images, ...videos];
  }

  //extrae etiquetas img
  static List<MediaItem> extractImages(
    Document doc,
    Uri baseUri,
    String defaultTitle,
  ) {
    return doc
        .querySelectorAll('img')
        .map((img) {
          final rawSrc =
              img.attributes['src'] ??
              img.attributes['data-src'] ??
              img.attributes['data-original'];
          final url = UrlHelper.resolve(baseUri, rawSrc);
          if (url == null) return null;
          final title = (img.attributes['alt']?.trim().isNotEmpty ?? false)
              ? img.attributes['alt']!.trim()
              : defaultTitle;
          return _createItem(url, title, MediaType.image);
        })
        .whereType<MediaItem>()
        .toList();
  }

  //extrae etiquetas video
  static List<MediaItem> extractVideos(
    Document doc,
    Uri baseUri,
    String title,
  ) {
    final List<MediaItem> results = [];

    for (final video in doc.querySelectorAll('video')) {
      final rawPoster = video.attributes['poster'] ??
          video.attributes['data-poster'] ??
          video.attributes['data-src'];
      final poster = UrlHelper.resolve(baseUri, rawPoster);

      final rawVideoSrc = video.attributes['src'] ??
          video.attributes['data-src'] ??
          video.attributes['data-url'];
      final videoSrc = UrlHelper.resolve(baseUri, rawVideoSrc);

      if (videoSrc != null) {
        results.add(
          _createItem(videoSrc, title, MediaType.video, previewUrl: poster),
        );
      }

      for (final source in video.querySelectorAll('source')) {
        final rawSourceSrc = source.attributes['src'] ??
            source.attributes['data-src'] ??
            source.attributes['data-url'];
        final sourceSrc = UrlHelper.resolve(baseUri, rawSourceSrc);
        if (sourceSrc != null) {
          results.add(
            _createItem(
              sourceSrc,
              title,
              MediaType.video,
              previewUrl: poster,
            ),
          );
        }
      }
    }

    return results;
  }

  //extrae enlaces a archivos multimedia
  static List<MediaItem> extractDirectLinks(
    Document doc,
    Uri baseUri,
    String title,
  ) {
    final mediaExtensions = {
      'jpg': MediaType.image,
      'jpeg': MediaType.image,
      'png': MediaType.image,
      'gif': MediaType.image,
      'webp': MediaType.image,
      'mp4': MediaType.video,
      'webm': MediaType.video,
      'mkv': MediaType.video,
      'avi': MediaType.video,
    };

    return doc
        .querySelectorAll('a[href]')
        .map((a) {
          final url = UrlHelper.resolve(baseUri, a.attributes['href']);
          if (url == null) return null;
          final ext = UrlHelper.getExtension(Uri.parse(url).path);
          if (ext == null || !mediaExtensions.containsKey(ext)) return null;
          return _createItem(url, title, mediaExtensions[ext]!);
        })
        .whereType<MediaItem>()
        .toList();
  }

  static MediaItem _createItem(
    String url,
    String title,
    MediaType type, {
    String? previewUrl,
  }) {
    return MediaItem(
      id: url,
      url: url,
      previewUrl: previewUrl ?? url,
      title: title,
      type: type,
      extension: UrlHelper.getExtension(Uri.parse(url).path),
    );
  }
}
