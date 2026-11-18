import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/frosted_glass.dart';

/// ============================================================================
/// 🧑💻 MEMBER 2 INTEGRATION SLOT: EXPLORE & SEARCH SCREEN
/// ============================================================================
/// This file hosts the Explore tab within Member 3's StatefulShellRoute.
/// Member 2 can plug in full discovery features, category filters, and live search.
/// ============================================================================

class ExploreScreenPlaceholder extends StatelessWidget {
  const ExploreScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Explore Universe', style: AppTypography.h2),
                    const SizedBox(height: 8),
                    Text(
                      'Search films, studio archives, live events & 4K documentaries.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 20),

                    // Search Bar Mock (Member 2 Hook)
                    FrostedGlass(
                      borderRadius: 16,
                      blur: 16,
                      backgroundColor: AppColors.cardSurface.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded, color: AppColors.cyanPrimary, size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search titles, actors, genres or studios...',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                            ),
                          ),
                          Icon(Icons.mic_none_rounded, color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Studio Badges
                    Text(
                      'STUDIOS & HUBS',
                      style: AppTypography.badge.copyWith(
                        color: AppColors.cyanPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStudioRow(),

                    const SizedBox(height: 28),

                    // Genre Filters (Member 2 Hook)
                    Text('Trending Genres', style: AppTypography.titleLarge),
                    const SizedBox(height: 14),
                    _buildGenreChips(),

                    const SizedBox(height: 28),

                    // Integration Box
                    FrostedGlass(
                      borderRadius: 16,
                      blur: 14,
                      backgroundColor: AppColors.surfaceDark.withOpacity(0.5),
                      border: Border.all(color: AppColors.cyanPrimary.withOpacity(0.3)),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.code_rounded, color: AppColors.cyanPrimary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Member 2 Ready Slot',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.cyanPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Replace this widget with your custom Explore / Search screen implementation in lib/screens/placeholders/explore_screen_placeholder.dart.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudioRow() {
    final studios = ['Aura Studios', 'HBO Max', 'Sci-Fi Hub', 'Anime Vault', 'Indie Room'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: studios.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.glassSurface,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Center(
              child: Text(
                studios[index],
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenreChips() {
    final genres = ['Action', 'Cyberpunk', 'Space Opera', 'Psychological', 'Anime', 'Horror'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: genres.map((g) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surfaceDark,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(g, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        );
      }).toList(),
    );
  }
}
