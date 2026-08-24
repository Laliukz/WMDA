import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/media_item.dart';
import '../providers/download_provider.dart';
import '../widgets/screen_header.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(downloadProvider);
    final activeItems = downloadState.downloadingItems.values.toList();

    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera fija
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: ScreenHeader(
                title: 'Descargas Activas',
                trailing: activeItems.isEmpty
                    ? null
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${activeItems.length} en curso',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),

            // Barra de acción para cancelar todas si hay descargas activas
            if (activeItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'En cola / procesando',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.neutral,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(downloadProvider.notifier).cancelAll();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cancel_outlined,
                              size: 15,
                              color: Color(0xFFD32F2F),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Cancelar todas',
                              style: AppTypography.labelSmall.copyWith(
                                color: const Color(0xFFD32F2F),
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

            // Contenido: Lista activa o estado vacío
            Expanded(
              child: activeItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      itemCount: activeItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = activeItems[index];
                        final progress =
                            downloadState.progressMap[item.id] ?? 0.0;
                        return _ActiveDownloadCard(
                          item: item,
                          progress: progress,
                          onCancel: () {
                            ref.read(downloadProvider.notifier).cancel(item.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.chipBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_download_outlined,
                size: 52,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No hay descargas activas',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando inicies la descarga de imágenes o videos desde la pestaña de Escaneo, podrás seguir su progreso aquí.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveDownloadCard extends StatelessWidget {
  final MediaItem item;
  final double progress;
  final VoidCallback onCancel;

  const _ActiveDownloadCard({
    required this.item,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = item.type == MediaType.video;
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Miniatura
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildThumbnail(isVideo),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        isVideo
                            ? Icons.play_arrow_rounded
                            : Icons.image_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Detalles y Barra de Progreso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title ??
                            (isVideo
                                ? 'Video en descarga'
                                : 'Imagen en descarga'),
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$percentage%',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress > 0 ? progress : null,
                    minHeight: 6,
                    backgroundColor: AppColors.chipBackground,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Descargando...',
                      style: AppTypography.label.copyWith(
                        color: AppColors.neutral,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Botón para cancelar descarga individual
          IconButton(
            onPressed: onCancel,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.neutral,
              size: 20,
            ),
            tooltip: 'Cancelar descarga',
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

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
        placeholder: (_, _) => Container(color: AppColors.chipBackground),
        errorWidget: (_, _, _) => isVideo
            ? _buildVideoPlaceholder()
            : Container(
                color: AppColors.chipBackground,
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.neutral,
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
      placeholder: (_, _) => Container(color: AppColors.chipBackground),
      errorWidget: (_, _, _) => Container(
        color: AppColors.chipBackground,
        child: const Icon(
          Icons.image_outlined,
          color: AppColors.neutral,
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
          size: 24,
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
