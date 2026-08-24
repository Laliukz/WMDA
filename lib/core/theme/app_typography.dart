import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  // Headline: DM Serif Display
  static TextStyle headlineLarge = GoogleFonts.dmSerifDisplay(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );

  static TextStyle headlineMedium = GoogleFonts.dmSerifDisplay(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );

  // Body: Hanken Grotesk
  static TextStyle bodyLarge = GoogleFonts.hankenGrotesk(
    fontSize: 16,
    color: AppColors.dark,
  );

  static TextStyle bodyMedium = GoogleFonts.hankenGrotesk(
    fontSize: 14,
    color: AppColors.neutral,
  );

  // Label: JetBrains Mono
  static TextStyle label = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral,
  );

  static TextStyle badge = GoogleFonts.jetBrainsMono(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static TextStyle labelLarge = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral,
  );

  static TextStyle button = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );

  static TextStyle bodySmall = GoogleFonts.hankenGrotesk(
    fontSize: 13,
    color: AppColors.neutral,
  );

  static TextStyle headlineSmall = GoogleFonts.dmSerifDisplay(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );
}
