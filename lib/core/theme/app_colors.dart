import 'package:flutter/material.dart';

/// Minimal Cinema Noir color tokens (Apple TV+ / Criterion Obsidian).
/// Keeps UI chrome monochrome while preserving semantic status indicators
/// and letting full-color cinema & profile imagery shine.
class AppColors {
  AppColors._();

  // Deep Obsidian Backgrounds
  static const Color background = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF111114);
  static const Color cardSurface = Color(0xFF18181B);
  static const Color surfaceOverlay = Color(0xD9000000);

  // Noir Monochrome Accents
  static const Color noirWhite = Color(0xFFFFFFFF);
  static const Color noirSilver = Color(0xFFE4E4E7);
  static const Color noirPillFill = Color(0x1AFFFFFF);

  // Legacy accent aliases mapped to Noir Monochrome so existing callers
  // render cleanly in Obsidian without neon glow clutter.
  static const Color cyanPrimary = noirWhite;
  static const Color cyanNeon = noirSilver;
  static const Color cyanElectric = Color(0xFFD4D4D8);
  static const Color cyanDim = Color(0xFF27272A);

  static const Color neonPurple = Color(0xFFA1A1AA);
  static const Color neonViolet = Color(0xFF71717A);
  static const Color neonMagenta = noirSilver;
  static const Color neonBlue = noirSilver;

  // Semantic Indicators (Live Red, Supabase Emerald, Kids Amber)
  static const Color liveRed = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color kidsModeAmber = Color(0xFFF59E0B);
  static const Color kidsModeOrange = Color(0xFFEA580C);

  // Typography Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // Frosted Hairline Borders & Glass Surfaces
  static const Color glassSurface = Color(0xCC111114);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassBorderBright = Color(0x40FFFFFF);
  static const Color glassBorderCyan = Color(0x4DFFFFFF);

  // Gradients
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFE4E4E7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient obsidianFadeGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000), Color(0xFF000000)],
    stops: [0.0, 0.65, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient kidsProfileGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
