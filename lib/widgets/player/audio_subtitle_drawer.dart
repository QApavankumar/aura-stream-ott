import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aura_stream/models/track_models.dart';
import 'package:aura_stream/theme/player_theme.dart';

/// Frosted Glass Slide-over Drawer for Audio, Subtitle & Quality Selection
class AudioSubtitleDrawer extends StatefulWidget {
  final AudioTrackOption selectedAudio;
  final SubtitleTrackOption selectedSubtitle;
  final QualityOption selectedQuality;
  final ValueChanged<AudioTrackOption> onAudioSelected;
  final ValueChanged<SubtitleTrackOption> onSubtitleSelected;
  final ValueChanged<QualityOption> onQualitySelected;
  final VoidCallback onClose;

  const AudioSubtitleDrawer({
    super.key,
    required this.selectedAudio,
    required this.selectedSubtitle,
    required this.selectedQuality,
    required this.onAudioSelected,
    required this.onSubtitleSelected,
    required this.onQualitySelected,
    required this.onClose,
  });

  @override
  State<AudioSubtitleDrawer> createState() => _AudioSubtitleDrawerState();
}

class _AudioSubtitleDrawerState extends State<AudioSubtitleDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  void _closeDrawer() {
    _slideController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Stack(
          children: [
            // Scrim overlay - tap outside to close
            GestureDetector(
              onTap: _closeDrawer,
              behavior: HitTestBehavior.opaque,
              child: Opacity(
                opacity: _fadeAnimation.value * 0.45,
                child: Container(color: Colors.black),
              ),
            ),

            // Slide-over Drawer Panel
            SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 360,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: PlayerTheme.cyanAccent.withOpacity(0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: PlayerTheme.cyanAccent.withOpacity(0.15),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(24),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        color: PlayerTheme.bgGlassDark,
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(),
                              const Divider(
                                color: PlayerTheme.borderGlass,
                                height: 1,
                              ),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  children: [
                                    _buildSubtitleSection(),
                                    const SizedBox(height: 24),
                                    _buildAudioSection(),
                                    const SizedBox(height: 24),
                                    _buildQualitySection(),
                                    const SizedBox(height: 24),
                                    _buildPrototypeDisclaimer(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PlayerTheme.borderGlass),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Audio, Subtitles & Quality',
                    style: TextStyle(
                      color: PlayerTheme.textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _closeDrawer,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: PlayerTheme.textMuted,
                size: 16,
              ),
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.high_quality_rounded,
              color: PlayerTheme.cyanAccent,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'VIDEO QUALITY',
              style: TextStyle(
                color: PlayerTheme.cyanAccent.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...QualityOption.defaultQualities.map((quality) {
          final isSelected = widget.selectedQuality.id == quality.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                widget.onQualitySelected(quality);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: PlayerTheme.neonPillDecoration(
                  isSelected: isSelected,
                  accentColor: PlayerTheme.cyanAccent,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? PlayerTheme.cyanAccent
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        quality.badge,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : PlayerTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quality.label,
                            style: TextStyle(
                              color: isSelected
                                  ? PlayerTheme.textMain
                                  : PlayerTheme.textMuted,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            quality.resolution,
                            style: TextStyle(
                              color: isSelected
                                  ? PlayerTheme.cyanAccent
                                  : PlayerTheme.textDim,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: PlayerTheme.cyanAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PlayerTheme.cyanAccent.withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.black,
                          size: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAudioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.volume_up_rounded,
              color: PlayerTheme.purpleAccent,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'AUDIO TRACKS',
              style: TextStyle(
                color: PlayerTheme.purpleAccent.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...AudioTrackOption.defaultTracks.map((track) {
          final isSelected = widget.selectedAudio.id == track.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                widget.onAudioSelected(track);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: PlayerTheme.neonPillDecoration(
                  isSelected: isSelected,
                  accentColor: PlayerTheme.purpleAccent,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.label,
                            style: TextStyle(
                              color: isSelected
                                  ? PlayerTheme.textMain
                                  : PlayerTheme.textMuted,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.formatInfo,
                            style: TextStyle(
                              color: isSelected
                                  ? PlayerTheme.purpleAccent
                                  : PlayerTheme.textDim,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: PlayerTheme.purpleAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PlayerTheme.purpleAccent.withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubtitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.closed_caption_rounded,
              color: PlayerTheme.cyanAccent,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'SUBTITLES',
              style: TextStyle(
                color: PlayerTheme.cyanAccent.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...SubtitleTrackOption.defaultSubtitles.map((subtitle) {
          final isSelected = widget.selectedSubtitle.id == subtitle.id;
          final isOff = subtitle.id == 'off';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                widget.onSubtitleSelected(subtitle);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: PlayerTheme.neonPillDecoration(
                  isSelected: isSelected,
                  accentColor: PlayerTheme.cyanAccent,
                ),
                child: Row(
                  children: [
                    Icon(
                      isOff
                          ? Icons.closed_caption_disabled_rounded
                          : Icons.closed_caption_rounded,
                      color: isSelected
                          ? PlayerTheme.cyanAccent
                          : PlayerTheme.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtitle.label,
                            style: TextStyle(
                              color: isSelected
                                  ? PlayerTheme.textMain
                                  : PlayerTheme.textMuted,
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isOff
                                ? 'No subtitles'
                                : 'Closed Captions • ${subtitle.languageCode}',
                            style: TextStyle(
                              color: isSelected
                                  ? PlayerTheme.cyanAccent
                                  : PlayerTheme.textDim,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: PlayerTheme.cyanAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PlayerTheme.cyanAccent.withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.black,
                          size: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPrototypeDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: PlayerTheme.cyanAccent.withOpacity(0.8),
            size: 15,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Prototype Selector: Interactive UI for Audio, Subtitles and Video Bitrate quality switching.',
              style: TextStyle(
                color: PlayerTheme.textDim,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
