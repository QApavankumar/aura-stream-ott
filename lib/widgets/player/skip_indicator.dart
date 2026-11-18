import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aura_stream/theme/player_theme.dart';

/// Animated visual ripple indicator for -10s rewind or +10s forward skip
class SkipIndicatorOverlay extends StatefulWidget {
  final bool isForward;
  final VoidCallback onDismissed;

  const SkipIndicatorOverlay({
    super.key,
    required this.isForward,
    required this.onDismissed,
  });

  @override
  State<SkipIndicatorOverlay> createState() => _SkipIndicatorOverlayState();
}

class _SkipIndicatorOverlayState extends State<SkipIndicatorOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _rippleAnimation = Tween<double>(begin: 0.5, end: 1.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.85, curve: Curves.easeOutQuad),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) => widget.onDismissed());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        widget.isForward ? PlayerTheme.cyanAccent : PlayerTheme.purpleAccent;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Expanding glowing ripple circle
                Transform.scale(
                  scale: _rippleAnimation.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withOpacity(
                            (1.0 - _controller.value).clamp(0.0, 0.8)),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(
                              (0.5 * (1.0 - _controller.value))
                                  .clamp(0.0, 0.5)),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // Frosted Glass Core
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withOpacity(0.7),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.35),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isForward
                                ? Icons.fast_forward_rounded
                                : Icons.fast_rewind_rounded,
                            color: accentColor,
                            size: 30,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.isForward ? '+10s' : '-10s',
                            style: TextStyle(
                              color: PlayerTheme.textMain,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              shadows: [
                                Shadow(
                                  color: accentColor,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

