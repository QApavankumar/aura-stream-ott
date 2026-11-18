import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.linear,
      ),
    );

    if (widget.isAnimated) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = widget.isAnimated ? _pulseAnimation.value : 1.0;
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Ambient Glow Aura
                  Container(
                    width: widget.size * scale,
                    height: widget.size * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyanPrimary.withOpacity(0.35),
                          blurRadius: widget.size * 0.45,
                          spreadRadius: widget.size * 0.1,
                        ),
                        BoxShadow(
                          color: AppColors.neonPurple.withOpacity(0.25),
                          blurRadius: widget.size * 0.6,
                          spreadRadius: widget.size * 0.05,
                        ),
                      ],
                    ),
                  ),

                  // Orbital Ring (Custom Painted)
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _AuraOrbitPainter(
                      glowFactor: scale,
                      rotation: widget.isAnimated ? _rotationAnimation.value : 0.0,
                    ),
                  ),

                  // Center Cyan Emblem
                  Container(
                    width: widget.size * 0.52,
                    height: widget.size * 0.52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F2FE), Color(0xFF0072FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyanPrimary.withOpacity(0.8),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: widget.size * 0.32,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        // Logo Text: AURA STREAM
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AURA',
              style: AppTypography.brandLogo(
                fontSize: widget.size * 0.32,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'STREAM',
              style: AppTypography.brandLogo(
                fontSize: widget.size * 0.32,
                letterSpacing: 4.0,
              ).copyWith(
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: AppColors.cyanPrimary.withOpacity(0.7),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.showTagline) ...[
          const SizedBox(height: 8),
          Text(
            'FUTURE OF ENTERTAINMENT • 4K HDR',
            style: AppTypography.badge.copyWith(
              letterSpacing: 2.5,
              color: AppColors.cyanPrimary.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}

class _AuraOrbitPainter extends CustomPainter {
  final double glowFactor;
  final double rotation;

  _AuraOrbitPainter({required this.glowFactor, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    // Glowing Neon Cyan Arc
    final paint1 = Paint()
      ..color = AppColors.cyanPrimary.withOpacity(0.75 * glowFactor.clamp(0.5, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);

    canvas.drawCircle(center, radius, paint1);

    // Dynamic Accent Dash
    final paintDash = Paint()
      ..color = AppColors.neonPurple.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 1.1),
      rotation,
      math.pi / 2.5,
      false,
      paintDash,
    );

    // Opposing Cyan Accent Dash
    final paintDash2 = Paint()
      ..color = AppColors.cyanNeon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 1.1),
      rotation + math.pi,
      math.pi / 3,
      false,
      paintDash2,
    );
  }

  @override
  bool shouldRepaint(_AuraOrbitPainter oldDelegate) => true;
}
