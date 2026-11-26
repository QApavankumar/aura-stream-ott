import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/media_item.dart';
import '../../providers/profile_provider.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/common/cinema_image.dart';
import '../../widgets/glass_dock/dock_item.dart';
import '../../widgets/glass_dock/floating_frosted_dock.dart';

/// Responsive Minimal Cinema Noir Navigation Shell:
/// - Desktop/Tablet (>= 768px): Centered translucent top pill bar
///   (`AURA` left, `Home | Originals | Cinema | Sports | Library` center, Search & Avatar right).
/// - Mobile (< 768px): Floating monochrome bottom pill dock.
class MainAppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainAppShell({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  String _selectedDesktopHomePill = 'Home';

  static const List<DockItemData> _dockItems = [
    DockItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      routePath: RouteNames.home,
    ),
    DockItemData(
      icon: Icons.search_rounded,
      activeIcon: Icons.live_tv_rounded,
      label: 'Sports',
      routePath: RouteNames.explore,
    ),
    DockItemData(
      icon: Icons.video_library_outlined,
      activeIcon: Icons.video_library_rounded,
      label: 'Library',
      routePath: RouteNames.downloads,
    ),
    DockItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Account',
      routePath: RouteNames.profile,
    ),
  ];

  void _onBranchTap(int branchIndex, {String? pillLabel}) {
    if (pillLabel != null) {
      setState(() => _selectedDesktopHomePill = pillLabel);
    }
    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  Future<void> _openQuickSearch(BuildContext context) async {
    final data = await MockDataService.loadHomeFeed();
    if (!context.mounted) return;
    final catalog = <Movie>[
      data.hero,
      ...data.continueWatching,
      ...data.top10,
      const Movie(
        id: 'pop_solaris',
        title: 'SOLARIS',
        synopsis: 'An orbital psychologist encounters living memories orbiting a sentient twin star.',
        backdropUrl: 'assets/images/poster_solaris.jpg',
        posterUrl: 'assets/images/poster_solaris.jpg',
        genres: ['Sci-Fi', '4K Dolby Vision'],
        rating: '9.8',
        year: '2026',
        maturityRating: '16+',
        duration: '2h 18m',
      ),
      const Movie(
        id: 'pop_silent_sea',
        title: 'THE SILENT SEA',
        synopsis: 'An arctic research expedition uncovers a submerged signal beneath the polar ice shelf.',
        backdropUrl: 'assets/images/poster_silent_sea.jpg',
        posterUrl: 'assets/images/poster_silent_sea.jpg',
        genres: ['Thriller', 'Sci-Fi'],
        rating: '9.5',
        year: '2026',
        maturityRating: '16+',
        duration: '2h 08m',
      ),
      const Movie(
        id: 'pop_eclipse',
        title: 'ECLIPSE',
        synopsis: 'As the total shadow crosses the outer colonies, humanity races to reignite the solar array.',
        backdropUrl: 'assets/images/poster_eclipse.jpg',
        posterUrl: 'assets/images/poster_eclipse.jpg',
        genres: ['Sci-Fi', 'IMAX 4K'],
        rating: '9.6',
        year: '2026',
        maturityRating: '16+',
        duration: '2h 22m',
      ),
      const Movie(
        id: 'pop_nocturne',
        title: 'NOCTURNE',
        synopsis: 'A nocturnal archivist decodes encrypted broadcasts across a rain-soaked metropolis.',
        backdropUrl: 'assets/images/poster_nocturne.jpg',
        posterUrl: 'assets/images/poster_nocturne.jpg',
        genres: ['Mystery', 'Noir'],
        rating: '9.4',
        year: '2026',
        maturityRating: '18+',
        duration: '2h 04m',
      ),
      const Movie(
        id: 'pop_voyager',
        title: 'VOYAGER',
        synopsis: 'Humankind sends a deep-space vessel beyond the heliosphere toward Proxima Centauri.',
        backdropUrl: 'assets/images/poster_voyager.jpg',
        posterUrl: 'assets/images/poster_voyager.jpg',
        genres: ['Sci-Fi', 'Adventure'],
        rating: '9.9',
        year: '2026',
        maturityRating: 'PG-13',
        duration: '2h 36m',
      ),
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => _QuickSearchDialog(catalog: catalog),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 768;
    final activeBranch =
        widget.navigationShell.currentIndex.clamp(0, _dockItems.length - 1);

    final activeLabel = switch (activeBranch) {
      1 => 'Sports',
      2 => 'Library',
      3 => 'Account',
      _ => (_selectedDesktopHomePill == 'Originals' ||
              _selectedDesktopHomePill == 'Cinema')
          ? _selectedDesktopHomePill
          : 'Home',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: widget.navigationShell,
          ),

          // Desktop: Centered Noir Top Pill Navbar (`Home | Originals | Cinema | Sports | Library`)
          if (isDesktop)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _NoirDesktopNavBar(
                activeLabel: activeLabel,
                activeBranch: activeBranch,
                onSelectPill: (label, branch) =>
                    _onBranchTap(branch, pillLabel: label),
                onSearchTap: () => _openQuickSearch(context),
                onAccountTap: () => _onBranchTap(3),
              ),
            ),

          // Mobile: Compact Floating Pill Bottom Bar
          if (!isDesktop)
            FloatingFrostedDock(
              currentIndex: activeBranch,
              items: _dockItems,
              onTabSelected: (idx) => _onBranchTap(idx),
            ),
        ],
      ),
    );
  }
}

