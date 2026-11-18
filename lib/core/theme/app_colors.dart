import 'package:flutter/material.dart';

class AppColors {
  // Deep Backgrounds
  static const Color background = Color(0xFF08090C);
  static const Color surfaceDark = Color(0xFF0F131D);
  static const Color cardSurface = Color(0xFF151B27);
  static const Color surfaceOverlay = Color(0xCC090C14);

  // Neon Cyan Accents (Signature "Aura Stream" Glow)
  static const Color cyanPrimary = Color(0xFF00F2FE);
  static const Color cyanNeon = Color(0xFF00E5FF);
  static const Color cyanElectric = Color(0xFF4FACFE);
  static const Color cyanDim = Color(0xFF006875);

  // Secondary Neon Accents
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color neonViolet = Color(0xFF7B2CBF);
  static const Color neonMagenta = Color(0xFFE040FB);
  static const Color neonBlue = Color(0xFF2979FF);

  // Kids Mode Accents
  static const Color kidsModeAmber = Color(0xFFFF9E00);
  static const Color kidsModeYellow = Color(0xFFFFD166);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9EA7B8);
  static const Color textMuted = Color(0xFF5D6678);

  // Frosted Glass & Borders
  static const Color glassSurface = Color(0x18FFFFFF);
  static const Color glassSurfaceStrong = Color(0x30FFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassBorderCyan = Color(0x6600F2FE);
  static const Color glassDockBackground = Color(0xD90E131F);

  // Status & Badges
  static const Color liveRed = Color(0xFFFF334B);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF1744);

  // Signature Gradients
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [cyanPrimary, cyanElectric],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auraBrandGradient = LinearGradient(
    colors: [cyanPrimary, neonPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient glassDockGradient = LinearGradient(
    colors: [
      Color(0xEE111726),
      Color(0xCC0B0F1A),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroCardOverlay = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x6608090C),
      Color(0xF508090C),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
