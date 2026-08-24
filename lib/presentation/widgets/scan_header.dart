import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ScanHeader extends StatelessWidget {
  const ScanHeader({super.key});

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
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text('Scan Website', style: AppTypography.headlineLarge),
        const SizedBox(height: 8),
        Text('Enter a URL to dicover extractable images and videos'),
      ],
    );
  }
}
