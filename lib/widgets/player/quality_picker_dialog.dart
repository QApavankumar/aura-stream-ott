import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aura_stream/models/track_models.dart';
import 'package:aura_stream/theme/player_theme.dart';

/// Frosted Glass Dialog for Selecting Streaming Video Quality
class QualityPickerDialog extends StatelessWidget {
  final QualityOption selectedQuality;
  final ValueChanged<QualityOption> onQualitySelected;

  const QualityPickerDialog({
    super.key,
    required this.selectedQuality,
    required this.onQualitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: 380,
            decoration: BoxDecoration(
              color: PlayerTheme.bgGlassDark,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: PlayerTheme.cyanAccent.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: PlayerTheme.cyanAccent.withOpacity(0.2),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  PlayerTheme.cyanAccent,
                                  PlayerTheme.purpleAccent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: PlayerTheme.cyanAccent.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.high_quality_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Video Quality',
                            style: TextStyle(
                              color: PlayerTheme.textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
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
                ),
                const Divider(
                  color: PlayerTheme.borderGlass,
                  height: 1,
                ),

                // Quality Options List
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: QualityOption.defaultQualities.map((quality) {
                      final isSelected = quality.id == selectedQuality.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            onQualitySelected(quality);
                            Navigator.of(context).pop();
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          color: PlayerTheme.cyanAccent
                                              .withOpacity(0.8),
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
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

