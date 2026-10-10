import 'package:html/dom.dart';

import '../../core/utils/url_helper.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/scan_result.dart';

class ScraperExtractors {
  static String extractTitle(Document doc) {
    //extrae el titulo del documento
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
          return url != null
              ? _createItem(baseUri, url, title, MediaType.image)
              : null;
        })
        .whereType<MediaItem>();

    final videos = doc
        .querySelectorAll(
          'meta[property="og:video"], meta[property="og:video:url"]',
        )
        .map((meta) {
          final url = UrlHelper.resolve(baseUri, meta.attributes['content']);
          // og:video:url suele ser HTML, no el archivo: sin extensión
          // no es descargable
          if (url == null || UrlHelper.getExtension(Uri.parse(url).path) == null) {
            return null;
          }
          return _createItem(baseUri, url, title, MediaType.video);
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
          return _createItem(baseUri, url, title, MediaType.image);
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
          _createItem(
            baseUri,
            videoSrc,
            title,
            MediaType.video,
            previewUrl: poster,
          ),
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
              baseUri,
              sourceSrc,
              title,
              MediaType.video,
              previewUrl: poster,
            ),
          );
        }
      }
    }

    // Galerías con preview en data-preview (thumbnail -> mp4) en cualquier tag
    for (final el in doc.querySelectorAll('[data-preview]')) {
      final videoSrc = UrlHelper.resolve(
        baseUri,
        el.attributes['data-preview'],
      );
      if (videoSrc == null || !_isVideoUrl(videoSrc)) continue;
      final itemTitle =
          (el.attributes['alt']?.trim().isNotEmpty ?? false)
          ? el.attributes['alt']!.trim()
          : title;
      final preview = UrlHelper.resolve(
        baseUri,
        el.attributes['data-webp'] ?? el.attributes['src'],
      );
      results.add(
        _createItem(
          baseUri,
          videoSrc,
          itemTitle,
          MediaType.video,
          previewUrl: preview,
        ),
      );
    }

    return results;
  }

  static bool _isVideoUrl(String url) {
    final ext = UrlHelper.getExtension(Uri.parse(url).path);
    return ext == 'mp4' ||
        ext == 'webm' ||
        ext == 'mkv' ||
        ext == 'avi' ||
        ext == 'mov';
  }

  // Basura universal: iconos UI, emoticonos, popups de verificación, etc.
  static bool isJunkUrl(String url) {
    final lower = url.toLowerCase();
    return const [
      'emoticon',
      'favicon',
      'apple-touch',
      'apple-smiles',
      'age-verification',
      'sprite',
      'placeholder',
      'blank.',
      'spacer',
      'pixel.',
    ].any(lower.contains);
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
          return _createItem(baseUri, url, title, mediaExtensions[ext]!);
        })
        .whereType<MediaItem>()
        .toList();
  }

  // Enlaces internos con vista previa: el ancla envuelve una
  // imagen/preview y apunta a otra URL del mismo host
  static List<SubpageLink> extractSubpages(Document doc, Uri baseUri) {
    const mediaExtensions = {
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'mp4',
      'webm',
      'mkv',
      'avi',
      'mov',
      'm3u8',
    };
    final results = <SubpageLink>[];
    final seen = <String>{};
    for (final a in doc.querySelectorAll('a[href]')) {
      final url = UrlHelper.resolve(baseUri, a.attributes['href']);
      if (url == null || url == baseUri.toString() || !seen.add(url)) {
        continue;
      }
      final uri = Uri.tryParse(url);
      if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
        continue;
      }
      if (uri.host != baseUri.host) continue; // mismo host, sin externos
      if (isJunkUrl(url)) continue;
      final ext = UrlHelper.getExtension(uri.path);
      if (ext != null && mediaExtensions.contains(ext)) {
        continue; // ya sale como item descargable
      }
      final media = a.querySelector('img, video, source, [data-preview]');
      if (media == null) continue; // solo con contenido visual, no texto
      final img = media.localName == 'img' ? media : a.querySelector('img');
      final preview = UrlHelper.resolve(
        baseUri,
        img?.attributes['src'] ?? img?.attributes['data-src'],
      );
      var title = img?.attributes['alt']?.trim() ?? '';
      if (title.isEmpty) {
        title = a.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      }
      if (title.length > 80) title = '${title.substring(0, 80)}…';
      if (title.isEmpty) title = uri.host;
      results.add(SubpageLink(title: title, url: url, previewUrl: preview));
    }
    return results;
  }

  // Archivos dentro de <script>: el video completo a veces solo está
  // en el JS, no en etiquetas <video>
  static List<MediaItem> extractEmbeddedFiles(
    String html,
    Uri baseUri,
    String title,
  ) {
    final byPath = <String, String>{};
    final re = RegExp("https?://[^\\s\"'<>]+\\.mp4/?(?:\\?[^\\s\"'<>]*)?");
    for (final m in re.allMatches(html)) {
      // evita recortes tipo preview.mp4.jpg (coincidencia parcial)
      if (m.end < html.length &&
          RegExp(r'[A-Za-z0-9.]').hasMatch(html[m.end])) {
        continue;
      }
      final url = m.group(0)!.replaceAll('&amp;', '&');
      if (url.contains('_preview.mp4')) continue;
      final path = Uri.tryParse(url)?.path ?? url;
      final prev = byPath[path];
      // misma ruta con y sin token: vale la que trae query (token de acceso)
      if (prev == null ||
          (Uri.parse(prev).query.isEmpty &&
              Uri.parse(url).query.isNotEmpty)) {
        byPath[path] = url;
      }
    }
    return byPath.values.map((url) {
      final quality = RegExp(r'_(\d+p)\.mp4').firstMatch(url)?.group(1);
      return _createItem(
        baseUri,
        url,
        quality != null ? '$title [$quality]' : title,
        MediaType.video,
      );
    }).toList();
  }

  static MediaItem _createItem(
    Uri baseUri,
    String url,
    String title,
    MediaType type, {
    String? previewUrl,
  }) {
    return MediaItem(
      // id con host: el mismo archivo servido por dos hosts no colisiona
      id: '${baseUri.host}#$url',
      url: url,
      previewUrl: previewUrl ?? url,
      title: title,
      type: type,
      extension: UrlHelper.getExtension(Uri.parse(url).path),
      referer: baseUri.toString(),
    );
  }
}
