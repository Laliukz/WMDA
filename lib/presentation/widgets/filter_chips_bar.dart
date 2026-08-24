import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum MediaFilter { all, images, videos }

class FilterChipsBar extends StatelessWidget {
  final int totalCount;
  final int imagesCount;
  final int videosCount;
  final MediaFilter selectedFilter;
  final ValueChanged<MediaFilter> onFilterChanged;

  const FilterChipsBar({
    super.key,
    required this.totalCount,
    required this.imagesCount,
    required this.videosCount,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 1. Contador de Resultados a la izquierda
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RESULTS',
                style: AppTypography.label.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$totalCount items\nfound',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        // 2. Chips de filtro a la derecha
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildChip('ALL', MediaFilter.all),
            const SizedBox(width: 6),
            _buildChip('Images\n($imagesCount)', MediaFilter.images),
            const SizedBox(width: 6),
            _buildChip('Videos\n($videosCount)', MediaFilter.videos),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, MediaFilter filter) {
    final isSelected = selectedFilter == filter;

    return InkWell(
      onTap: () => onFilterChanged(filter),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.border : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.dark.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.label.copyWith(
            fontSize: 11,
            color: isSelected ? AppColors.dark : AppColors.neutral,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
