import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/media_item.dart';

class MediaThumbnail extends StatelessWidget {
  final MediaItem item;
  final BoxFit fit;

  const MediaThumbnail({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Check local path if downloaded (solo imágenes; video va a placeholder)
    if (item.localPath != null && item.localPath!.isNotEmpty) {
      final file = File(item.localPath!);
      if (file.existsSync()) {
        if (item.type == MediaType.video) return _buildPlaceholder();
        return Image.file(
          file,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }

    // 2. Check previewUrl o url, nunca un archivo de video como imagen
    final imageUrl = item.previewUrl ?? item.url;
    if (imageUrl.isNotEmpty && !_isVideoUrl(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(isLoading: true),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    // 3. Fallback placeholder
    return _buildPlaceholder();
  }

  // ponytail: sin player, video nunca se carga como imagen
  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase().split('?').first;
    return lower.endsWith('.mp4') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mov');
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      color: AppColors.chipBackground,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                item.type == MediaType.video
                    ? Icons.videocam_outlined
                    : Icons.image_outlined,
                color: AppColors.neutral.withValues(alpha: 0.5),
                size: 32,
              ),
      ),
    );
  }
}
