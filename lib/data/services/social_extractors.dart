import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/url_helper.dart';
import '../../domain/entities/media_item.dart';

// Resolutores por host para URLs que el scraping genérico no cubre:
// el hilo de X exige sesión, así que se usa su API pública de lectura.
class SocialExtractors {
  static bool isFacebookUrl(Uri uri) {
    final host = uri.host.toLowerCase();
    return host == 'facebook.com' ||
        host.endsWith('.facebook.com') ||
        host == 'fb.com' ||
        host.endsWith('.fb.com') ||
        host == 'fb.watch';
  }

  // UA con el que Facebook sirve HTML estático con og:* sin sesión
  static const facebookUserAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
      'Mobile/15E148 Safari/604.1';

  static String? tweetId(Uri uri) {
    final host = uri.host.toLowerCase();
    final isX =
        host == 'x.com' ||
        host.endsWith('.x.com') ||
        host == 'twitter.com' ||
        host.endsWith('.twitter.com');
    if (!isX) return null;
    final segs = uri.pathSegments;
    final i = segs.indexOf('status');
    if (i < 0 || i + 1 >= segs.length) return null;
    final id = segs[i + 1];
    return RegExp(r'^\d+$').hasMatch(id) ? id : null;
  }

  static bool isTikTokUrl(Uri uri) {
    final host = uri.host.toLowerCase();
    return host == 'tiktok.com' ||
        host.endsWith('.tiktok.com') ||
        host == 'vt.tiktok.com' ||
        host == 'vm.tiktok.com';
  }

  // Video directo sin marca vía API pública de lectura
  static Future<List<MediaItem>> resolveTikTok(
    http.Client client,
    Uri pageUri,
  ) async {
    final res = await client
        .get(
          Uri.parse(
            'https://www.tikwm.com/api/?url=${Uri.encodeComponent(pageUri.toString())}',
          ),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw StateError('HTTP ${res.statusCode}');
    final data = (jsonDecode(res.body) as Map<String, dynamic>)['data'];
    if (data is! Map<String, dynamic>) throw const FormatException('sin video');
    final url = data['play'] as String? ?? data['wmplay'] as String?;
    if (url == null || url.isEmpty) throw const FormatException('sin video');
    var title = (data['title'] as String? ?? '').replaceAll(
      RegExp(r'\s+'),
      ' ',
    ).trim();
    if (title.length > 80) title = '${title.substring(0, 80)}…';
    final author = (data['author'] as Map?)?['nickname'] as String?;
    if (title.isEmpty) title = author ?? 'tiktok';
    final preview = UrlHelper.resolve(
      pageUri,
      data['cover'] as String?,
    );
    return [
      MediaItem(
        id: 'tiktok#$url',
        url: url,
        previewUrl: preview ?? url,
        title: author != null ? '@$author: $title' : title,
        type: MediaType.video,
        extension: 'mp4',
        referer: pageUri.toString(),
      ),
    ];
  }

  // Lee el hilo vía API pública y devuelve sus fotos/videos directos
  static Future<List<MediaItem>> resolveTweet(
    http.Client client,
    Uri pageUri,
    String id,
  ) async {
    final res = await client
        .get(
          Uri.parse('https://api.fxtwitter.com/i/status/$id'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw StateError('HTTP ${res.statusCode}');
    }
    final tweet = (jsonDecode(res.body) as Map<String, dynamic>)['tweet'];
    if (tweet is! Map<String, dynamic>) throw const FormatException('sin hilo');
    final author = (tweet['author'] as Map?)?['screen_name'] ?? 'x';
    var title = (tweet['text'] as String? ?? '').replaceAll(
      RegExp(r'\s+'),
      ' ',
    ).trim();
    if (title.length > 80) title = '${title.substring(0, 80)}…';
    if (title.isEmpty) title = '@$author';
    title = '@$author: $title';

    final media = tweet['media'];
    final items = <MediaItem>[];
    if (media is Map<String, dynamic>) {
      for (final p in (media['photos'] as List? ?? [])) {
        if (p is! Map) continue;
        final url = UrlHelper.resolve(pageUri, p['url'] as String?);
        if (url == null) continue;
        items.add(
          MediaItem(
            id: 'x#$url',
            url: url,
            previewUrl: url,
            title: title,
            type: MediaType.image,
            extension: UrlHelper.getExtension(Uri.parse(url).path),
            referer: pageUri.toString(),
          ),
        );
      }
      for (final v in (media['videos'] as List? ?? [])) {
        if (v is! Map) continue;
        final url = UrlHelper.resolve(pageUri, v['url'] as String?);
        if (url == null) continue;
        final preview = UrlHelper.resolve(
          pageUri,
          v['thumbnail_url'] as String?,
        );
        items.add(
          MediaItem(
            id: 'x#$url',
            url: url,
            previewUrl: preview ?? url,
            title: title,
            type: MediaType.video,
            extension:
                UrlHelper.getExtension(Uri.parse(url).path) ?? 'mp4',
            referer: pageUri.toString(),
          ),
        );
      }
    }
    return items;
  }
}
