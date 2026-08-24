import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/media_item.dart';
import '../providers/history_provider.dart';
import '../widgets/home_discovery_banner.dart';
import '../widgets/recent_media_card.dart';
import '../widgets/recent_section_header.dart';
import '../widgets/screen_header.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToScan;
  final VoidCallback onNavigateToLibrary;

  const HomeScreen({
    super.key,
    required this.onNavigateToScan,
    required this.onNavigateToLibrary,
  });

  String _formatRecentDate(DateTime? date) {
    if (date == null) return 'Reciente';
    final now = DateTime.now();
    final difference = now.difference(date);

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    if (difference.inDays == 0 && now.day == date.day) {
      return 'Hoy, $hour:$minute';
    } else if (difference.inDays <= 1) {
      return 'Ayer, $hour:$minute';
    } else {
      const months = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      return '${date.day} ${months[date.month - 1]}, $hour:$minute';
    }
  }

  void _showPreviewDialog(BuildContext context, MediaItem item) {
    final hasLocalFile =
        item.localPath != null && File(item.localPath!).existsSync();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: AppColors.dark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasLocalFile && item.type == MediaType.image)
                  Image.file(File(item.localPath!), fit: BoxFit.contain)
                else
                  Image.network(
                    item.previewUrl ?? item.url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Branding Superior
              const HeaderBrandRow(),
              const SizedBox(height: 20),

              // 2. Banner "Descubre contenido"
              HomeDiscoveryBanner(onExplore: onNavigateToScan),
              const SizedBox(height: 28),

              // 3. Encabezado "Recientes" + "Ver todo"
              RecentSectionHeader(onViewAll: onNavigateToLibrary),
              const SizedBox(height: 16),

              // 4. Lista de Descargas Recientes
              historyAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (error, stack) => const SizedBox(),
                data: (items) {
                  if (items.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.history_toggle_off_rounded,
                              size: 40,
                              color: AppColors.neutral,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Aún no hay descargas recientes',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.neutral,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Mostramos los 3 más recientes
                  final recentList = items.take(3).toList();
                  return Column(
                    children: recentList.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: RecentMediaCard(
                          item: item,
                          dateLabel: _formatRecentDate(item.downloadedAt),
                          sizeLabel: item.type == MediaType.video
                              ? '150 MB'
                              : '12 MB',
                          onTap: () => _showPreviewDialog(context, item),
                        ),
                      );
                    }).toList(),
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
