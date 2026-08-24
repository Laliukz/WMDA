import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/media_item.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final bool isSelected;
  final ValueChanged<bool>? onSelectedChanged;
  final VoidCallback? onTap;

  const MediaCard({
    super.key,
    required this.item,
    this.isSelected = false,
    this.onSelectedChanged,
    this.onTap,
  });

  Map<String, String> _imageHeaders(String url) {
    try {
      final uri = Uri.parse(url);
      return {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'Referer': '${uri.scheme}://${uri.host}/',
        'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
      };
    } catch (_) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = item.type == MediaType.video;
    final extensionLabel = (item.extension ?? (isVideo ? 'mp4' : 'jpg'))
        .toUpperCase();
    final badgeText = '${isVideo ? 'VIDEO' : 'IMAGE'} • $extensionLabel';

    // Obtenemos un nombre legible a partir del título o la URL
    final fileName = item.title?.isNotEmpty == true
        ? item.title!
        : item.url.split('/').last.split('?').first;

    return GestureDetector(
      onTap: onTap ?? () => onSelectedChanged?.call(!isSelected),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Imagen / Miniatura con CachedNetworkImage o Fallback de Video
              _buildThumbnail(isVideo),

              // 2. Gradiente inferior para legibilidad del texto
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.dark.withValues(alpha: 0.1),
                        Colors.transparent,
                        AppColors.dark.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Botón central de Play (solo para videos)
              if (isVideo)
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.dark.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

              // 4. Selector circular superior derecho
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => onSelectedChanged?.call(!isSelected),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.dark.withValues(alpha: 0.3),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : Colors.white.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 15, color: Colors.white)
                        : null,
                  ),
                ),
              ),

              // 5. Metadatos inferiores (Badge y Nombre)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge translúcido
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dark.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(badgeText, style: AppTypography.badge),
                    ),
                    const SizedBox(height: 4),
                    // Nombre del archivo
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isVideo) {
    final imagePreviewUrl = item.previewUrl;
    final hasValidImagePreview = imagePreviewUrl != null &&
        imagePreviewUrl.isNotEmpty &&
        !imagePreviewUrl.toLowerCase().endsWith('.mp4') &&
        !imagePreviewUrl.toLowerCase().endsWith('.webm');

    if (hasValidImagePreview) {
      return CachedNetworkImage(
        imageUrl: imagePreviewUrl,
        httpHeaders: _imageHeaders(imagePreviewUrl),
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
        errorWidget: (context, url, error) => isVideo
            ? _buildVideoPlaceholder()
            : Container(
                color: const Color(0xFFE2E8F0),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.neutral,
                    size: 32,
                  ),
                ),
              ),
      );
    }

    if (isVideo) {
      return _buildVideoPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: item.url,
      httpHeaders: _imageHeaders(item.url),
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
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.neutral,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            AppColors.primary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: 40,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
