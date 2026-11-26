import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/route_names.dart';
import '../../models/media_item.dart';
import '../../providers/profile_provider.dart';
import '../../services/mock_data_service.dart';
import '../../services/supabase_media_service.dart';
import '../details/movie_detail_screen.dart';
import '../../widgets/feed/modern_top_app_bar.dart';
import '../../widgets/feed/modern_category_hub.dart';
import '../../widgets/feed/modern_hero_banner.dart';
import '../../widgets/feed/live_match_card.dart';
import '../../widgets/feed/popular_4k_card.dart';
import '../../widgets/feed/continue_watching_card.dart';
import '../../widgets/feed/top_ten_card.dart';

/// Next-Gen High-Fidelity Home Screen Feed for Aura Stream.
///
/// Pixel-perfect implementation based on the Aura Stream OTT UI reference:
/// 1. Futuristic Glassmorphic Top App Bar with AURA STREAM logo, Search pill,
///    Notification alert dot, and Profile avatar with glowing halo ring.
/// 2. Category / Channel Hub with circular glowing hubs (Live Sports, Sci-Fi,
///    Cinema, Originals, Indie, HBO Studio, and Story Bubbles).
/// 3. Massive Hero Banner featuring "CHRONO HORIZON" with centered floating
///    Frosted Glass HUD ("🔴 LIVE PREMIERE", "4K Ultra HD • Dolby Atmos",
///    "Watch Now", and "+ List").
/// 4. Rail 1: "Live Channels & Matches" with widescreen cards, LIVE status pills,
///    and dynamic animated neon soundwave equalizer visualizers.
/// 5. Rail 2: "Popular in 4K UHD" with high-contrast cinematic movie cards and
///    purple "Tags" / "4K HDR" badges.
/// 6. Continue Watching & Top 10 Today rails with neon progress bars and rankings.
/// 7. 60 FPS fluid rendering, zero lag, full keyboard/mouse/touch support.
class HomeScreenFeed extends StatefulWidget {
  final bool showAppBar;
  final void Function(Movie item)? onMovieSelected;
  final void Function(Movie item)? onPlayMovie;
  final void Function(StoryHub hub)? onHubSelected;

  const HomeScreenFeed({
    super.key,
    this.showAppBar = true,
    this.onMovieSelected,
    this.onPlayMovie,
    this.onHubSelected,
  });

  @override
  State<HomeScreenFeed> createState() => _HomeScreenFeedState();
}

/// Backward compatibility alias for Member 2 code.
typedef HomeFeedScreen = HomeScreenFeed;

class _HomeScreenFeedState extends State<HomeScreenFeed> {
  final SupabaseMediaService _mediaService = SupabaseMediaService();
  late Future<HomeFeedData> _feedDataFuture;
  String _searchQuery = '';
  StreamSubscription? _moviesSubscription;

  late List<ModernHeroItem> _heroItems;
  late List<LiveMatchItem> _liveMatches;
  late List<Popular4kItem> _popular4k;
  List<Movie> _cloudTop10 = [];
  List<Movie> _cloudContinueWatching = [];

