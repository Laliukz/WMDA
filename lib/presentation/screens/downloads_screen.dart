import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/media_item.dart';
import '../providers/download_provider.dart';
import '../widgets/dowload_summary_footer.dart';
import '../widgets/download_preview_card.dart';
import '../widgets/downloads_header.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //datos de demostracion
    final demoItems = [
      const MediaItem(
        id: '1',
        url: 'https://picsum.photos/800/600?random=1',
        //sourcePageUrl: 'http//example.com',
        type: MediaType.image,
      ),
      const MediaItem(
        id: '2',
        url: 'https://picsum.photos/800/400?random=4',
        //sourcePageUrl: 'http//example.com',
        type: MediaType.image,
      ),
    ];

    final downloadState = ref.watch(downloadProvider);
    final isDownloading = downloadState.downloadingIds.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //header
              DownloadsHeader(itemCount: demoItems.length),
              const SizedBox(height: 20),

              //lista de descargas
              DownloadPreviewCard(
                item: demoItems[0],
                sizeLabel: '1.2 GB',
                height: 240,
              ),
              const SizedBox(height: 12),

              DownloadSummaryFooter(
                totalSize: "2.4 GB",
                isDownloading: isDownloading,
                onDownloadAll: () {
                  for (final item in demoItems) {
                    ref.read(downloadProvider.notifier).download(item);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Descargando todos los elementos...'),
                      duration: Duration(seconds: 4),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
