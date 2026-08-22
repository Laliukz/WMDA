import 'package:flutter/material.dart';

import 'data/repositories/media_repository_impl.dart';
import 'domain/usercases/scan_url_usecase.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('WMDA Tester')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final repo = MediaRepositoryImpl();
              final scanUseCase = ScanUrlUsecase(repo);
              final results = await scanUseCase('https://flutter.dev');
              print('Encontrados: ${results.length} elementos');

              for (var item in results) {
                print('${item.type}: ${item.url}');
              }
            },
            child: const Text('Probar Scraper'),
          ),
        ),
      ),
    );
  }
}