  // Reference Hubs matching the screenshot
  static const List<ModernHubItem> _hubItems = [
    ModernHubItem(
      id: 'hub_sports',
      label: 'Live Sports',
      type: HubType.icon,
      icon: Icons.sports_soccer_rounded,
      glowColor: Color(0xFF00F2FE),
    ),
    ModernHubItem(
      id: 'hub_scifi',
      label: 'Sci-Fi',
      type: HubType.icon,
      icon: Icons.rocket_launch_rounded,
      glowColor: Color(0xFF00F2FE),
    ),
    ModernHubItem(
      id: 'hub_cinema',
      label: 'Cinema',
      type: HubType.icon,
      icon: Icons.movie_filter_rounded,
      glowColor: Color(0xFF00F2FE),
    ),
    ModernHubItem(
      id: 'hub_originals',
      label: 'Originals',
      type: HubType.icon,
      icon: Icons.video_camera_back_rounded,
      glowColor: Color(0xFF00F2FE),
    ),
    ModernHubItem(
      id: 'hub_indie',
      label: 'Indie Room',
      type: HubType.icon,
      icon: Icons.play_arrow_rounded,
      glowColor: Color(0xFF4FACFE),
    ),
    ModernHubItem(
      id: 'hub_hbo',
      label: 'Studio Badge',
      type: HubType.textBadge,
      badgeText: 'HBO',
      glowColor: Color(0xFF9D4EDD),
    ),
    ModernHubItem(
      id: 'hub_anime',
      label: 'Anime',
      type: HubType.icon,
      icon: Icons.auto_awesome_rounded,
      glowColor: Color(0xFFFF5252),
    ),
    ModernHubItem(
      id: 'bubble_scifi',
      label: 'Story bubbles',
      badgeText: 'Sci-Fi',
      type: HubType.storyBubbleCapsule,
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=200&q=80',
      glowColor: Color(0xFF00F2FE),
    ),
    ModernHubItem(
      id: 'bubble_showy',
      label: 'Story bubbles',
      badgeText: 'Showy',
      type: HubType.storyBubbleCapsule,
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=200&q=80',
      glowColor: Color(0xFF9D4EDD),
    ),
    ModernHubItem(
      id: 'bubble_anime',
      label: 'Anime',
      type: HubType.storyAvatar,
      imageUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=200&q=80',
      glowColor: Color(0xFF00F2FE),
    ),
  ];

  // Default Hero Items matching the Minimal Cinema Noir Home reference
  static const List<ModernHeroItem> _defaultHeroItems = [
    ModernHeroItem(
      id: 'horizon_zero',
      title: 'HORIZON ZERO',
      subtitle: 'A lone deep-space surveyor confronts an ancient obsidian monolith above an uncharted canyon.',
      badgeText: '4K DOLBY VISION',
      formatInfo: '2026 • Sci-Fi • 4K Dolby Vision',
      imageUrl: 'assets/images/hero_horizon_zero.jpg',
    ),
    ModernHeroItem(
      id: 'solaris',
      title: 'SOLARIS',
      subtitle: 'An orbital psychologist encounters living memories orbiting a sentient twin star.',
      badgeText: 'AURA ORIGINAL',
      formatInfo: '2026 • Sci-Fi • 4K Dolby Vision',
      imageUrl: 'assets/images/poster_solaris.jpg',
    ),
    ModernHeroItem(
      id: 'eclipse',
      title: 'ECLIPSE',
      subtitle: 'As the total shadow crosses the outer colonies, humanity races to reignite the solar array.',
      badgeText: 'IMAX ENHANCED',
      formatInfo: '2026 • Thriller • Dolby Atmos',
      imageUrl: 'assets/images/poster_eclipse.jpg',
    ),
  ];

  // Default Rail 1: Live Channels & Matches
  static const List<LiveMatchItem> _defaultLiveMatches = [
    LiveMatchItem(
      id: 'live_01',
      title: 'Champions League: Real Madrid vs Man City',
      subtitle: 'Semifinal Leg 2 • Santiago Bernabéu',
      imageUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800&q=80',
      isRedBadge: false,
      statusText: 'LIVE',
      channel: 'Aura Sport 1 HD',
    ),
    LiveMatchItem(
      id: 'live_02',
      title: 'Premier League: Arsenal vs Liverpool',
      subtitle: 'Emirates Stadium • Live Atmos Feed',
      imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
      isRedBadge: true,
      statusText: 'LIVE',
      channel: 'Aura Premier',
    ),
    LiveMatchItem(
      id: 'live_03',
      title: 'Derby della Madonnina: Milan vs Inter',
      subtitle: 'San Siro • Multicam Ultra HD',
      imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800&q=80',
      isRedBadge: false,
      statusText: 'LIVE',
      channel: 'Aura Calcio',
    ),
    LiveMatchItem(
      id: 'live_04',
      title: 'Global Cyber Invitational: Grand Finals',
      subtitle: 'Neo Tokyo Arena • Live Crowd Audio',
      imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&q=80',
      isRedBadge: true,
      statusText: 'LIVE',
      channel: 'Esports 4K',
    ),
    LiveMatchItem(
      id: 'live_05',
      title: 'Formula 1: Monaco Grand Prix Qualifiers',
      subtitle: 'Circuit de Monaco • Onboard Cameras',
      imageUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800&q=80',
      isRedBadge: false,
      statusText: 'LIVE',
      channel: 'F1 Live 4K',
    ),
  ];

