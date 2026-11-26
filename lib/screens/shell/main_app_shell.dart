import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/glass_dock/dock_item.dart';
import '../../widgets/glass_dock/floating_frosted_dock.dart';

/// Responsive Minimal Cinema Noir Navigation Shell:
/// - Desktop/Tablet (>= 768px): Centered translucent top pill bar (`AURA` left, tabs center, search & avatar right).
/// - Mobile (< 768px): Floating monochrome bottom pill dock.
class MainAppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainAppShell({
    super.key,
    required this.navigationShell,
  });

  static const List<DockItemData> _dockItems = [
    DockItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      routePath: RouteNames.home,
    ),
    DockItemData(
      icon: Icons.sports_soccer_outlined,
      activeIcon: Icons.live_tv_rounded,
      label: 'Live & Sports',
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

  void _onBranchTap(int branchIndex) {
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 768;
    final activeBranch = navigationShell.currentIndex.clamp(0, _dockItems.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: navigationShell,
          ),

          // Desktop: Centered Noir Top Pill Navbar (Panels 1, 3, 5)
          if (isDesktop)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _NoirDesktopNavBar(
                activeBranch: activeBranch,
                onSelectBranch: _onBranchTap,
              ),
            ),

          // Mobile: Compact Floating Pill Bottom Bar
          if (!isDesktop)
            FloatingFrostedDock(
              currentIndex: activeBranch,
              items: _dockItems,
              onTabSelected: _onBranchTap,
            ),
        ],
      ),
    );
  }
}

class _NoirDesktopNavBar extends StatelessWidget {
  final int activeBranch;
  final ValueChanged<int> onSelectBranch;

  const _NoirDesktopNavBar({
    required this.activeBranch,
    required this.onSelectBranch,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final activeProfile = context.watch<ProfileProvider>().activeProfile;
    final avatarText =
        (activeProfile?.name.isNotEmpty ?? false) ? activeProfile!.name[0].toUpperCase() : 'A';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(28, topPad + 12, 28, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.78),
                Colors.black.withValues(alpha: 0.35),
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
                  onTap: () => onSelectBranch(0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AURA',
                        style: AppTypography.brandLogo(
                          fontSize: 20,
                          letterSpacing: 4.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Centered Translucent Nav Pill
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xCC111114),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.glassBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DesktopNavPillItem(
                      label: 'Home',
                      isSelected: activeBranch == 0,
                      onTap: () => onSelectBranch(0),
                    ),
                    _DesktopNavPillItem(
                      label: 'Live & Sports',
                      isSelected: activeBranch == 1,
                      hasLiveDot: true,
                      onTap: () => onSelectBranch(1),
                    ),
                    _DesktopNavPillItem(
                      label: 'Library',
                      isSelected: activeBranch == 2,
                      onTap: () => onSelectBranch(2),
                    ),
                    _DesktopNavPillItem(
                      label: 'Account',
                      isSelected: activeBranch == 3,
                      onTap: () => onSelectBranch(3),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Right Utility Icons (Profiles switcher + Account)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavIconCircle(
                    icon: Icons.switch_account_outlined,
                    tooltip: 'Switch Profile',
                    onTap: () => context.push(RouteNames.whoIsWatching),
                  ),
                  const SizedBox(width: 10),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onSelectBranch(3),
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
                                : AppColors.glassBorderBright,
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
  final bool hasLiveDot;
  final VoidCallback onTap;

  const _DesktopNavPillItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.hasLiveDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.noirWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasLiveDot) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.liveRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.background
                      : AppColors.textSecondary,
                ),
              ),
            ],
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
            decoration: BoxDecoration(
              color: const Color(0xCC111114),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Icon(icon, size: 17, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
