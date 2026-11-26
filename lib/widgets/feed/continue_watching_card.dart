import 'package:flutter/material.dart';
import 'package:aura_stream/models/media_item.dart';
import 'package:aura_stream/core/theme/app_colors.dart';
import 'package:aura_stream/core/theme/app_typography.dart';

/// Clean 16:9 Continue Watching card with crisp white playback progress bar.
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
    final progress = (widget.item.progress ?? 0.35).clamp(0.05, 0.98);
    final durationLabel = widget.item.remainingTime ??
        (widget.item.duration.isNotEmpty
            ? '${widget.item.duration} left'
            : 'Continue');
    final primaryGenre = widget.item.genres.isNotEmpty
        ? widget.item.genres.first
        : '4K HDR';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 268,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _hovered
                        ? AppColors.noirWhite
                        : AppColors.glassBorder,
                    width: _hovered ? 1.5 : 1.0,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.item.backdropUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.cardSurface),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.72),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: widget.onPlayTap,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: _hovered ? 1.0 : 0.85,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.noirWhite,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 3.5,
                        color: Colors.white.withValues(alpha: 0.22),
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
              const SizedBox(height: 10),
              Text(
                widget.item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleLarge.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 2),
              Text(
                widget.item.episodeLabel != null &&
                        widget.item.episodeLabel!.isNotEmpty
                    ? '${widget.item.episodeLabel} • $durationLabel'
                    : '$durationLabel • $primaryGenre',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
