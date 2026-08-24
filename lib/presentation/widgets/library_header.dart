import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'filter_chips_bar.dart';

class LibraryHeader extends StatelessWidget {
  final MediaFilter selectedFilter;
  final ValueChanged<MediaFilter> onFilterChanged;

  const LibraryHeader({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_downward,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'MediaDownloader',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 20,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Library',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.dark,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: selectedFilter == MediaFilter.all,
                  onTap: () => onFilterChanged(MediaFilter.all),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Images',
                  isSelected: selectedFilter == MediaFilter.images,
                  onTap: () => onFilterChanged(MediaFilter.images),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Videos',
                  isSelected: selectedFilter == MediaFilter.videos,
                  onTap: () => onFilterChanged(MediaFilter.videos),
                ),
              ],
            ),
          ],
        ),
      ],
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
