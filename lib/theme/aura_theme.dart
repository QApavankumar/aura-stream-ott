import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The core Aura Stream design system theme aligned with Member 3 specs.
///
/// Palette:
/// - Dark Obsidian Background: #08090C (Deep streaming canvas)
/// - Surface Dark:              #10131A (Container & sheet surfaces)
/// - Card Dark:                 #161B26 (Elevated cards & tiles)
/// - Neon Cyan Accent:          #00F2FE (Primary neon glow, progress bars, active states)
/// - Purple Aura Secondary:     #9D4EDD (Secondary neon accent, badges, gradient blends)
class AuraTheme {
  AuraTheme._();

  // Primary Brand Colors (Member 3 Canonical Specs)
  static const Color darkObsidian = Color(0xFF08090C);
  static const Color surfaceDark  = Color(0xFF10131A);
  static const Color cardDark     = Color(0xFF161B26);
  static const Color neonCyan     = Color(0xFF00F2FE);
  static const Color purpleAura   = Color(0xFF9D4EDD);

  // Backward-compatibility aliases for Member 2 code
  static const Color midnightNavy = darkObsidian;
  static const Color electricCyan = neonCyan;
  static const Color neonViolet   = purpleAura;

  // Neutral Tints & Opacities
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0AEC0);
  static const Color textMuted     = Color(0xFF718096);
  static const Color glassBorder   = Color(0x26FFFFFF); // 15% white
  static const Color glassFill     = Color(0x14FFFFFF); // 8% white
  static const Color dividerColor  = Color(0x1A00F2FE); // 10% neon cyan

  // Gradients
  static const LinearGradient auraCyanVioletGradient = LinearGradient(
    colors: [neonCyan, purpleAura],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroFadeGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x8008090C),
      darkObsidian,
    ],
    stops: [0.30, 0.70, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassHighlightGradient = LinearGradient(
    colors: [
      Color(0x33FFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Box Shadows / Neon Glow Effects
  static List<BoxShadow> cyanGlow({double blur = 18, double spread = 0}) => [
        BoxShadow(
          color: neonCyan.withValues(alpha: 0.35),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];

  static List<BoxShadow> violetGlow({double blur = 16, double spread = 0}) => [
        BoxShadow(
          color: purpleAura.withValues(alpha: 0.35),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];

  /// Material ThemeData configuration using GoogleFonts Orbitron & Outfit
  static ThemeData get darkTheme {
    final textTheme = TextTheme(
      headlineLarge: AppTypography.displayLarge,
      headlineMedium: AppTypography.headlineMedium,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkObsidian,
      canvasColor: darkObsidian,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: purpleAura,
        surface: surfaceDark,
        surfaceContainerHighest: cardDark,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppTypography.displayLogo,
      ),
      textTheme: textTheme,
    );
  }
}

/// Standardized Typography using Orbitron for headings/ranks and Outfit for body/UI
class AppTypography {
  AppTypography._();

  static TextStyle get displayLogo => GoogleFonts.orbitron(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
      );

  static TextStyle get displayLarge => GoogleFonts.orbitron(
        color: AuraTheme.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => GoogleFonts.orbitron(
        color: AuraTheme.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static TextStyle get titleLarge => GoogleFonts.orbitron(
        color: AuraTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  static TextStyle get titleMedium => GoogleFonts.outfit(
        color: AuraTheme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.outfit(
        color: AuraTheme.textPrimary,
        fontSize: 14,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
        color: AuraTheme.textSecondary,
        fontSize: 13,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        color: AuraTheme.textMuted,
        fontSize: 11,
        letterSpacing: 0.3,
      );

  static TextStyle get buttonText => GoogleFonts.outfit(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      );

  static TextStyle get rankNumber => GoogleFonts.orbitron(
        fontSize: 88,
        fontWeight: FontWeight.w900,
        letterSpacing: -6,
      );
}
