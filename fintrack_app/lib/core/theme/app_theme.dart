import 'package:flutter/material.dart';

class AppColors {
  // Luminous Finance Deep Abyss Palette
  static const Color background = Color(0xFF0B1326); // True Black/Midnight
  static const Color surfaceContainerLowest = Color(0xFF060E20);
  static const Color surfaceContainerLow = Color(0xFF131B2E);
  static const Color surfaceContainer = Color(0xFF171F33);
  static const Color surfaceContainerHigh = Color(0xFF222A3D);
  static const Color surfaceContainerHighest = Color(0xFF2D3449);
  
  static const Color primary = Color(0xFF4EDEA3); // Emerald
  static const Color primaryContainer = Color(0xFF10B981);
  static const Color onPrimary = Color(0xFF003824);
  
  static const Color secondary = Color(0xFFFFB3AD);
  static const Color error = Color(0xFFFFB4AB); // Crimson
  static const Color warning = Color(0xFFF59E0B); // Amber
  
  static const Color onSurface = Color(0xFFDAE2FD);
  static const Color onSurfaceVariant = Color(0xFFBBCABF);
  static const Color outline = Color(0xFF86948A);
  
  // Glassmorphism helper
  static Color glassSurface = const Color(0xFF1E293B).withOpacity(0.5);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        background: AppColors.background,
        surface: AppColors.surfaceContainer,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        onSurface: AppColors.onSurface,
      ),
      fontFamily: 'Inter',
      useMaterial3: true,
      cardTheme: CardTheme(
        color: AppColors.glassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // rounded-xl 1.5rem
          side: const BorderSide(color: AppColors.outline, width: 0.5),
        ),
      ),
    );
  }
}
