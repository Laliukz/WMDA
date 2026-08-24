import 'package:download_multimedia/presentation/screens/scan_screen.dart';
import 'package:download_multimedia/presentation/widgets/scan_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/widgets/scan_header.dart';
import 'presentation/widgets/url_input_bar.dart';

void main() {
  runApp(const ProviderScope(child: MediaDownloaderApp()));
}

class MediaDownloaderApp extends StatelessWidget {
  const MediaDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WMDA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ScanScreen(),
    );
  }
}
