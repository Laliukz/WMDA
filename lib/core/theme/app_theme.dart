import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.tertiary,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.dark,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.headlineLarge,
        displayMedium: AppTypography.headlineMedium,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        labelMedium: AppTypography.label,
        labelSmall: AppTypography.badge,
      ),
    );
  }
}
