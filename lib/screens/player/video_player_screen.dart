import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:aura_stream/models/subtitle_data.dart';
import 'package:aura_stream/models/track_models.dart';
import 'package:aura_stream/theme/player_theme.dart';
import 'package:aura_stream/widgets/player/audio_subtitle_drawer.dart';
import 'package:aura_stream/widgets/player/player_controls.dart';
import 'package:aura_stream/widgets/player/skip_indicator.dart';
import 'package:aura_stream/widgets/player/subtitle_overlay.dart';

/// Fullscreen Landscape Futuristic Video Player Screen
/// Member 1 Video Player Module for OTT Streaming App
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String subtitle;
  final String? thumbnailUrl;

  const VideoPlayerScreen({
    super.key,
    String? videoUrl,
    String? streamUrl,
    this.title = 'CHRONO HORIZON: VOID ODYSSEY',
    this.subtitle = 'S1 : E1 • Neural Frontier',
    this.thumbnailUrl,
  }) : videoUrl = streamUrl ??
            videoUrl ??
            'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  // MediaKit Player & VideoController
  late final Player _player;
  late final VideoController _controller;

  // Stream Subscriptions
  final List<StreamSubscription> _subscriptions = [];

  // Playback State
  bool _isPlaying = false;
  bool _isBuffering = true;
  bool _isAutoplayRestricted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _buffered = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;
  String? _errorMessage;

  // UI Control State
  bool _showControls = true;
  Timer? _autoHideTimer;
  bool _isSeeking = false;
  bool _isDrawerOpen = false;

  // Double-tap Skip Indicator State
  bool _showSkipIndicator = false;
  bool _skipIsForward = true;
  int _skipCounter = 0;

  // Mock Track Selections
  AudioTrackOption _selectedAudio = AudioTrackOption.defaultTracks.first;
  SubtitleTrackOption _selectedSubtitle =
      SubtitleTrackOption.defaultSubtitles.first;
  QualityOption _selectedQuality = QualityOption.defaultQualities.first;

  // Subtitle Toast Notification State
  bool _showSubtitleToast = false;
  String? _subtitleToastMessage;
  Timer? _subtitleToastTimer;

  // Screen Mode (BoxFit / sizing)
  ScreenMode _screenMode = ScreenMode.fitContain;
  bool _isHalfScreen = false;

  // Controls Fade Animation Controller
  late final AnimationController _controlsFadeController;
  late final Animation<double> _controlsFadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Lock screen to landscape & immersive mode
    _lockLandscapeAndImmersive();

    // 2. Setup Animation
    _controlsFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _controlsFadeAnimation = CurvedAnimation(
      parent: _controlsFadeController,
      curve: Curves.easeInOut,
    );

    // 3. Initialize MediaKit Player
    _initializePlayer();

    // 4. Start Auto-Hide Timer
    _startAutoHideTimer();
  }

  void _lockLandscapeAndImmersive() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _restoreOrientationsAndUI() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _initializePlayer() {
    _player = Player();
    _controller = VideoController(_player);

    // Subscribe to state streams
    _subscriptions.add(
      _player.stream.playing.listen((playing) {
        if (!mounted) return;
        setState(() {
          _isPlaying = playing;
        });
        if (playing) {
          _startAutoHideTimer();
        } else {
          _cancelAutoHideTimer();
        }
      }),
    );

    _subscriptions.add(
      _player.stream.buffering.listen((buffering) {
        if (!mounted) return;
        setState(() {
          _isBuffering = buffering;
        });
      }),
    );

    _subscriptions.add(
      _player.stream.position.listen((pos) {
        if (!mounted || _isSeeking) return;
        setState(() {
          _position = pos;
        });
      }),
    );

    _subscriptions.add(
      _player.stream.duration.listen((dur) {
        if (!mounted) return;
        setState(() {
          _duration = dur;
        });
      }),
    );

    _subscriptions.add(
      _player.stream.buffer.listen((buf) {
        if (!mounted) return;
        setState(() {
          _buffered = buf;
        });
      }),
    );

    _subscriptions.add(
      _player.stream.error.listen((err) {
        if (!mounted) return;
        final errLower = err.toLowerCase();
        final isAutoplay = errLower.contains("didn't interact") ||
            errLower.contains("notallowederror") ||
            errLower.contains("autoplay") ||
            errLower.contains("play() failed") ||
            errLower.contains("user didn't interact") ||
            errLower.contains("play failed");

        setState(() {
          _isAutoplayRestricted = isAutoplay;
          _errorMessage = isAutoplay ? null : (err.isNotEmpty ? err : 'Stream playback error');
          _isBuffering = false;
          if (isAutoplay) {
            _showControls = true;
          }
        });
      }),
    );

    _loadStream();
  }

  void _loadStream() {
    setState(() {
      _errorMessage = null;
      _isAutoplayRestricted = false;
      _isBuffering = true;
    });

    try {
      _player.open(Media(widget.videoUrl));
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load HLS stream: $e';
        _isBuffering = false;
      });
    }
  }

  // Auto-Hide Controls
  void _startAutoHideTimer() {
    _cancelAutoHideTimer();
    if (!_isPlaying || _isSeeking || _isDrawerOpen) return;

    _autoHideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying && !_isSeeking && !_isDrawerOpen) {
        setState(() {
          _showControls = false;
        });
        _controlsFadeController.reverse();
      }
    });
  }

  void _cancelAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
  }

  void _toggleControls() {
    if (_isDrawerOpen) {
      setState(() {
        _isDrawerOpen = false;
      });
      return;
    }

    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _controlsFadeController.forward();
      _startAutoHideTimer();
    } else {
      _controlsFadeController.reverse();
      _cancelAutoHideTimer();
    }
  }

  // Playback Actions
  void _handlePlayPause() {
    if (_isAutoplayRestricted) {
      setState(() {
        _isAutoplayRestricted = false;
      });
      _player.play();
      _startAutoHideTimer();
      return;
    }
    _player.playOrPause();
    _startAutoHideTimer();
  }

  void _handleSeek(Duration newPosition) {
    final clampedMs =
        newPosition.inMilliseconds.clamp(0, _duration.inMilliseconds);
    final target = Duration(milliseconds: clampedMs);
    setState(() {
      _position = target;
    });
    _player.seek(target);
    _startAutoHideTimer();
  }

  void _handleSeekingChanged(bool isSeeking) {
    setState(() {
      _isSeeking = isSeeking;
    });
    if (isSeeking) {
      _cancelAutoHideTimer();
    } else {
      _startAutoHideTimer();
    }
  }

  void _handleRewind10() {
    final newMs = (_position.inMilliseconds - 10000).clamp(0, _duration.inMilliseconds);
    _handleSeek(Duration(milliseconds: newMs));
    _triggerSkipIndicator(isForward: false);
  }

  void _handleForward10() {
    final newMs = (_position.inMilliseconds + 10000).clamp(0, _duration.inMilliseconds);
    _handleSeek(Duration(milliseconds: newMs));
    _triggerSkipIndicator(isForward: true);
  }

  void _triggerSkipIndicator({required bool isForward}) {
    setState(() {
      _skipIsForward = isForward;
      _showSkipIndicator = true;
      _skipCounter++;
    });
    _startAutoHideTimer();
  }

  void _handleVolumeChanged(double val) {
    setState(() {
      _volume = val;
      _isMuted = val == 0.0;
    });
    _player.setVolume(val * 100.0);
    _startAutoHideTimer();
  }

  void _handleToggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      _player.setVolume(0.0);
    } else {
      _player.setVolume((_volume > 0 ? _volume : 0.5) * 100.0);
    }
    _startAutoHideTimer();
  }

  void _handleToggleScreenMode() {
    const modes = ScreenMode.values;
    final nextIndex = (modes.indexOf(_screenMode) + 1) % modes.length;
    setState(() {
      _screenMode = modes[nextIndex];
      _isHalfScreen = _screenMode == ScreenMode.halfScreen;
    });
    _startAutoHideTimer();
  }

  void _handleToggleSubtitles() {
    final subOptions = SubtitleTrackOption.defaultSubtitles;
    // Cycle between Off -> Telugu -> English -> Hindi -> Spanish -> Off
    final currentIndex =
        subOptions.indexWhere((s) => s.id == _selectedSubtitle.id);
    final nextIndex = (currentIndex + 1) % subOptions.length;
    final nextSub = subOptions[nextIndex];

    _applySubtitleSelection(nextSub);
    _startAutoHideTimer();
  }

  void _applySubtitleSelection(SubtitleTrackOption sub) {
    setState(() {
      _selectedSubtitle = sub;
      _subtitleToastMessage =
          sub.id == 'off' ? 'Subtitles: Off' : 'Subtitles: ${sub.label}';
      _showSubtitleToast = true;
    });

    _subtitleToastTimer?.cancel();
    _subtitleToastTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _showSubtitleToast = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _cancelAutoHideTimer();
    _subtitleToastTimer?.cancel();
    _controlsFadeController.dispose();
    for (final s in _subscriptions) {
      s.cancel();
    }
    _player.dispose();
    _restoreOrientationsAndUI();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Raw Video View
          _isHalfScreen
              ? Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Video(
                      controller: _controller,
                      controls: NoVideoControls,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : Center(
                  child: Video(
                    controller: _controller,
                    controls: NoVideoControls,
                    fit: _screenMode.boxFit,
                  ),
                ),

          // 2. Gesture Detector for Screen Taps & Double Taps
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleControls,
            onDoubleTapDown: (details) {
              final xPos = details.localPosition.dx;
              if (xPos < screenWidth * 0.40) {
                // Double tap on left side -> Rewind 10s
                _handleRewind10();
              } else if (xPos > screenWidth * 0.60) {
                // Double tap on right side -> Forward 10s
                _handleForward10();
              } else {
                // Center double tap toggles play/pause
                _handlePlayPause();
              }
            },
            child: Container(color: Colors.transparent),
          ),

          // 3. Skip Indicator Overlay (-10s / +10s)
          if (_showSkipIndicator)
            Positioned.fill(
              key: ValueKey(_skipCounter),
              child: Align(
                alignment: _skipIsForward
                    ? const Alignment(0.65, 0.0)
                    : const Alignment(-0.65, 0.0),
                child: SkipIndicatorOverlay(
                  isForward: _skipIsForward,
                  onDismissed: () {
                    if (mounted) {
                      setState(() {
                        _showSkipIndicator = false;
                      });
                    }
                  },
                ),
              ),
            ),

          // 3b. Subtitle Text Overlay (timed mock cues)
          if (_selectedSubtitle.id != 'off')
            SubtitleOverlay(
              cues: getSubtitleCuesForTrack(_selectedSubtitle.id),
              position: _position,
              controlsVisible: _showControls,
            ),

          // 3c. Subtitle Status Notification Toast
          if (_showSubtitleToast && _subtitleToastMessage != null)
            _buildSubtitleToast(),

          // 4. Loading / Buffering Spinner
          if (_isBuffering && _errorMessage == null && !_isAutoplayRestricted)
            Center(
              child: _buildFuturisticLoadingIndicator(),
            ),

          // 4b. Autoplay Initial Interaction Prompt
          if (_isAutoplayRestricted)
            Center(
              child: _buildAutoplayPrompt(),
            ),

          // 5. Error View Overlay
          if (_errorMessage != null)
            Center(
              child: _buildErrorOverlay(),
            ),

          // 6. Player Controls HUD Overlay
          if (_showControls && _errorMessage == null)
            FadeTransition(
              opacity: _controlsFadeAnimation,
              child: PlayerControls(
                isPlaying: _isPlaying,
                isBuffering: _isBuffering,
                position: _position,
                duration: _duration,
                buffered: _buffered,
                volume: _volume,
                isMuted: _isMuted,
                title: widget.title,
                subtitle: widget.subtitle,
                selectedAudio: _selectedAudio,
                selectedSubtitle: _selectedSubtitle,
                selectedQuality: _selectedQuality,
                screenMode: _screenMode,
                onPlayPause: _handlePlayPause,
                onRewind10: _handleRewind10,
                onForward10: _handleForward10,
                onSeek: _handleSeek,
                onSeekingChanged: _handleSeekingChanged,
                onVolumeChanged: _handleVolumeChanged,
                onToggleMute: _handleToggleMute,
                onOpenAudioSubtitles: () {
                  setState(() {
                    _isDrawerOpen = true;
                  });
                  _cancelAutoHideTimer();
                },
                onToggleScreenMode: _handleToggleScreenMode,
                onToggleSubtitles: _handleToggleSubtitles,
                onBack: () {
                  Navigator.of(context).maybePop();
                },
              ),
            ),

          // 7. Audio & Subtitles Slide-over Frosted Glass Drawer
          if (_isDrawerOpen)
            AudioSubtitleDrawer(
              selectedAudio: _selectedAudio,
              selectedSubtitle: _selectedSubtitle,
              selectedQuality: _selectedQuality,
              onAudioSelected: (audio) {
                setState(() {
                  _selectedAudio = audio;
                });
              },
              onSubtitleSelected: (sub) {
                _applySubtitleSelection(sub);
              },
              onQualitySelected: (quality) {
                setState(() {
                  _selectedQuality = quality;
                });
              },
              onClose: () {
                setState(() {
                  _isDrawerOpen = false;
                });
                _startAutoHideTimer();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubtitleToast() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: PlayerTheme.cyanAccent.withOpacity(0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: PlayerTheme.cyanAccent.withOpacity(0.3),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedSubtitle.id == 'off'
                        ? Icons.closed_caption_disabled_rounded
                        : Icons.closed_caption_rounded,
                    color: PlayerTheme.cyanAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _subtitleToastMessage ?? '',
                    style: const TextStyle(
                      color: PlayerTheme.textMain,
                      fontSize: 13,
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
    );
  }

  Widget _buildAutoplayPrompt() {
    return InkWell(
      onTap: _handlePlayPause,
      borderRadius: BorderRadius.circular(30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: PlayerTheme.cyanAccent.withOpacity(0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: PlayerTheme.cyanAccent.withOpacity(0.35),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        PlayerTheme.cyanAccent,
                        PlayerTheme.purpleAccent,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PlayerTheme.cyanAccent.withOpacity(0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'START STREAMING',
                      style: TextStyle(
                        color: PlayerTheme.textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Click to play HLS video',
                      style: TextStyle(
                        color: PlayerTheme.cyanAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFuturisticLoadingIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: PlayerTheme.cyanAccent.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: PlayerTheme.cyanAccent.withOpacity(0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    PlayerTheme.cyanAccent,
                  ),
                ),
              ),
              SizedBox(width: 14),
              Text(
                'BUFFERING STREAM...',
                style: TextStyle(
                  color: PlayerTheme.cyanAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: PlayerTheme.bgGlassDark,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: PlayerTheme.rubyAccent.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: PlayerTheme.rubyAccent.withOpacity(0.25),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlayerTheme.rubyAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PlayerTheme.rubyAccent,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: PlayerTheme.rubyAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Playback Stream Error',
                style: TextStyle(
                  color: PlayerTheme.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unable to stream the requested HLS media.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: PlayerTheme.textMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PlayerTheme.textMuted,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _loadStream,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Retry Stream'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlayerTheme.cyanAccent,
                      foregroundColor: Colors.black,
                      elevation: 8,
                      shadowColor: PlayerTheme.cyanAccent.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
