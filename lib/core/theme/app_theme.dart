import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette (DESIGN.md "Luminous Finance") ──────────────────────────────
  static const Color background          = Color(0xFF0B1326);
  static const Color surface             = Color(0xFF121826);
  static const Color surfaceContainer    = Color(0xFF171F33);
  static const Color surfaceHigh         = Color(0xFF222A3D);
  static const Color surfaceHighest      = Color(0xFF2D3449);

  static const Color primaryNeon         = Color(0xFF4EDEA3); // Glowing Emerald
  static const Color primaryContainer    = Color(0xFF10B981);
  static const Color secondaryNeon       = Color(0xFFFFB3AD); // Neon Crimson (expenses)
  static const Color tertiaryNeon        = Color(0xFFFFB95F); // Soft Amber (pending)

  static const Color textPrimary         = Color(0xFFDAE2FD);
  static const Color textSecondary       = Color(0xFFBBCABF);
  static const Color textMuted           = Color(0xFF86948A);

  static const Color success             = Color(0xFF4EDEA3);
  static const Color warning             = Color(0xFFFFB95F);
  static const Color danger              = Color(0xFFFFB3AD);
  static const Color dangerBright        = Color(0xFFEF4444);
  static const Color outline             = Color(0xFF3C4A42);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNeon, Color(0xFF005236)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFF93000A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFFFB95F), Color(0xFF653E00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFBD00FF), Color(0xFF3D0066)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2D40), Color(0xFF0B1326)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Wallet type → gradient ───────────────────────────────────────────────
  static LinearGradient walletGradient(String type) {
    switch (type) {
      case 'BANK':     return primaryGradient;
      case 'BUSINESS': return purpleGradient;
      case 'DIGITAL':  return amberGradient;
      default:         return cardGradient;
    }
  }

  // ── Glassmorphism ────────────────────────────────────────────────────────
  static BoxDecoration glassDecoration({
    double radius = 16.0,
    Color borderColor = Colors.white12,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1.0),
      boxShadow: [
        if (glowColor != null)
          BoxShadow(color: glowColor.withOpacity(0.25), blurRadius: 24, spreadRadius: 0),
        BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
      ],
    );
  }

  static BoxDecoration surfaceDecoration({double radius = 16.0}) {
    return BoxDecoration(
      color: surfaceContainer,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
    );
  }

  // ── ThemeData ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primaryNeon,
      cardColor: surfaceContainer,
      colorScheme: const ColorScheme.dark(
        primary:    primaryNeon,
        secondary:  secondaryNeon,
        tertiary:   tertiaryNeon,
        surface:    surface,
        error:      dangerBright,
        onPrimary:  Color(0xFF003824),
        onSecondary: Color(0xFF68000A),
        onSurface:  textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor:    textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: surfaceContainer,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryNeon,
        foregroundColor: Color(0xFF003824),
        elevation: 6,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        selectedColor: primaryNeon.withOpacity(0.2),
        side: const BorderSide(color: Colors.white12),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHighest,
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryNeon, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x14FFFFFF), thickness: 1),
      tabBarTheme: TabBarThemeData(
        indicator: const UnderlineTabIndicator(borderSide: BorderSide(color: primaryNeon, width: 2)),
        labelColor: primaryNeon,
        unselectedLabelColor: textMuted,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
      ),
    );
  }
}
