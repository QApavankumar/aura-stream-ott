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

  // Default Fallback Hero Items matching the screenshot
  static const List<ModernHeroItem> _defaultHeroItems = [
    ModernHeroItem(
      id: 'chrono_horizon',
      title: 'CHRONO HORIZON',
      subtitle: 'The boundaries of space-time shatter in the deep orbit of Saturn.',
      badgeText: 'LIVE PREMIERE',
      formatInfo: '4K Ultra HD • Dolby Atmos',
      imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1600&q=80',
    ),
    ModernHeroItem(
      id: 'cyberpunk_neo',
      title: 'CYBERPUNK: NEO HORIZON',
      subtitle: 'A rogue synthetics detective unravels a corporate conspiracy.',
      badgeText: 'EXCLUSIVE 4K',
      formatInfo: '4K Ultra HD • HDR10+ • Dolby Vision',
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1600&q=80',
    ),
    ModernHeroItem(
      id: 'quantum_singularity',
      title: 'QUANTUM SINGULARITY',
      subtitle: 'Theoretical physicists accidentally open a stable wormhole in the Alps.',
      badgeText: 'TOP #1 TODAY',
      formatInfo: 'IMAX Enhanced • Dolby Atmos',
      imageUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&q=80',
    ),
  ];

  // Default Fallback Rail 1: Live Channels & Matches matching screenshot
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

  // Default Fallback Rail 2: Popular in 4K UHD matching screenshot
  static const List<Popular4kItem> _defaultPopular4k = [
    Popular4kItem(
      id: 'pop_01',
      title: 'Quantum Singularity',
      subtitle: 'Directed by Christopher Nolan',
      tag: 'Tags',
      imageUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=600&q=80',
      rating: '9.8',
      year: '2026',
    ),
    Popular4kItem(
      id: 'pop_02',
      title: 'Blade of the Ronin',
      subtitle: 'Feudal Cyberpunk Action',
      tag: 'Tags',
      imageUrl: 'https://images.unsplash.com/photo-1514539079130-25950c84af65?w=600&q=80',
      rating: '9.5',
      year: '2025',
    ),
    Popular4kItem(
      id: 'pop_03',
      title: 'Orbital Protocol: Redux',
      subtitle: 'Sci-Fi Survival Thriller',
      tag: 'Tags',
      imageUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=600&q=80',
      rating: '9.2',
      year: '2026',
    ),
    Popular4kItem(
      id: 'pop_04',
      title: 'Shadow Nexus: 2099',
      subtitle: 'Underground Synthetic Rebellion',
      tag: 'Tags',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&q=80',
      rating: '9.6',
      year: '2026',
    ),
    Popular4kItem(
      id: 'pop_05',
      title: 'The Infinite Dimension',
      subtitle: 'Cosmic Multiverse Odyssey',
      tag: 'Tags',
      imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&q=80',
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
          if (cloudHeroes.isNotEmpty) _heroItems = cloudHeroes;
          if (cloudMatches.isNotEmpty) _liveMatches = cloudMatches;
          if (cloudPopular.isNotEmpty) _popular4k = cloudPopular;
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
            side: const BorderSide(color: AppColors.cyanPrimary, width: 0.8),
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

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 1. Futuristic Glassmorphic Top App Bar
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

                  return RefreshIndicator(
                    color: AppColors.cyanPrimary,
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
                      // 120px clearance at bottom for the floating frosted glass dock
                      padding: const EdgeInsets.only(top: 14, bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- CATEGORY / CHANNEL HUB (TOP RAIL MATCHING SCREENSHOT) ---
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
                                    side: const BorderSide(color: AppColors.cyanPrimary, width: 0.8),
                                  ),
                                  content: Text(
                                    'Filtering by ${hub.label}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // --- MASSIVE HERO BANNER (CHRONO HORIZON MATCHING SCREENSHOT) ---
                          ModernHeroBanner(
                            items: _heroItems,
                            onWatchNow: _onWatchHeroNow,
                            onAddList: (hero) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.surfaceDark,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(milliseconds: 1200),
                                  content: Text('Updated "${hero.title}" in My List'),
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
                                rating: '9.9',
                                year: '2026',
                                duration: '2h 30m',
                                maturityRating: '16+',
                              );
                              _navigateToDetail(movie);
                            },
                          ),

                          const SizedBox(height: 32),

                          // --- RAIL 1: LIVE CHANNELS & MATCHES (WITH NEON SOUNDWAVE) ---
                          _buildRailHeader(
                            railTag: 'Rail 1',
                            title: 'Live Channels & Matches',
                            onTap: () {},
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 154,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
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

                          // --- RAIL 2: POPULAR IN 4K UHD (MATCHING SCREENSHOT) ---
                          _buildRailHeader(
                            railTag: 'Rail 2',
                            title: 'Popular in 4K UHD',
                            onTap: () {},
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 230,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _popular4k.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 16),
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
                                      genres: const ['4K UHD', 'Popular'],
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

                          const SizedBox(height: 32),

                          // --- RAIL 3: CONTINUE WATCHING (CROSS-DEVICE CLOUD SYNC) ---
                          if (continueWatchingList.isNotEmpty) ...[
                            _buildRailHeader(
                              railTag: 'Rail 3',
                              title: 'Continue Watching',
                              onTap: () {},
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 200,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            const SizedBox(height: 32),
                          ],

                          // --- RAIL 4: TOP 10 TODAY (DYNAMIC CLOUD SUPABASE CATALOG) ---
                          final effectiveTop10 = _cloudTop10.isNotEmpty
                              ? _cloudTop10
                              : (data?.top10 ?? <Movie>[]);
                          if (effectiveTop10.isNotEmpty) ...[
                            _buildRailHeader(
                              railTag: 'Rail 4',
                              title: 'Top 10 Today',
                              onTap: () {},
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 270,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
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
    required String railTag,
    required String title,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                railTag,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTypography.titleLarge.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: Colors.white,
                ),
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
                size: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
