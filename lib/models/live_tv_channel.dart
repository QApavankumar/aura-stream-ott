import 'package:flutter/material.dart';

class LiveProgram {
  final String id;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final double progress; // 0.0 to 1.0
  final bool isLiveNow;
  final String category;
  final String maturityRating;
  final String resolution; // '4K UHD', '1080p 60fps'

  const LiveProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.progress,
    required this.isLiveNow,
    required this.category,
    this.maturityRating = '16+',
    this.resolution = '4K UHD',
  });
}

class LiveChannel {
  final String id;
  final String number;
  final String name;
  final String category;
  final String logoUrl;
  final String streamUrl;
  final String currentViewers;
  final Color themeColor;
  final List<LiveProgram> schedule;

  const LiveChannel({
    required this.id,
    required this.number,
    required this.name,
    required this.category,
    required this.logoUrl,
    required this.streamUrl,
    required this.currentViewers,
    required this.themeColor,
    required this.schedule,
  });

  LiveProgram? get currentProgram {
    try {
      return schedule.firstWhere((p) => p.isLiveNow);
    } catch (_) {
      return schedule.isNotEmpty ? schedule.first : null;
    }
  }
}
