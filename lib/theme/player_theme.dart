import 'dart:ui';
import 'package:flutter/material.dart';

/// Futuristic Cinematic OTT Theme Tokens
/// Inspired by Aura Stream / Cineflix 2.0 Design System
class PlayerTheme {
  // Canvas & Background Surfaces
  static const Color bgDeep = Color(0xFF06070A);
  static const Color bgCanvas = Color(0xFF090A0F);
  static const Color bgGlass = Color(0xCC0E1322);
  static const Color bgGlassDark = Color(0xE6080A10);
  static const Color bgCard = Color(0xFF11141F);
  static const Color bgCardElevated = Color(0xFF181D2C);

  // Luminous Brand Accents
  static const Color cyanAccent = Color(0xFF00F0FF);
  static const Color cyanGlow = Color(0x6600F0FF);
  static const Color cyanSubtle = Color(0x1A00F0FF);

  static const Color purpleAccent = Color(0xFF8A2BE2);
  static const Color purpleGlow = Color(0x668A2BE2);
  static const Color purpleSubtle = Color(0x268A2BE2);

  static const Color rubyAccent = Color(0xFFFF1344);
  static const Color rubyGlow = Color(0x66FF1344);

  static const Color goldAccent = Color(0xFFFFC837);
  static const Color emeraldAccent = Color(0xFF00E676);

  // Typography Colors
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9BA1B5);
  static const Color textDim = Color(0xFF5C6275);

  // Borders & Glass
  static const Color borderGlass = Color(0x1FFFFFFF);
  static const Color borderGlassHover = Color(0x40FFFFFF);
  static const Color borderCyan = Color(0x8000F0FF);

  // Glassmorphic BoxDecoration Helper
  static BoxDecoration glassDecoration({
    Color color = bgGlass,
    Color borderColor = borderGlass,
    double borderRadius = 16,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.0),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
    );
  }

  // Neon Glow BoxDecoration Helper
  static BoxDecoration neonPillDecoration({
    bool isSelected = false,
    Color accentColor = cyanAccent,
  }) {
    if (isSelected) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.28),
            purpleAccent.withOpacity(0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.35),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      );
    }
    return BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderGlass, width: 1.0),
    );
  }
}

