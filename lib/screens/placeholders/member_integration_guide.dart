/// ============================================================================
/// 🎬 AURA STREAM - MEMBER INTEGRATION ARCHITECTURE GUIDE
/// ============================================================================
/// 
/// Developed by Member 3 (App Shell, Routing, Frosted Glass Dock, Auth & Profiles)
/// 
/// 📦 ARCHITECTURE SUMMARY:
/// ----------------------------------------------------------------------------
/// 1. App Shell & Routing:
///    - Managed via GoRouter with a `StatefulShellRoute.indexedStack`.
///    - State (scroll position, sub-views) is preserved across all 4 bottom tabs.
///    - The Floating Frosted Glass Bottom Dock renders over the active branch.
/// 
/// 2. Member 1 Hook (Home Screen & Content Rails):
///    - Target File: `lib/screens/placeholders/home_screen_placeholder.dart`
///    - Pre-built hooks:
///      * Category/Channel Hub (`_buildCategoryHub`)
///      * Hero Featured Banner (`_buildHeroBanner`)
///      * Live Channels & Matches Rail (`_buildLiveChannelsRail`)
///      * 4K Ultra HD Rail (`_buildPopularRail`)
///    - To integrate: Simply replace `HomeScreenPlaceholder` in `app_router.dart`
///      with your top-level Home Screen widget (or edit the placeholder directly).
/// 
/// 3. Member 2 Hook (Explore, Search & Details/Player):
///    - Target File: `lib/screens/placeholders/explore_screen_placeholder.dart`
///    - Pre-built hooks:
///      * Search Input Bar
///      * Studio Badges & Hubs
///      * Genre Filters
///    - Non-shell routes (like Fullscreen Player or Movie Details) should use
///      `parentNavigatorKey: rootNavigatorKey` in `app_router.dart` so they
///      overlay above the bottom dock.
/// 
/// 4. Shared State Access:
///    - Active Profile: `context.watch<ProfileProvider>().activeProfile`
///    - Auth State: `context.watch<AuthProvider>().isAuthenticated`
///    - Kids Mode Status: `profile.isKids`
/// 
/// ============================================================================

class MemberIntegrationGuide {
  static const String version = '1.0.0';
}
