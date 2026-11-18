import 'package:flutter/material.dart';
import 'package:aura_stream/models/media_item.dart';
import 'package:aura_stream/theme/aura_theme.dart';
import 'frosted_glass_card.dart';

/// Horizontal rail card for category movies (e.g. "Trending Now", "Action & Sci-Fi").
class CategoryMovieCard extends StatelessWidget {
  final Movie item;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  const CategoryMovieCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 14),
        child: FrostedGlassCard(
          borderRadius: BorderRadius.circular(16),
          borderColor: AuraTheme.glassBorder,
          backgroundColor: AuraTheme.surfaceDark.withValues(alpha: 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AuraTheme.cardDark,
                          child: const Icon(Icons.movie, color: AuraTheme.textSecondary),
                        ),
                      ),

                      // Rating Pill
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: AuraTheme.neonCyan.withValues(alpha: 0.4),
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 11, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                item.rating,
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Quick play button on tap
                      if (onPlay != null)
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: onPlay,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.7),
                                border: Border.all(color: AuraTheme.neonCyan, width: 1),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 16,
                                color: AuraTheme.neonCyan,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Title & Meta
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.genres.take(2).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 10,
                        color: AuraTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
