import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/media_item.dart';

class RecentMediaCard extends StatelessWidget {
  final MediaItem item;
  final String dateLabel;
  final String sizeLabel;
  final VoidCallback? onTap;

  const RecentMediaCard({
    super.key,
    required this.item,
    this.dateLabel = 'Hoy, 14:30',
    this.sizeLabel = '124 MB',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = item.type == MediaType.video;
    final hasLocalFile =
        item.localPath != null && File(item.localPath!).existsSync();
    final title = item.title?.isNotEmpty == true
        ? item.title!
        : (item.url.split('/').last.split('?').first);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagen / Miniatura
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasLocalFile && !isVideo)
                      Image.file(File(item.localPath!), fit: BoxFit.cover)
                    else
                      CachedNetworkImage(
                        imageUrl: item.previewUrl ?? item.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: AppColors.chipBackground),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.neutral,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                    // Badge de Calidad (1080p) en esquina inferior derecha
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dark.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isVideo ? '1080p' : 'HD',
                          style: AppTypography.badge.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Información del Archivo
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file_outlined,
                            size: 14,
                            color: AppColors.neutral,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sizeLabel,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