class _NoirDesktopNavBar extends StatelessWidget {
  final String activeLabel;
  final int activeBranch;
  final void Function(String label, int branch) onSelectPill;
  final VoidCallback onSearchTap;
  final VoidCallback onAccountTap;

  const _NoirDesktopNavBar({
    required this.activeLabel,
    required this.activeBranch,
    required this.onSelectPill,
    required this.onSearchTap,
    required this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final activeProfile = context.watch<ProfileProvider>().activeProfile;
    final avatarText = (activeProfile?.name.isNotEmpty ?? false)
        ? activeProfile!.name[0].toUpperCase()
        : 'A';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.fromLTRB(36, topPad + 12, 36, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.72),
                Colors.black.withValues(alpha: 0.25),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              // Brand Wordmark
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onSelectPill('Home', 0),
                  child: Text(
                    'AURA',
                    style: AppTypography.brandLogo(
                      fontSize: 20,
                      letterSpacing: 4.5,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Centered Translucent Nav Pill (`Home | Originals | Cinema | Sports | Library`)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0x9918181B),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DesktopNavPillItem(
                      label: 'Home',
                      isSelected: activeLabel == 'Home',
                      onTap: () => onSelectPill('Home', 0),
                    ),
                    _DesktopNavPillItem(
                      label: 'Originals',
                      isSelected: activeLabel == 'Originals',
                      onTap: () => onSelectPill('Originals', 0),
                    ),
                    _DesktopNavPillItem(
                      label: 'Cinema',
                      isSelected: activeLabel == 'Cinema',
                      onTap: () => onSelectPill('Cinema', 0),
                    ),
                    _DesktopNavPillItem(
                      label: 'Sports',
                      isSelected: activeLabel == 'Sports',
                      onTap: () => onSelectPill('Sports', 1),
                    ),
                    _DesktopNavPillItem(
                      label: 'Library',
                      isSelected: activeLabel == 'Library',
                      onTap: () => onSelectPill('Library', 2),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Right Utility Icons (Search + Account Avatar) matching screenshot
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavIconCircle(
                    icon: Icons.search_rounded,
                    tooltip: 'Search Catalog',
                    onTap: onSearchTap,
                  ),
                  const SizedBox(width: 10),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onAccountTap,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: activeProfile != null
                                ? [
                                    activeProfile.themeColor,
                                    Color.lerp(
                                      activeProfile.themeColor,
                                      Colors.black,
                                      0.35,
                                    )!,
                                  ]
                                : const [Color(0xFF27272A), Color(0xFF18181B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: activeBranch == 3
                                ? AppColors.noirWhite
                                : Colors.white.withValues(alpha: 0.25),
                            width: activeBranch == 3 ? 1.8 : 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          avatarText,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopNavPillItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesktopNavPillItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? AppColors.noirWhite
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconCircle extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _NavIconCircle({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _QuickSearchDialog extends StatefulWidget {
  final List<Movie> catalog;

  const _QuickSearchDialog({required this.catalog});

  @override
  State<_QuickSearchDialog> createState() => _QuickSearchDialogState();
}

class _QuickSearchDialogState extends State<_QuickSearchDialog> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.trim().isEmpty
        ? widget.catalog.take(6).toList()
        : widget.catalog
            .where((m) =>
                m.title.toLowerCase().contains(_query.toLowerCase()) ||
                m.genres.any(
                    (g) => g.toLowerCase().contains(_query.toLowerCase())))
            .toList();

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (val) => setState(() => _query = val),
                cursorColor: AppColors.noirWhite,
                style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search HORIZON ZERO, SOLARIS, ECLIPSE...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text(
                          'No matching titles found',
                          style: AppTypography.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final movie = results[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).pop();
                              context.push('/movie/${movie.id}', extra: movie);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 84,
                                      height: 50,
                                      child: CinemaImage(
                                        imageUrl: movie.backdropUrl,
                                        fit: BoxFit.cover,
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
                                          movie.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.titleLarge
                                              .copyWith(fontSize: 14),
                                        ),
                                        Text(
                                          '${movie.year} • ${movie.genres.join(', ')}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppColors.noirWhite,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
