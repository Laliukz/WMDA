import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/media_item.dart';
import '../providers/download_provider.dart';
import '../providers/selected_media_provider.dart';
import '../widgets/dowload_summary_footer.dart';
import '../widgets/download_preview_card.dart';
import '../widgets/downloads_header.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  String _estimateItemSize(MediaItem item) {
    if (item.type == MediaType.video) {
      return '150 MB';
    }
    final hash = item.id.hashCode.abs();
    final mb = (hash % 40) + 5;
    return '$mb MB';
  }

  String _calculateTotalSize(List<MediaItem> items) {
    if (items.isEmpty) return '0 MB';
    double totalMb = 0;
    for (final item in items) {
      if (item.type == MediaType.video) {
        totalMb += 150;
      } else {
        final hash = item.id.hashCode.abs();
        totalMb += (hash % 40) + 5;
      }
    }
    if (totalMb >= 1000) {
      return '${(totalMb / 1024).toStringAsFixed(2)} GB';
    }
    return '${totalMb.toStringAsFixed(0)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItems = ref.watch(selectedMediaProvider);
    final downloadState = ref.watch(downloadProvider);
    final isDownloading = downloadState.downloadingIds.isNotEmpty;

    if (selectedItems.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.tertiary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const DownloadsHeader(itemCount: 0),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppColors.chipBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.download_for_offline_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items selected',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan a URL and select media to download them here.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalSizeLabel = _calculateTotalSize(selectedItems);

    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header dinámico
              DownloadsHeader(itemCount: selectedItems.length),
              const SizedBox(height: 20),

              // 2. Mosaico Adaptativo de medios seleccionados
              DownloadPreviewCard(
                item: selectedItems[0],
                sizeLabel: _estimateItemSize(selectedItems[0]),
                height: 220,
              ),
              const SizedBox(height: 12),

              if (selectedItems.length >= 2) ...[
                Row(
                  children: [
                    Expanded(
                      child: DownloadPreviewCard(
                        item: selectedItems[1],
                        sizeLabel: _estimateItemSize(selectedItems[1]),
                        height: 140,
                      ),
                    ),
                    if (selectedItems.length >= 3) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: DownloadPreviewCard(
                          item: selectedItems[2],
                          sizeLabel: _estimateItemSize(selectedItems[2]),
                          height: 140,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
              ],

              if (selectedItems.length >= 4) ...[
                for (int i = 3; i < selectedItems.length; i++) ...[
                  DownloadPreviewCard(
                    item: selectedItems[i],
                    sizeLabel: _estimateItemSize(selectedItems[i]),
                    height: 140,
                  ),
                  const SizedBox(height: 12),
                ],
              ],

              const SizedBox(height: 12),

              // 3. Footer con Tamaño Total y Botón de Descarga
              DownloadSummaryFooter(
                totalSize: totalSizeLabel,
                isDownloading: isDownloading,
                onDownloadAll: () async {
                  final itemsToDownload = List<MediaItem>.from(selectedItems);
                  for (final item in itemsToDownload) {
                    await ref.read(downloadProvider.notifier).download(item);
                  }
                  ref.read(selectedMediaProvider.notifier).clearSelection();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Descargas completadas con éxito!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
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
