import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Marca compartida: icono circular + "MediaDownloader".
/// Estilo fijo a propósito: todas las pantallas se ven igual.
class HeaderBrandRow extends StatelessWidget {
  const HeaderBrandRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          style: AppTypography.headlineMedium.copyWith(
            fontSize: 20,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? subtitleIcon;
  final Widget? trailing;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleIcon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HeaderBrandRow(),
        const SizedBox(height: 24),
        if (trailing != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _title()),
              const SizedBox(width: 8),
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
              Expanded(
                child: Text(
                  subtitle!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral,
                  ),
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
