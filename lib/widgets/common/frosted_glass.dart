import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Monochrome Noir frosted surface container with crisp 1px hairline border.
class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Border? border;
  final double? width;
  final double? height;
  final List<BoxShadow>? shadows;

  const FrostedGlass({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.borderRadius = 18.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.backgroundGradient,
    this.border,
    this.width,
    this.height,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.glassSurface,
              gradient: backgroundGradient,
              borderRadius: radius,
              border: border ??
                  Border.all(
                    color: AppColors.glassBorder,
                    width: 1.0,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