  // Featured in 4K Posters matching screenshot (SOLARIS, THE SILENT SEA, ECLIPSE, NOCTURNE, VOYAGER)
  static const List<Popular4kItem> _defaultPopular4k = [
    Popular4kItem(
      id: 'pop_solaris',
      title: 'SOLARIS',
      subtitle: 'Sci-Fi • 4K Dolby Vision',
      tag: '4K HDR',
      imageUrl: 'assets/images/poster_solaris.jpg',
      rating: '9.8',
      year: '2026',
    ),
    Popular4kItem(
      id: 'pop_silent_sea',
      title: 'THE SILENT SEA',
      subtitle: 'Nordic Survival • 4K HDR',
      tag: '4K HDR',
      imageUrl: 'assets/images/poster_silent_sea.jpg',
      rating: '9.5',
      year: '2026',
    ),
    Popular4kItem(
      id: 'pop_eclipse',
      title: 'ECLIPSE',
      subtitle: 'Cosmic Thriller • IMAX 4K',
      tag: 'IMAX 4K',
      imageUrl: 'assets/images/poster_eclipse.jpg',
      rating: '9.6',
      year: '2026',
    ),
    Popular4kItem(
      id: 'pop_nocturne',
      title: 'NOCTURNE',
      subtitle: 'Neo-Noir Mystery • 4K',
      tag: '4K UHD',
      imageUrl: 'assets/images/poster_nocturne.jpg',
      rating: '9.4',
      year: '2026',
    ),
    Popular4kItem(
      id: 'pop_voyager',
      title: 'VOYAGER',
      subtitle: 'Deep Space Odyssey • Atmos',
      tag: '4K ATMOS',
      imageUrl: 'assets/images/poster_voyager.jpg',
      rating: '9.9',
      year: '2026',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _heroItems = List.from(_defaultHeroItems);
    _liveMatches = List.from(_defaultLiveMatches);
    _popular4k = List.from(_defaultPopular4k);
    _feedDataFuture = MockDataService.loadHomeFeed();
    _loadCloudContent();

    // Listen to real-time changes on the Supabase movies catalog
    _moviesSubscription = _mediaService.watchMovies()?.listen((_) {
      debugPrint('[HomeScreenFeed] Real-time Supabase update detected. Reloading feed...');
      _loadCloudContent();
    });
  }

  @override
  void dispose() {
    _moviesSubscription?.cancel();
    super.dispose();
  }

  /// Dynamically load live catalog & continue watching from Supabase Cloud
  Future<void> _loadCloudContent() async {
    if (!_mediaService.isReady) return;

    try {
      final cloudHeroes = await _mediaService.fetchHeroItems();
      final cloudMatches = await _mediaService.fetchLiveMatches();
      final cloudPopular = await _mediaService.fetchPopular4k();
      final cloudTop10 = await _mediaService.fetchTop10();

      final profile = context.read<ProfileProvider>().activeProfile;
      List<Movie> continueWatching = [];
      if (profile != null) {
        continueWatching = await _mediaService.fetchContinueWatching(profileId: profile.id);
      }

      if (mounted) {
        setState(() {
          // Keep curated HORIZON ZERO hero + Featured in 4K showcase first,
          // appending live Supabase entries so DB edits also appear seamlessly.
          if (cloudHeroes.isNotEmpty) {
            final extraHeroes = cloudHeroes
                .where((h) => h.id != _defaultHeroItems.first.id)
                .toList();
            _heroItems = [_defaultHeroItems.first, ...extraHeroes];
          }
          if (cloudMatches.isNotEmpty) _liveMatches = cloudMatches;
          if (cloudPopular.isNotEmpty) {
            final knownTitles = _defaultPopular4k
                .map((e) => e.title.toLowerCase())
                .toSet();
            final extraPopular = cloudPopular
                .where((p) => !knownTitles.contains(p.title.toLowerCase()))
                .toList();
            _popular4k = [..._defaultPopular4k, ...extraPopular];
          }
          if (cloudTop10.isNotEmpty) _cloudTop10 = cloudTop10;
          if (continueWatching.isNotEmpty) _cloudContinueWatching = continueWatching;
        });
      }
    } catch (e) {
      debugPrint('[HomeScreenFeed] Cloud content fetch error: $e');
    }
  }

  void _navigateToDetail(Movie item) {
    if (widget.onMovieSelected != null) {
      widget.onMovieSelected!(item);
      return;
    }

    try {
      context.push('/movie/${item.id}', extra: item);
    } catch (_) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MovieDetailScreen(item: item),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.08);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        ),
      );
    }
  }

  void _onPlayMovie(Movie item) {
    if (widget.onPlayMovie != null) {
      widget.onPlayMovie!(item);
      return;
    }

    try {
      context.push('/player', extra: item);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.glassBorder, width: 0.8),
          ),
          content: Text(
            'Starting streaming for "${item.title}"...',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onWatchHeroNow(ModernHeroItem hero) {
    final movie = Movie(
      id: hero.id,
      title: hero.title,
      synopsis: hero.subtitle,
      backdropUrl: hero.imageUrl,
      posterUrl: hero.imageUrl,
      genres: const ['Sci-Fi', 'Action', '4K UHD'],
      rating: '9.9',
      year: '2026',
      duration: '2h 30m',
      maturityRating: '16+',
      badge: hero.badgeText,
    );
    _onPlayMovie(movie);
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = context.watch<ProfileProvider>().activeProfile;
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (!isDesktop || widget.showAppBar)
              ModernTopAppBar(
                activeProfile: activeProfile,
                onSearch: (query) => setState(() => _searchQuery = query),
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.surfaceDark,
                      behavior: SnackBarBehavior.floating,
                      content: const Text('Notifications: 2 Live Premieres Scheduled Today!'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                onProfileTap: () => context.go(RouteNames.whoIsWatching),
              ),

            // 2. Scrollable Body
            Expanded(
              child: FutureBuilder<HomeFeedData>(
                future: _feedDataFuture,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  final continueWatchingList = _cloudContinueWatching.isNotEmpty
                      ? _cloudContinueWatching
                      : (data?.continueWatching ?? <Movie>[]);
                  final effectiveTop10 = _cloudTop10.isNotEmpty
                      ? _cloudTop10
                      : (data?.top10 ?? <Movie>[]);

                  return RefreshIndicator(
                    color: AppColors.noirWhite,
                    backgroundColor: AppColors.surfaceDark,
                    onRefresh: () async {
                      MockDataService.invalidateCache();
                      await _loadCloudContent();
                      setState(() {
                        _feedDataFuture = MockDataService.loadHomeFeed();
                      });
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 0, bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- EDGE-TO-EDGE NOIR HERO BANNER (HORIZON ZERO) ---
                          ModernHeroBanner(
                            items: _heroItems,
                            onWatchNow: _onWatchHeroNow,
                            onAddList: (hero) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.surfaceDark,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(milliseconds: 1200),
                                  content: Text('Added "${hero.title}" to Watchlist'),
                                ),
                              );
                            },
                            onTap: (hero) {
                              final movie = Movie(
                                id: hero.id,
                                title: hero.title,
                                synopsis: hero.subtitle,
                                backdropUrl: hero.imageUrl,
                                posterUrl: hero.imageUrl,
                                genres: const ['Sci-Fi', 'Action'],
                                rating: '9.8',
                                year: '2026',
                                duration: '2h 28m',
                                maturityRating: '16+',
                              );
                              _navigateToDetail(movie);
                            },
                          ),

                          const SizedBox(height: 18),

                          // --- RAIL 1: CONTINUE WATCHING (MATCHING SCREENSHOT) ---
                          if (continueWatchingList.isNotEmpty) ...[
                            _buildRailHeader(
                              title: 'Continue Watching',
                              onTap: () {},
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: isDesktop ? 152 : 132,
                              child: ListView.separated(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 36 : 20,
                                ),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: continueWatchingList.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final item = continueWatchingList[index];
                                  return ContinueWatchingCard(
                                    item: item,
                                    onTap: () => _navigateToDetail(item),
                                    onPlayTap: () => _onPlayMovie(item),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 22),
                          ],

                          // --- RAIL 2: FEATURED IN 4K (MATCHING SCREENSHOT) ---
                          _buildRailHeader(
                            title: 'Featured in 4K',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: isDesktop ? 144 : 124,
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 36 : 20,
                              ),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _popular4k.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final item = _popular4k[index];
                                return Popular4kCard(
                                  item: item,
                                  onTap: () {
                                    final movie = Movie(
                                      id: item.id,
                                      title: item.title,
                                      synopsis: item.subtitle,
                                      backdropUrl: item.imageUrl,
                                      posterUrl: item.imageUrl,
                                      genres: const ['4K UHD', 'Sci-Fi'],
                                      rating: item.rating,
                                      year: item.year,
                                      duration: '2h 15m',
                                      maturityRating: '16+',
                                    );
                                    _navigateToDetail(movie);
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- GENRE FILTER PILLS (BELOW FOLD) ---
                          ModernCategoryHub(
                            items: _hubItems,
                            onSelect: (hub) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.surfaceDark,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(milliseconds: 900),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: AppColors.glassBorder, width: 0.8),
                                  ),
                                  content: Text(
                                    'Filtering by ${hub.label}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 28),

                          // --- RAIL 3: LIVE CHANNELS & SPORTS ---
                          _buildRailHeader(
                            railTag: 'LIVE BROADCASTS',
                            title: 'Live Channels & Matches',
                            onTap: () => context.go(RouteNames.explore),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 240,
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 36 : 20,
                              ),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _liveMatches.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final match = _liveMatches[index];
                                return LiveMatchCard(
                                  item: match,
                                  onTap: () {
                                    final movie = Movie(
                                      id: match.id,
                                      title: match.title,
                                      synopsis: match.subtitle,
                                      backdropUrl: match.imageUrl,
                                      posterUrl: match.imageUrl,
                                      genres: const ['Live Sports', 'Football'],
                                      rating: '10.0',
                                      year: '2026',
                                      duration: '90m',
                                      maturityRating: 'All',
                                    );
                                    _onPlayMovie(movie);
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 32),

                          // --- RAIL 4: TOP 10 TODAY (DYNAMIC CLOUD SUPABASE CATALOG) ---
                          if (effectiveTop10.isNotEmpty) ...[
                            _buildRailHeader(
                              railTag: 'MOST WATCHED',
                              title: 'Top 10 Today',
                              onTap: () {},
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 286,
                              child: ListView.separated(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 36 : 20,
                                ),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: effectiveTop10.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final item = effectiveTop10[index];
                                  return TopTenCard(
                                    item: item,
                                    onTap: () => _navigateToDetail(item),
                                  );
                                },
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildRailHeader({
    String? railTag,
    required String title,
    VoidCallback? onTap,
  }) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 36 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (railTag != null) ...[
                Text(
                  railTag,
                  style: AppTypography.badge.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                title,
                style: AppTypography.h2.copyWith(fontSize: 19),
              ),
            ],
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
