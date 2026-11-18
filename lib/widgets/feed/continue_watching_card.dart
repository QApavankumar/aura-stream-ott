import 'package:flutter/material.dart';
import 'package:aura_stream/models/media_item.dart';
import 'package:aura_stream/theme/aura_theme.dart';
import 'frosted_glass_card.dart';

/// Horizontal rail card for "Continue Watching" items,
/// featuring a prominent Neon Cyan progress bar and frosted container.
class ContinueWatchingCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final progressVal = (item.progress ?? 0.5).clamp(0.0, 1.0);

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      child: FrostedGlassCard(
        borderRadius: BorderRadius.circular(16),
        borderColor: AuraTheme.glassBorder,
        backgroundColor: AuraTheme.surfaceDark.withValues(alpha: 0.65),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail with Play Button
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.backdropUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AuraTheme.cardDark,
                        child: const Icon(Icons.movie, color: AuraTheme.textSecondary),
                      ),
                    ),

                    // Translucent dark vignette
                    Container(
                      color: Colors.black.withValues(alpha: 0.28),
                    ),

                    // Play Button Circle
                    Center(
                      child: GestureDetector(
                        onTap: onPlayTap,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.6),
                            border: Border.all(
                              color: AuraTheme.neonCyan,
                              width: 1.5,
                            ),
                            boxShadow: AuraTheme.cyanGlow(blur: 10),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AuraTheme.neonCyan,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Remaining Time Tag (e.g. "45m left", "18m remaining")
                    if (item.remainingTime != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.remainingTime!,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // NEON CYAN PROGRESS BAR
            ClipRRect(
              child: SizedBox(
                height: 3.5,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    FractionallySizedBox(
                      widthFactor: progressVal,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AuraTheme.purpleAura, AuraTheme.neonCyan],
                          ),
                          boxShadow: AuraTheme.cyanGlow(blur: 6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Metadata info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.episodeLabel ?? item.genres.join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AuraTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
