import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/media_item.dart';
import '../providers/download_provider.dart';
import '../providers/scan_provider.dart';
import '../providers/selected_media_provider.dart';
import '../widgets/filter_chips_bar.dart';
import '../widgets/media_card.dart';
import '../widgets/screen_header.dart';
import '../widgets/selection_bottom_bar.dart';
import '../widgets/url_input_bar.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final TextEditingController _urlController = TextEditingController();
  MediaFilter _selectedFilter = MediaFilter.all;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      // Limpiamos selecciones previas al hacer un nuevo escaneo
      ref.read(selectedMediaProvider.notifier).clearSelection();
      ref.read(scanProvider.notifier).scan(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final selectedItems = ref.watch(selectedMediaProvider);

    // Conteo de elementos escaneados según tipo
    final imagesCount = scanState.items
        .where((i) => i.type == MediaType.image)
        .length;
    final videosCount = scanState.items
        .where((i) => i.type == MediaType.video)
        .length;

    // Filtramos según el chip activo
    final filteredItems = scanState.items.where((item) {
      if (_selectedFilter == MediaFilter.images) {
        return item.type == MediaType.image;
      }
      if (_selectedFilter == MediaFilter.videos) {
        return item.type == MediaType.video;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Header
                  const ScreenHeader(
                    title: 'Escanear sitio',
                    subtitle:
                        'Ingresa una URL para descubrir imágenes y videos extraíbles',
                  ),
                  const SizedBox(height: 24),

                  // 2. Barra de entrada de URL y botón Search
                  UrlInputBar(
                    controller: _urlController,
                    onSearch: _onSearch,
                    isLoading: scanState.status == ScanStatus.loading,
                  ),
                  const SizedBox(height: 24),

                  // 3. Banner de Error (si ocurre)
                  if (scanState.status == ScanStatus.error) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        scanState.errorMessage ??
                            'Ocurrió un error al escanear',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 4. Barra de Filtros (visible tras un escaneo exitoso)
                  if (scanState.status == ScanStatus.success &&
                      scanState.items.isNotEmpty) ...[
                    FilterChipsBar(
                      totalCount: scanState.items.length,
                      imagesCount: imagesCount,
                      videosCount: videosCount,
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 5. Mensaje si no se encontraron medios
                  if (scanState.status == ScanStatus.success &&
                      scanState.items.isEmpty) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Text(
                          'No se encontraron medios extraíbles en esta URL.',
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ]),
              ),
            ),

            // 6. Grid dinámico con los resultados reales del Scraper
            if (scanState.status == ScanStatus.success &&
                filteredItems.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = filteredItems[index];
                    final isSelected = selectedItems.any(
                      (e) => e.id == item.id,
                    );

                    return MediaCard(
                      item: item,
                      isSelected: isSelected,
                      onSelectedChanged: (selected) {
                        ref
                            .read(selectedMediaProvider.notifier)
                            .toggleSelection(item);
                      },
                    );
                  }, childCount: filteredItems.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      bottomNavigationBar: SelectionBottomBar(
        selectedCount: selectedItems.length,
        onDownload: () {
          for (final item in selectedItems) {
            ref.read(downloadProvider.notifier).download(item);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Iniciando descarga de ${selectedItems.length} elemento(s)',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
