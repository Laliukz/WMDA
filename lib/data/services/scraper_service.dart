import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import '../../core/errors/failures.dart';
import '../../core/utils/url_helper.dart';
import '../../domain/entities/media_item.dart';
import 'scraper_extractors.dart';

class ScraperService {
  final http.Client _client;

  ScraperService({http.Client? client}) : _client = client ?? http.Client();

  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/*,*/*;q=0.8',
  };

  Future<List<MediaItem>> scrape(String rawUrl) async {
    final cleanUrl = UrlHelper.format(rawUrl);
    final baseUri = Uri.tryParse(cleanUrl);

    if (baseUri == null || !baseUri.hasScheme) {
      throw const InvalidUrlFailure();
    }

    try {
      final response = await _client.get(baseUri, headers: _headers);

      if (response.statusCode != 200) {
        throw ServerFailure(
          'Error HTTP ${response.statusCode} al obtener la página',
        );
      }

      final doc = html_parser.parse(response.body);
      final title = ScraperExtractors.extractTitle(doc);

      //combinamos todos los extractores
      final allItems = [
        ...ScraperExtractors.extractOpenGraph(doc, baseUri, title),
        ...ScraperExtractors.extractImages(doc, baseUri, title),
        ...ScraperExtractors.extractVideos(doc, baseUri, title),
        ...ScraperExtractors.extractDirectLinks(doc, baseUri, title),
      ];

      //eliminar duplicados
      final uniqueMap = {for (var item in allItems) item.url: item};
      final results = uniqueMap.values.toList();

      if (results.isEmpty) {
        throw const ScrapingFailure();
      }
      return results;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ScrapingFailure('Error al procesar la página: $e');
    }
  }
}
