import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/route_names.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/frosted_glass.dart';
import '../../widgets/common/aura_logo.dart';

/// ============================================================================
/// 🧑💻 MEMBER 1 INTEGRATION SLOT: HOME SCREEN
/// ============================================================================
/// This file hosts the Home tab within Member 3's StatefulShellRoute.
/// Member 1 can replace or inject their custom Hero Carousels, Category Hubs,
/// and Content Rails directly here without altering the shell or dock!
/// ============================================================================

class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final activeProfile = context.watch<ProfileProvider>().activeProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Aura Logo, Search, and Active Profile Avatar
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.background.withOpacity(0.85),
            elevation: 0,
            leadingWidth: 160,
            leading: const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  AuraLogo(size: 28, showTagline: false, isAnimated: false),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.cast_rounded, color: Colors.white, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                onPressed: () {},
              ),
              // Profile Quick Avatar Button
              GestureDetector(
                onTap: () => context.go(RouteNames.whoIsWatching),
                child: Container(
                  margin: const EdgeInsets.only(right: 16, left: 4),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: activeProfile?.themeColor ?? AppColors.cyanPrimary,
                      width: 1.5,
                    ),
                    color: (activeProfile?.themeColor ?? AppColors.cyanPrimary).withOpacity(0.2),
                  ),
                  child: Icon(
                    activeProfile?.isKids == true
                        ? Icons.child_care_rounded
                        : Icons.person_rounded,
                    size: 18,
                    color: activeProfile?.themeColor ?? AppColors.cyanPrimary,
                  ),
                ),
              ),
            ],
          ),

          // Scrollable Content Feed
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- MEMBER 1 SLOT: Category / Channel Hub ---
                  _buildCategoryHub(),

                  const SizedBox(height: 20),

                  // --- MEMBER 1 SLOT: Hero Featured Banner ---
                  _buildHeroBanner(context),

                  const SizedBox(height: 28),

                  // --- MEMBER 1 SLOT: Live Channels & Matches Rail ---
                  _buildSectionHeader('Live Channels & Matches', hasLiveBadge: true),
                  const SizedBox(height: 12),
                  _buildLiveChannelsRail(),

                  const SizedBox(height: 28),

                  // --- MEMBER 1 SLOT: Popular in 4K UHD Rail ---
                  _buildSectionHeader('Popular in 4K Ultra HD'),
                  const SizedBox(height: 12),
                  _buildPopularRail(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Category / Channel Hub (Mock matching design reference)
  Widget _buildCategoryHub() {
    final categories = [
      {'name': 'Live Sports', 'icon': Icons.sports_soccer_rounded},
      {'name': 'Sci-Fi', 'icon': Icons.rocket_launch_rounded},
      {'name': 'Cinema', 'icon': Icons.movie_filter_rounded},
      {'name': 'Originals', 'icon': Icons.video_collection_rounded},
      {'name': 'Anime', 'icon': Icons.animation_rounded},
    ];

    return SizedBox(
      height: 94,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isFirst = index == 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceDark,
                  border: Border.all(
                    color: isFirst ? AppColors.cyanPrimary : AppColors.glassBorder,
                    width: 1.5,
                  ),
                  boxShadow: isFirst
                      ? [
                          BoxShadow(
                            color: AppColors.cyanPrimary.withOpacity(0.35),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  cat['icon'] as IconData,
                  size: 24,
                  color: isFirst ? AppColors.cyanPrimary : Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cat['name'] as String,
                style: AppTypography.badge.copyWith(
                  fontSize: 11,
                  color: isFirst ? AppColors.cyanPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Hero Featured Banner
  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1E36), Color(0xFF080C14)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: AppColors.glassBorderCyan.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyanPrimary.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Banner Background Glow
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyanPrimary.withOpacity(0.2),
              ),
            ),
          ),

          // Content & Controls
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.liveRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'LIVE PREMIERE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '4K UHD • Dolby Atmos',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.cyanPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('CHRONO HORIZON', style: AppTypography.h2.copyWith(fontSize: 22)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyanPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('Watch Now', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.glassBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('My List'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool hasLiveBadge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title, style: AppTypography.titleLarge),
              if (hasLiveBadge) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.liveRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildLiveChannelsRail() {
    return SizedBox(
      height: 124,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.cardSurface,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Match ${index + 1}', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.liveRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.liveRed, width: 0.8),
                      ),
                      child: const Text('LIVE', style: TextStyle(color: AppColors.liveRed, fontSize: 8)),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.graphic_eq_rounded, color: AppColors.cyanPrimary, size: 18),
                    SizedBox(width: 6),
                    Text('Live Atmos Feed', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularRail() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.cardSurface,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.movie_creation_outlined, color: AppColors.textMuted, size: 32),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.neonPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('4K HDR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
