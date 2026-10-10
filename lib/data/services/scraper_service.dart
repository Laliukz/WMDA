import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import '../../core/errors/failures.dart';
import '../../core/utils/url_helper.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/scan_result.dart';
import 'scraper_extractors.dart';

class ScraperService {
  final http.Client _client;

  ScraperService({http.Client? client}) : _client = client ?? http.Client();

  // ponytail: jar en memoria como un navegador; muchos gates (edad,
  // cookies) se abren solos al reintentar con la cookie que ellos emiten
  final Map<String, String> _cookieJar = {};

  static const _cookieAttrs = {
    'expires',
    'max-age',
    'domain',
    'path',
    'secure',
    'httponly',
    'samesite',
  };

  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/*,*/*;q=0.8',
  };

  Future<List<MediaItem>> scrape(String rawUrl) async {
    return (await scrapeFull(rawUrl)).items;
  }

  Future<ScanResult> scrapeFull(String rawUrl) async {
    final cleanUrl = UrlHelper.format(rawUrl);
    final baseUri = Uri.tryParse(cleanUrl);

    if (baseUri == null || !baseUri.hasScheme) {
      throw const InvalidUrlFailure();
    }

    try {
      final headers = Map<String, String>.from(_headers);
      final jar = _cookieJar[baseUri.host];
      if (jar != null && jar.isNotEmpty) headers['Cookie'] = jar;

      var response = await _client
          .get(baseUri, headers: headers)
          .timeout(const Duration(seconds: 15));

      // Si la respuesta trae cookies, reintenta una vez con ellas
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null && setCookie.isNotEmpty) {
        _storeCookies(baseUri.host, setCookie);
        final retryHeaders = Map<String, String>.from(_headers)
          ..['Cookie'] = _cookieJar[baseUri.host]!;
        response = await _client
            .get(baseUri, headers: retryHeaders)
            .timeout(const Duration(seconds: 15));
      }

      if (response.statusCode != 200) {
        throw ServerFailure(
          'Error HTTP ${response.statusCode} al obtener la página',
        );
      }

      // ponytail: body decodifica latin1 si el header no trae charset;
      // casi todo es UTF-8 real, se intenta eso primero
      String htmlBody;
      try {
        htmlBody = utf8.decode(response.bodyBytes);
      } catch (_) {
        htmlBody = response.body;
      }
      final doc = html_parser.parse(htmlBody);
      final title = ScraperExtractors.extractTitle(doc);

      //combinamos todos los extractores (el contenido principal primero)
      final allItems = [
        ...ScraperExtractors.extractEmbeddedFiles(
          htmlBody,
          baseUri,
          title,
        ),
        ...ScraperExtractors.extractOpenGraph(doc, baseUri, title),
        ...ScraperExtractors.extractImages(doc, baseUri, title),
        ...ScraperExtractors.extractVideos(doc, baseUri, title),
        ...ScraperExtractors.extractDirectLinks(doc, baseUri, title),
      ];

      //eliminar duplicados y basura (iconos, emoticonos, popups)
      final uniqueMap = {for (var item in allItems) item.url: item};
      final results = uniqueMap.values
          .where((item) => !ScraperExtractors.isJunkUrl(item.url))
          .toList();

      if (results.isEmpty) {
        throw const ScrapingFailure();
      }
      return ScanResult(
        items: results,
        subpages: ScraperExtractors.extractSubpages(doc, baseUri),
      );
    } catch (e) {
      if (e is Failure) rethrow;
      if (e is TimeoutException) {
        throw const ServerFailure('Tiempo de espera agotado al obtener página');
      }
      throw ScrapingFailure('Error al procesar la página: $e');
    }
  }

  void _storeCookies(String host, String setCookie) {
    final pairs = <String, String>{};
    for (final part in (_cookieJar[host] ?? '').split('; ')) {
      final i = part.indexOf('=');
      if (i > 0) pairs[part.substring(0, i)] = part.substring(i + 1);
    }
    for (final chunk in setCookie.split(';')) {
      final i = chunk.indexOf('=');
      if (i <= 0) continue;
      final name = chunk.substring(0, i).trim().toLowerCase();
      if (name.contains(' ') ||
          name.contains(',') ||
          _cookieAttrs.contains(name)) {
        continue;
      }
      pairs[chunk.substring(0, i).trim()] = chunk.substring(i + 1).trim();
    }
    _cookieJar[host] = pairs.entries
        .map((e) => '${e.key}=${e.value}')
        .join('; ');
  }
}
