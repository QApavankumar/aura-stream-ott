import 'package:flutter/material.dart';

/// Models for Audio, Subtitles, Quality, and Screen Adjustment in Video Player
class AudioTrackOption {
  final String id;
  final String label;
  final String languageCode;
  final String formatInfo;

  const AudioTrackOption({
    required this.id,
    required this.label,
    required this.languageCode,
    this.formatInfo = 'Dolby Atmos 5.1',
  });

  static const List<AudioTrackOption> defaultTracks = [
    AudioTrackOption(
      id: 'te',
      label: 'Telugu',
      languageCode: 'te-IN',
      formatInfo: 'Original 5.1 • DTS-HD',
    ),
    AudioTrackOption(
      id: 'en',
      label: 'English',
      languageCode: 'en-US',
      formatInfo: 'Original • Dolby Atmos 5.1',
    ),
    AudioTrackOption(
      id: 'hi',
      label: 'Hindi',
      languageCode: 'hi-IN',
      formatInfo: 'Dubbed • Dolby Digital 5.1',
    ),
    AudioTrackOption(
      id: 'es',
      label: 'Spanish',
      languageCode: 'es-ES',
      formatInfo: 'Doblaje • Stereo 2.0',
    ),
  ];
}

class SubtitleTrackOption {
  final String id;
  final String label;
  final String languageCode;

  const SubtitleTrackOption({
    required this.id,
    required this.label,
    required this.languageCode,
  });

  static const List<SubtitleTrackOption> defaultSubtitles = [
    SubtitleTrackOption(
      id: 'off',
      label: 'Off',
      languageCode: '',
    ),
    SubtitleTrackOption(
      id: 'te',
      label: 'Telugu',
      languageCode: 'te-IN',
    ),
    SubtitleTrackOption(
      id: 'en',
      label: 'English',
      languageCode: 'en-US',
    ),
    SubtitleTrackOption(
      id: 'hi',
      label: 'Hindi',
      languageCode: 'hi-IN',
    ),
    SubtitleTrackOption(
      id: 'es',
      label: 'Spanish',
      languageCode: 'es-ES',
    ),
  ];
}

class QualityOption {
  final String id;
  final String label;
  final String resolution;
  final String badge;

  const QualityOption({
    required this.id,
    required this.label,
    required this.resolution,
    required this.badge,
  });

  static const List<QualityOption> defaultQualities = [
    QualityOption(
      id: 'auto',
      label: 'Auto (Adaptive)',
      resolution: 'Optimal dynamic bitrate',
      badge: 'Auto',
    ),
    QualityOption(
      id: '4k',
      label: '4K Ultra HD',
      resolution: '3840 x 2160 • High Bitrate',
      badge: '4K UHD',
    ),
    QualityOption(
      id: '1080p',
      label: '1080p Full HD',
      resolution: '1920 x 1080 • 60 fps',
      badge: '1080p',
    ),
    QualityOption(
      id: '720p',
      label: '720p HD Ready',
      resolution: '1280 x 720 • Fast',
      badge: '720p',
    ),
    QualityOption(
      id: '480p',
      label: '480p SD',
      resolution: '854 x 480 • Data Saver',
      badge: '480p',
    ),
  ];
}

/// Screen View Mode for Full, Fit, or Half-screen Theater Mode
enum ScreenMode {
  fullCover('Full (Cover)', Icons.fullscreen_rounded, BoxFit.cover),
  fitContain('Fit (16:9)', Icons.fit_screen_rounded, BoxFit.contain),
  halfScreen('Half Screen', Icons.picture_in_picture_alt_rounded, BoxFit.contain);

  final String label;
  final IconData icon;
  final BoxFit boxFit;
  const ScreenMode(this.label, this.icon, this.boxFit);
}
