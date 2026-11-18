import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../widgets/glass_dock/dock_item.dart';
import '../../widgets/glass_dock/floating_frosted_dock.dart';

class MainAppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainAppShell({
    super.key,
    required this.navigationShell,
  });

  // 5 items matching the reference screenshot:
  // [Home, Live TV, Search, Equalizer/Trending, Settings/Profile]
  static const List<DockItemData> _dockItems = [
    DockItemData(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      routePath: RouteNames.home,
    ),
    DockItemData(
      icon: Icons.tv_rounded,
      activeIcon: Icons.tv_rounded,
      label: 'Live TV',
      routePath: RouteNames.explore,
    ),
    DockItemData(
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: 'Search',
      routePath: RouteNames.explore,
    ),
    DockItemData(
      icon: Icons.bar_chart_rounded,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Trending',
      routePath: RouteNames.downloads,
    ),
    DockItemData(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
      routePath: RouteNames.profile,
    ),
  ];

  void _onTabSelected(int index) {
    // Map 5 dock items to the 4 underlying GoRouter branches
    int branchIndex = index;
    if (index == 1 || index == 2) {
      branchIndex = 1; // Explore
    } else if (index == 3) {
      branchIndex = 2; // Downloads/Trending
    } else if (index == 4) {
      branchIndex = 3; // Profile
    }

    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  int _calculateDockIndex() {
    final branch = navigationShell.currentIndex;
    if (branch == 0) return 0; // Home
    if (branch == 1) return 1; // TV / Explore
    if (branch == 2) return 3; // Trending / Downloads
    if (branch == 3) return 4; // Settings / Profile
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The Nested Navigated Content of the Current Branch
          navigationShell,

          // Floating Frosted Glass Bottom Dock pinned above content
          FloatingFrostedDock(
            currentIndex: _calculateDockIndex(),
            onTabSelected: _onTabSelected,
            items: _dockItems,
          ),
        ],
      ),
    );
  }
}
