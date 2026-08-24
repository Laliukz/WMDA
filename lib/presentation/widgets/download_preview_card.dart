import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/media_item.dart';

class DownloadPreviewCard extends StatelessWidget {
  final MediaItem item;
  final String sizeLabel;
  final double? height;

  const DownloadPreviewCard({
    super.key,
    required this.item,
    required this.sizeLabel,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final displayUrl = item.previewUrl ?? item.url;
    final isVideo = item.type == MediaType.video;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            //miniatura
            CachedNetworkImage(
              imageUrl: displayUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.chipBackground,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFFE2E8F0),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.neutral,
                    size: 32,
                  ),
                ),
              ),
            ),
            //Badge
            Positioned(
              top: 20,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                      size: 14,
                      color: AppColors.dark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sizeLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.dark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
