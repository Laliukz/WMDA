import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/media_item.dart';
import 'media_thumbnail.dart';

class LibraryCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback? onPreview;
  final VoidCallback? onDelete;

  const LibraryCard({
    super.key,
    required this.item,
    this.onPreview,
    this.onDelete,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Reciente';
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
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]}, $hour:$minute';
  }

  String _formatSource(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.replaceFirst('www.', '');
      final path = uri.path;
      final preview = '$host$path';
      return preview.length > 35 ? '${preview.substring(0, 32)}...' : preview;
    } catch (_) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = item.type == MediaType.video;
    final title = item.title?.isNotEmpty == true
        ? item.title!
        : (item.url.split('/').last.split('?').first);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Previsualización de Imagen/Video
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen (desde archivo local o red) o Fallback de Video
                  MediaThumbnail(item: item),

                  // Botón central de Play si es video
                  if (isVideo)
                    Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.dark.withValues(alpha: 0.45),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),

                  // Badge superior derecho: "Image" o "Video"
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVideo
                                ? Icons.videocam_outlined
                                : Icons.image_outlined,
                            size: 13,
                            color: AppColors.dark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVideo ? 'Video' : 'Imagen',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 11,
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
          ),

          // 2. Información y Acciones
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSmall.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),

                // Dominio / Enlace
                Text(
                  _formatSource(item.url),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),

                // Fila inferior: Fecha + Acciones (Ojo y Basura)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(item.downloadedAt),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.neutral,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        // Botón de visualización
                        IconButton(
                          icon: const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          onPressed: onPreview,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        // Botón de eliminar
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: Color(0xFFD32F2F),
                          ),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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
    );
  }
}
