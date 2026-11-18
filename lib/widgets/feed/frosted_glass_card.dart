import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aura_stream/theme/aura_theme.dart';

/// Reusable frosted glass card utilizing Flutter's [BackdropFilter].
/// Provides smooth blur, specular border highlights, and optional neon glow.
class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final List<BoxShadow>? glowShadows;
  final Gradient? borderGradient;

  const FrostedGlassCard({
    super.key,
    required this.child,
    this.blurSigma = 14.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.glowShadows,
    this.borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(18);
    final effectiveBorderColor = borderColor ?? AuraTheme.glassBorder;
    final effectiveBgColor = backgroundColor ?? Colors.white.withValues(alpha: 0.07);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: effectiveRadius,
        border: borderGradient == null
            ? Border.all(color: effectiveBorderColor, width: borderWidth)
            : null,
      ),
      child: child,
    );

    // If border gradient is supplied, wrap in custom gradient border
    if (borderGradient != null) {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          gradient: borderGradient,
        ),
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: effectiveRadius,
          ),
          child: child,
        ),
      );
    }

    Widget glass = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: glowShadows,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          splashColor: AuraTheme.electricCyan.withValues(alpha: 0.15),
          highlightColor: AuraTheme.neonViolet.withValues(alpha: 0.1),
          child: glass,
        ),
      );
    }

    return glass;
  }
}
