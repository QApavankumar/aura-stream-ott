import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Minimal Cinema Noir wordmark & geometric aperture badge.
class AuraLogo extends StatefulWidget {
  final double size;
  final bool showTagline;
  final bool isAnimated;

  const AuraLogo({
    super.key,
    this.size = 100,
    this.showTagline = true,
    this.isAnimated = true,
  });

  @override
  State<AuraLogo> createState() => _AuraLogoState();
}

class _AuraLogoState extends State<AuraLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _pulse = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = widget.size;
    final mark = Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(badgeSize * 0.28),
        border: Border.all(
          color: AppColors.glassBorderBright,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: badgeSize * 0.64,
            height: badgeSize * 0.64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
          ),
          Icon(
            Icons.play_arrow_rounded,
            size: badgeSize * 0.46,
            color: AppColors.noirWhite,
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isAnimated)
          ScaleTransition(scale: _pulse, child: mark)
        else
          mark,
        if (widget.showTagline) ...[
          const SizedBox(height: 18),
          Text(
            'AURA',
            style: AppTypography.brandLogo(
              fontSize: (badgeSize * 0.28).clamp(20, 32),
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'CINEMA NOIR • 4K HDR',
            style: AppTypography.badge.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 2.2,
              fontSize: 10.5,
            ),
          ),
        ],
      ],
    );
  }
}
