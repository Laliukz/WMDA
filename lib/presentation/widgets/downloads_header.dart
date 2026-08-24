import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class DownloadsHeader extends StatelessWidget {
  final int itemCount;
  const DownloadsHeader({super.key, required this.itemCount});

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
                Icons.arrow_downward_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'MediaDownloader',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Ready to Download',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: AppColors.neutral,
            ),
            const SizedBox(width: 6),
            Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'} selected from Scan',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
