import 'package:flutter/material.dart';
import 'package:aura_stream/models/media_item.dart';
import 'package:aura_stream/core/theme/app_colors.dart';
import '../common/cinema_image.dart';

/// Clean 16:9 Continue Watching thumbnail with bottom white progress bar matching screenshot.
class ContinueWatchingCard extends StatefulWidget {
  final Movie item;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;

  const ContinueWatchingCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onPlayTap,
  });

  @override
  State<ContinueWatchingCard> createState() => _ContinueWatchingCardState();
}

class _ContinueWatchingCardState extends State<ContinueWatchingCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final progress = (widget.item.progress ?? 0.42).clamp(0.08, 0.96);
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final cardWidth = isDesktop ? 256.0 : 210.0;
    final cardHeight = isDesktop ? 134.0 : 114.0;

    return Tooltip(
      message: widget.item.title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: cardWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hovered
                          ? AppColors.noirWhite
                          : Colors.white.withValues(alpha: 0.1),
                      width: _hovered ? 1.5 : 1.0,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CinemaImage(
                        imageUrl: widget.item.backdropUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.cardSurface),
                      ),
                      if (_hovered)
                        Container(
                          color: Colors.black.withValues(alpha: 0.28),
                          child: Center(
                            child: GestureDetector(
                              onTap: widget.onPlayTap,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.72),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Sleek monochrome progress bar cleanly beneath card (screenshot style)
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 3.0,
                    width: cardWidth - 16,
                    color: Colors.white.withValues(alpha: 0.18),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(color: AppColors.noirWhite),
                    ),
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
