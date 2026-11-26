import 'package:flutter/material.dart';

/// Monochrome Cinema Noir tokens for the 4K video player HUD.
class PlayerTheme {
  PlayerTheme._();

  static const Color bgDeep = Color(0xFF000000);
  static const Color bgGlassDark = Color(0xD9111114);
  static const Color borderGlass = Color(0x26FFFFFF);

  static const Color cyanAccent = Color(0xFFFFFFFF);
  static const Color purpleAccent = Color(0xFFA1A1AA);
  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color rubyAccent = Color(0xFFEF4444);

  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textDim = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  static BoxDecoration glassDecoration({
    double borderRadius = 16,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? bgGlassDark,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? borderGlass, width: 1),
    );
  }

  static BoxDecoration neonPillDecoration({
    Color color = cyanAccent,
    Color? accentColor,
    bool isSelected = true,
    double borderRadius = 999,
  }) {
    final effectiveColor = accentColor ?? color;
    return BoxDecoration(
      color: isSelected
          ? effectiveColor.withValues(alpha: 0.16)
          : const Color(0x0DFFFFFF),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isSelected
            ? effectiveColor.withValues(alpha: 0.7)
            : borderGlass,
        width: isSelected ? 1.2 : 1.0,
      ),
    );
  }
}
