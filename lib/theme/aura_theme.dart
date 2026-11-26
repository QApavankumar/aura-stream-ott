import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Minimal Cinema Noir theme tokens & card helpers for feed components.
class AuraTheme {
  AuraTheme._();

  // Core Obsidian Palette
  static const Color darkObsidian = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF111114);
  static const Color cardDark = Color(0xFF18181B);

  // Monochrome CTA & Subtle Accent Tokens (preserving legacy getter names)
  static const Color electricCyan = Color(0xFFFFFFFF);
  static const Color neonCyan = Color(0xFFE4E4E7);
  static const Color neonViolet = Color(0xFFA1A1AA);
  static const Color purpleAura = Color(0xFF27272A);

  static List<BoxShadow> cyanGlow({double blur = 14, double opacity = 0.25}) =>
      [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: blur,
        ),
      ];

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // Glass & Borders
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassSurface = Color(0xCC111114);

  // Subtle Silver-Obsidian Gradient (replaces neon cyan-violet)
  static const LinearGradient auraCyanVioletGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFD4D4D8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// Editorial typography helpers used by feed cards.
class AppTypography {
  AppTypography._();

  static TextStyle get displayLogo => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 4.5,
        color: AuraTheme.textPrimary,
      );

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9,
        height: 1.1,
        color: AuraTheme.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.35,
        color: AuraTheme.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AuraTheme.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AuraTheme.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AuraTheme.textMuted,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AuraTheme.darkObsidian,
      );

  static TextStyle get rankNumber => GoogleFonts.inter(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        height: 0.9,
        letterSpacing: -2.0,
        color: const Color(0xD9FFFFFF),
      );
}
