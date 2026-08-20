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
    final items = <MediaItem>[];

    //imagenes
    final ogImages = doc.querySelectorAll(
      'meta[property="og:image"], meta[name="twitter:image"]',
    );
    for (var meta in ogImages) {
      final url = UrlHelper.resolve(baseUri, meta.attributes['content']);
      if (url != null) {
        items.add(_createItem(url, title, MediaType.image));
      }
    }

    //videos
    final ogVideos = doc.querySelectorAll(
      'meta[property="og:video"], meta[property="og:video:url"]',
    );
    for (var meta in ogVideos) {
      final url = UrlHelper.resolve(baseUri, meta.attributes['content']);
      if (url != null) {
        items.add(_createItem(url, title, MediaType.video));
      }
    }
    return items;
  }

  //extrae etiquetas img
  static List<MediaItem> extractImages(
    Document doc,
    Uri baseUri,
    String defaultTitle,
  ) {
    final items = <MediaItem>[];
    final images = doc.querySelectorAll('img');

    for (var img in images) {
      final rawSrc =
          img.attributes['src'] ??
          img.attributes['data-src'] ??
          img.attributes['data-original'];
      final url = UrlHelper.resolve(baseUri, rawSrc);
      if (url != null) {
        final alt = img.attributes['alt']?.trim();
        final title = (alt != null && alt.isNotEmpty) ? alt : defaultTitle;
        items.add(_createItem(url, title, MediaType.image));
      }
    }
    return items;
  }

  //extrae etiquetas video
  static List<MediaItem> extractVideos(
    Document doc,
    Uri baseUri,
    String title,
  ) {
    final items = <MediaItem>[];
    for (var video in doc.querySelectorAll('video')) {
      final url = UrlHelper.resolve(baseUri, video.attributes['src']);
      final poster = UrlHelper.resolve(baseUri, video.attributes['poster']);
      if (url != null) {
        items.add(_createItem(url, title, MediaType.video, previewUrl: poster));
      }
    }

    for (var source in doc.querySelectorAll('video source')) {
      final url = UrlHelper.resolve(baseUri, source.attributes['src']);
      if (url != null) {
        items.add(_createItem(url, title, MediaType.video));
      }
    }
    return items;
  }

  //extrae enlaces a archivos multimedia
  static List<MediaItem> extractDirectLinks(
    Document doc,
    Uri baseUri,
    String title,
  ) {
    final items = <MediaItem>[];
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

    for (var a in doc.querySelectorAll('a[href]')) {
      final url = UrlHelper.resolve(baseUri, a.attributes['href']);
      if (url != null) {
        final ext = UrlHelper.getExtension(Uri.parse(url).path);
        if (ext != null && mediaExtensions.containsKey(ext)) {
          items.add(_createItem(url, title, mediaExtensions[ext]!));
        }
      }
    }
    return items;
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
