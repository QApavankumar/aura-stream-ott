import 'package:flutter/material.dart';
import 'package:aura_stream/models/subtitle_data.dart';
import 'package:aura_stream/theme/player_theme.dart';

/// Cinematic subtitle overlay that renders timed subtitle text at the bottom
/// of the video player. Smoothly fades in/out as cues change.
class SubtitleOverlay extends StatelessWidget {
  /// The currently active subtitle cue list (empty = subtitles off).
  final List<SubtitleCue> cues;

  /// Current playback position — used to find the active cue.
  final Duration position;

  /// Whether the bottom controls are visible — shifts subs up to avoid overlap.
  final bool controlsVisible;

  const SubtitleOverlay({
    super.key,
    required this.cues,
    required this.position,
    this.controlsVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (cues.isEmpty) return const SizedBox.shrink();

    final activeCue = getActiveCue(cues, position);
    if (activeCue == null) return const SizedBox.shrink();

    // Push subtitles higher when controls are showing to avoid overlap
    final bottomPadding = controlsVisible ? 112.0 : 42.0;

    return Positioned(
      left: 24,
      right: 24,
      bottom: bottomPadding,
      child: IgnorePointer(
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Container(
              key: ValueKey(activeCue.text),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: PlayerTheme.cyanAccent.withOpacity(0.35),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.75),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                activeCue.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: Offset(1, 1),
                    ),
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(-1, -1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
