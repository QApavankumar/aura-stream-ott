import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Monochrome Cinema Noir action pill:
/// - Primary (`isSecondary: false`): Solid Obsidian-Contrast White `#FFFFFF` pill with `#000000` text.
/// - Secondary (`isSecondary: true`): Elevated Dark `#111114` pill with hairline `1px` white border & `#FFFFFF` text.
class AuraGlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;
  final Gradient? gradient;
  final Color glowColor;
  final bool isSecondary;

  const AuraGlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 50,
    this.width,
    this.gradient,
    this.glowColor = AppColors.noirWhite,
    this.isSecondary = false,
  });

  @override
  State<AuraGlowButton> createState() => _AuraGlowButtonState();
}

class _AuraGlowButtonState extends State<AuraGlowButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;
    final foregroundColor =
        widget.isSecondary ? AppColors.textPrimary : AppColors.background;

    final backgroundColor = widget.isSecondary
        ? (_isHovered ? const Color(0xFF1E1E24) : AppColors.surfaceDark)
        : (_isHovered ? const Color(0xFFE4E4E7) : AppColors.noirWhite);

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: disabled ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.975 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: disabled
                  ? (widget.isSecondary
                      ? AppColors.surfaceDark.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.45))
                  : backgroundColor,
              borderRadius: BorderRadius.circular(999),
              border: widget.isSecondary
                  ? Border.all(
                      color: _isHovered
                          ? AppColors.glassBorderBright
                          : AppColors.glassBorder,
                      width: 1.0,
                    )
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(foregroundColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 19, color: foregroundColor),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.button.copyWith(
                              color: foregroundColor,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
