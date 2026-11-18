import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated neon audio waveform visualizer matching the live sports cards
/// in the Aura Stream screenshot reference.
class SoundwaveVisualizer extends StatefulWidget {
  final int barCount;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;

  const SoundwaveVisualizer({
    super.key,
    this.barCount = 36,
    this.height = 24,
    this.primaryColor = const Color(0xFF00F2FE),
    this.secondaryColor = const Color(0xFF00E676),
  });

  @override
  State<SoundwaveVisualizer> createState() => _SoundwaveVisualizerState();
}

class _SoundwaveVisualizerState extends State<SoundwaveVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _SoundwavePainter(
            progress: _controller.value,
            barCount: widget.barCount,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        );
      },
    );
  }
}

class _SoundwavePainter extends CustomPainter {
  final double progress;
  final int barCount;
  final Color primaryColor;
  final Color secondaryColor;

  _SoundwavePainter({
    required this.progress,
    required this.barCount,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double barWidth = (size.width / (barCount * 1.6)).clamp(1.5, 4.0);
    final double spacing = (size.width - (barCount * barWidth)) / (barCount - 1);

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final double normalizedIdx = i / barCount;
      // Synthesize rhythmic soundwave motion with multiple frequency harmonics
      final double wave1 = math.sin((normalizedIdx * 4 * math.pi) + (progress * 2 * math.pi));
      final double wave2 = math.cos((normalizedIdx * 8 * math.pi) - (progress * 4 * math.pi));
      final double wave3 = math.sin((normalizedIdx * 2 * math.pi) + (progress * 6 * math.pi));

      // Calculate normalized height between 0.15 and 0.95
      double heightFactor = (0.35 + 0.35 * wave1 + 0.2 * wave2 + 0.1 * wave3).abs();
      heightFactor = heightFactor.clamp(0.12, 1.0);

      final double barHeight = size.height * heightFactor;
      final double x = i * (barWidth + spacing);
      final double y = size.height - barHeight;

      // Color interpolation: gradient from secondary (green/cyan) to primary (cyan)
      final Color color = Color.lerp(
        secondaryColor,
        primaryColor,
        (normalizedIdx + progress).remainder(1.0),
      )!;

      paint.color = color;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SoundwavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
