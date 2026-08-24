import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/media_item.dart';
import '../providers/history_provider.dart';
import '../widgets/filter_chips_bar.dart';
import '../widgets/library_card.dart';
import '../widgets/screen_header.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  MediaFilter _selectedFilter = MediaFilter.all;

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
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header con Filtros
              ScreenHeader(
                title: 'Biblioteca',
                trailing: Row(
                  children: [
                    _FilterChip(
                      label: 'Todos',
                      isSelected: _selectedFilter == MediaFilter.all,
                      onTap: () =>
                          setState(() => _selectedFilter = MediaFilter.all),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Imágenes',
                      isSelected: _selectedFilter == MediaFilter.images,
                      onTap: () =>
                          setState(() => _selectedFilter = MediaFilter.images),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Videos',
                      isSelected: _selectedFilter == MediaFilter.videos,
                      onTap: () =>
                          setState(() => _selectedFilter = MediaFilter.videos),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Lista de Elementos del Historial
              Expanded(
                child: historyAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (error, stack) =>
                      Center(child: Text('Error al cargar biblioteca: $error')),
                  data: (items) {
                    // Filtramos según el chip activo
                    final filtered = items.where((item) {
                      if (_selectedFilter == MediaFilter.images) {
                        return item.type == MediaType.image;
                      }
                      if (_selectedFilter == MediaFilter.videos) {
                        return item.type == MediaType.video;
                      }
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
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
                                Icons.folder_open_rounded,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No downloads yet',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Downloaded media will appear here.',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.neutral,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return LibraryCard(
                          item: item,
                          onPreview: () => _showPreviewDialog(context, item),
                          onDelete: () {
                            ref
                                .read(historyProvider.notifier)
                                .deleteItem(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Elemento eliminado del historial',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFE8EEF8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.dark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
