import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? subtitleIcon;
  final Widget? trailing;
  final double spacing;
  final Color accentColor;
  final IconData icon;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleIcon,
    this.trailing,
    this.spacing = 24,
    this.accentColor = AppColors.primary,
    this.icon = Icons.arrow_downward_rounded,
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
                border: Border.all(color: accentColor, width: 1.5),
              ),
              child: Icon(icon, size: 16, color: accentColor),
            ),
            const SizedBox(width: 8),
            Text(
              'MediaDownloader',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 20,
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        if (trailing != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _title(),
              trailing!,
            ],
          )
        else
          _title(),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (subtitleIcon != null) ...[
                Icon(subtitleIcon, size: 18, color: AppColors.neutral),
                const SizedBox(width: 6),
              ],
              Text(
                subtitle!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _title() => Text(
        title,
        style: AppTypography.headlineLarge.copyWith(
          color: AppColors.dark,
          fontWeight: FontWeight.bold,
        ),
      );
}
