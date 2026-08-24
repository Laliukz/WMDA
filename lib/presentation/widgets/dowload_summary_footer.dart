import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class DownloadSummaryFooter extends StatelessWidget {
  final String totalSize;
  final VoidCallback onDownloadAll;
  final bool isDownloading;

  const DownloadSummaryFooter({
    super.key,
    required this.totalSize,
    required this.onDownloadAll,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Fila Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Size:',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.dark,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                totalSize,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          //Boton de descargar todo
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isDownloading ? null : onDownloadAll,
              icon: isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
              label: Text(
                isDownloading ? 'Downloading...' : 'Download All',
                style: AppTypography.button,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
