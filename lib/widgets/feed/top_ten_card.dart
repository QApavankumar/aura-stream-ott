import 'package:flutter/material.dart';
import 'package:aura_stream/models/media_item.dart';
import 'package:aura_stream/theme/aura_theme.dart';
import 'frosted_glass_card.dart';

/// "Top 10" ranked vertical poster rail card with neon Orbitron typography rank badge.
class TopTenCard extends StatelessWidget {
  final Movie item;
  final VoidCallback onTap;

  const TopTenCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rank = item.rank ?? 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 18),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Vertical Poster Card
            Padding(
              padding: const EdgeInsets.only(left: 24),
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
                                child: const Icon(Icons.movie_creation_outlined, color: AuraTheme.textSecondary),
                              ),
                            ),

                            // Top Rating Badge
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AuraTheme.neonCyan.withValues(alpha: 0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 12,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      item.rating,
                                      style: AppTypography.bodySmall.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Title & Genres
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
                              fontSize: 13,
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

            // Numbered Rank Badge with Neon Stroke Orbitron Typography
            Positioned(
              left: 0,
              bottom: 30,
              child: Stack(
                children: [
                  // Outer Glow Stroke
                  Text(
                    '$rank',
                    style: AppTypography.rankNumber.copyWith(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4
                        ..color = rank <= 3
                            ? AuraTheme.neonCyan
                            : AuraTheme.purpleAura,
                    ),
                  ),

                  // Fill color
                  Text(
                    '$rank',
                    style: AppTypography.rankNumber.copyWith(
                      color: AuraTheme.darkObsidian,
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
