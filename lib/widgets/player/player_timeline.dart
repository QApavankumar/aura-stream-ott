import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aura_stream/theme/player_theme.dart';

/// Futuristic Video Timeline Scrubber with Live Timestamp and Seeking
class PlayerTimeline extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<bool>? onSeekingChanged;

  const PlayerTimeline({
    super.key,
    required this.position,
    required this.duration,
    this.buffered = Duration.zero,
    required this.onSeek,
    this.onSeekingChanged,
  });

  @override
  State<PlayerTimeline> createState() => _PlayerTimelineState();
}

class _PlayerTimelineState extends State<PlayerTimeline> {
  bool _isDragging = false;
  double _dragFraction = 0.0;

  String _formatDuration(Duration d) {
    if (d.isNegative) return '00:00';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _handleSeek(double fraction) {
    final clamped = fraction.clamp(0.0, 1.0);
    final targetMs = (widget.duration.inMilliseconds * clamped).round();
    widget.onSeek(Duration(milliseconds: targetMs));
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.duration.inMilliseconds > 0
        ? widget.duration.inMilliseconds.toDouble()
        : 1.0;
    final currentFraction = _isDragging
        ? _dragFraction
        : (widget.position.inMilliseconds / totalMs).clamp(0.0, 1.0);

    final bufferedFraction =
        (widget.buffered.inMilliseconds / totalMs).clamp(0.0, 1.0);

    final displayTime = _isDragging
        ? Duration(milliseconds: (_dragFraction * totalMs).round())
        : widget.position;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Interactive Scrubber Bar
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) {
                setState(() {
                  _isDragging = true;
                  _dragFraction =
                      (details.localPosition.dx / barWidth).clamp(0.0, 1.0);
                });
                widget.onSeekingChanged?.call(true);
              },
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragFraction =
                      (details.localPosition.dx / barWidth).clamp(0.0, 1.0);
                });
              },
              onHorizontalDragEnd: (details) {
                _handleSeek(_dragFraction);
                setState(() {
                  _isDragging = false;
                });
                widget.onSeekingChanged?.call(false);
              },
              onHorizontalDragCancel: () {
                setState(() {
                  _isDragging = false;
                });
                widget.onSeekingChanged?.call(false);
              },
              onTapDown: (details) {
                final fraction =
                    (details.localPosition.dx / barWidth).clamp(0.0, 1.0);
                setState(() {
                  _dragFraction = fraction;
                });
                _handleSeek(fraction);
              },
              child: Container(
                height: 36,
                alignment: Alignment.center,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background track
                    Container(
                      height: 5,
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Buffered progress track
                    Container(
                      height: 5,
                      width: barWidth * bufferedFraction,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.38),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Crisp White Noir Played Scrubber Bar (Panel 4)
                    Container(
                      height: 3.5,
                      width: barWidth * currentFraction,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Minimal White Scrubber Thumb
                    Positioned(
                      left: (barWidth * currentFraction) - 7,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Floating seek timecode bubble when dragging
                    if (_isDragging)
                      Positioned(
                        left: ((barWidth * currentFraction) - 34)
                            .clamp(0.0, barWidth - 68),
                        top: -34,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _formatDuration(displayTime),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // Timestamps and Stream Metadata Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Current timestamp
            Row(
              children: [
                Text(
                  _formatDuration(displayTime),
                  style: const TextStyle(
                    color: PlayerTheme.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  ' / ${_formatDuration(widget.duration)}',
                  style: const TextStyle(
                    color: PlayerTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            // Live HLS Stream Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: PlayerTheme.cyanAccent.withOpacity(0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: PlayerTheme.emeraldAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: PlayerTheme.emeraldAccent.withOpacity(0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'HLS LIVE STREAM',
                    style: TextStyle(
                      color: PlayerTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

