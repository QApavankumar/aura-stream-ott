import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aura_stream/models/track_models.dart';
import 'package:aura_stream/theme/player_theme.dart';
import 'player_timeline.dart';

/// Complete Futuristic HUD Player Controls Overlay
class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final double volume;
  final bool isMuted;
  final String title;
  final String subtitle;
  final AudioTrackOption selectedAudio;
  final SubtitleTrackOption selectedSubtitle;
  final QualityOption selectedQuality;
  final ScreenMode screenMode;

  final VoidCallback onPlayPause;
  final VoidCallback onRewind10;
  final VoidCallback onForward10;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<bool>? onSeekingChanged;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onToggleMute;
  final VoidCallback onOpenAudioSubtitles;
  final VoidCallback onToggleScreenMode;
  final VoidCallback? onToggleSubtitles;
  final VoidCallback? onBack;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isBuffering,
    required this.position,
    required this.duration,
    required this.buffered,
    required this.volume,
    required this.isMuted,
    required this.title,
    required this.subtitle,
    required this.selectedAudio,
    required this.selectedSubtitle,
    required this.selectedQuality,
    this.screenMode = ScreenMode.fitContain,
    required this.onPlayPause,
    required this.onRewind10,
    required this.onForward10,
    required this.onSeek,
    this.onSeekingChanged,
    required this.onVolumeChanged,
    required this.onToggleMute,
    required this.onOpenAudioSubtitles,
    required this.onToggleScreenMode,
    this.onToggleSubtitles,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top and Bottom Scrim Gradients for contrast
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xE606070A),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 140,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xF006070A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Controls Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTopBar(context),
                _buildCenterControls(),
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final isSubsOn = selectedSubtitle.id != 'off';

    return Row(
      children: [
        // Back Button
        if (onBack != null)
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: PlayerTheme.textMain,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(width: 16),

        // Title and Metadata
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: PlayerTheme.textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Live Premiere Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: PlayerTheme.rubyAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: PlayerTheme.rubyAccent,
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'PREMIERE',
                      style: TextStyle(
                        color: PlayerTheme.rubyAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        color: PlayerTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTechBadge('4K UHD', PlayerTheme.cyanAccent),
                  const SizedBox(width: 6),
                  _buildTechBadge('DOLBY ATMOS', PlayerTheme.purpleAccent),
                ],
              ),
            ],
          ),
        ),

        // Right Action Pills: Subtitles, Audio & Quality
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtitle CC Pill Button (Tappable, highlights when active)
            Tooltip(
              message: isSubsOn
                  ? 'Subtitles: ${selectedSubtitle.label} (Click to toggle)'
                  : 'Subtitles: Off (Click to turn on)',
              child: InkWell(
                onTap: onToggleSubtitles ?? onOpenAudioSubtitles,
                borderRadius: BorderRadius.circular(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSubsOn
                            ? PlayerTheme.cyanAccent.withOpacity(0.2)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSubsOn
                              ? PlayerTheme.cyanAccent
                              : Colors.white.withOpacity(0.2),
                          width: 1.2,
                        ),
                        boxShadow: isSubsOn
                            ? [
                                BoxShadow(
                                  color: PlayerTheme.cyanAccent.withOpacity(0.35),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSubsOn
                                ? Icons.closed_caption_rounded
                                : Icons.closed_caption_outlined,
                            color: isSubsOn
                                ? PlayerTheme.cyanAccent
                                : PlayerTheme.textMuted,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isSubsOn ? selectedSubtitle.label : 'CC Off',
                            style: TextStyle(
                              color: isSubsOn
                                  ? PlayerTheme.cyanAccent
                                  : PlayerTheme.textMuted,
                              fontSize: 11,
                              fontWeight: isSubsOn
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Audio Track Pill Button
            Tooltip(
              message: 'Audio: ${selectedAudio.label}',
              child: InkWell(
                onTap: onOpenAudioSubtitles,
                borderRadius: BorderRadius.circular(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: PlayerTheme.purpleAccent.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: PlayerTheme.purpleAccent.withOpacity(0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.volume_up_rounded,
                            color: PlayerTheme.purpleAccent,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            selectedAudio.label,
                            style: const TextStyle(
                              color: PlayerTheme.textMain,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Quality Badge Pill — tappable, opens the drawer
            Tooltip(
              message: 'Video Quality: ${selectedQuality.label}',
              child: InkWell(
                onTap: onOpenAudioSubtitles,
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 7),
                      decoration: BoxDecoration(
                        color: PlayerTheme.cyanAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: PlayerTheme.cyanAccent.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: PlayerTheme.cyanAccent.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.hd_rounded,
                            color: PlayerTheme.cyanAccent,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            selectedQuality.badge,
                            style: const TextStyle(
                              color: PlayerTheme.cyanAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTechBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4), width: 0.6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Quick Rewind -10s
        InkWell(
          onTap: onRewind10,
          borderRadius: BorderRadius.circular(30),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.replay_10_rounded,
                  color: PlayerTheme.textMain,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),

        // Clean White Noir Center Play/Pause Button (Panel 4)
        InkWell(
          onTap: onPlayPause,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),

        // Quick Forward +10s
        InkWell(
          onTap: onForward10,
          borderRadius: BorderRadius.circular(30),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.forward_10_rounded,
                  color: PlayerTheme.textMain,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final isSubsOn = selectedSubtitle.id != 'off';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scrubber Timeline
        PlayerTimeline(
          position: position,
          duration: duration,
          buffered: buffered,
          onSeek: onSeek,
          onSeekingChanged: onSeekingChanged,
        ),
        const SizedBox(height: 10),

        // Bottom Controls Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Mini Play/Pause + Volume Control
            Row(
              children: [
                IconButton(
                  onPressed: onPlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: PlayerTheme.textMain,
                    size: 22,
                  ),
                  splashRadius: 20,
                ),
                IconButton(
                  onPressed: onToggleMute,
                  icon: Icon(
                    isMuted || volume == 0
                        ? Icons.volume_off_rounded
                        : volume < 0.5
                            ? Icons.volume_down_rounded
                            : Icons.volume_up_rounded,
                    color: PlayerTheme.cyanAccent,
                    size: 20,
                  ),
                  splashRadius: 20,
                ),
                SizedBox(
                  width: 90,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: PlayerTheme.cyanAccent,
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: Colors.white,
                      overlayColor: PlayerTheme.cyanAccent.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: isMuted ? 0.0 : volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: onVolumeChanged,
                    ),
                  ),
                ),
              ],
            ),

            // Right: CC Subtitles Button + Audio & Subtitles Drawer + Screen Mode Toggle
            Row(
              children: [
                // Prominent CC Subtitles Toggle Button
                Tooltip(
                  message: isSubsOn
                      ? 'Subtitles: ${selectedSubtitle.label} (Click to toggle)'
                      : 'Subtitles: Off (Click to turn on)',
                  child: InkWell(
                    onTap: onToggleSubtitles ?? onOpenAudioSubtitles,
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSubsOn
                            ? PlayerTheme.cyanAccent.withOpacity(0.22)
                            : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSubsOn
                              ? PlayerTheme.cyanAccent
                              : Colors.white.withOpacity(0.18),
                          width: 1.2,
                        ),
                        boxShadow: isSubsOn
                            ? [
                                BoxShadow(
                                  color: PlayerTheme.cyanAccent.withOpacity(0.4),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSubsOn
                                ? Icons.closed_caption_rounded
                                : Icons.closed_caption_outlined,
                            color: isSubsOn
                                ? PlayerTheme.cyanAccent
                                : PlayerTheme.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSubsOn ? selectedSubtitle.label : 'CC',
                            style: TextStyle(
                              color: isSubsOn
                                  ? PlayerTheme.cyanAccent
                                  : PlayerTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Audio, Subtitles & Quality Full Drawer Button
                IconButton(
                  tooltip: 'Audio & Subtitles & Quality Menu',
                  onPressed: onOpenAudioSubtitles,
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: PlayerTheme.textMuted,
                    size: 20,
                  ),
                  splashRadius: 20,
                ),
                const SizedBox(width: 4),

                // Screen mode toggle with visual indicator
                Tooltip(
                  message: 'Screen: ${screenMode.label}',
                  child: InkWell(
                    onTap: onToggleScreenMode,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: PlayerTheme.cyanAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: PlayerTheme.cyanAccent.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            screenMode.icon,
                            color: PlayerTheme.cyanAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            screenMode.label,
                            style: const TextStyle(
                              color: PlayerTheme.cyanAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
