import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/route_names.dart';
import '../../models/media_item.dart';
import '../../services/supabase_media_service.dart';
import '../../widgets/common/frosted_glass.dart';

class DownloadItem {
  final String id;
  final String title;
  final String episode;
  final String size;
  final String format;
  final String imageUrl;
  final Movie movie;

  const DownloadItem({
    required this.id,
    required this.title,
    required this.episode,
    required this.size,
    required this.format,
    required this.imageUrl,
    required this.movie,
  });
}

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _smartDownloads = true;
  bool _wifiOnly = true;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', '4K Movies', 'Series', 'Sports'];

  // In-progress download state
  bool _isDownloading = true;
  bool _isDownloadPaused = false;
  double _downloadProgress = 0.68;
  final String _downloadTitle = 'Cyberpunk: Neo Horizon';
  final String _downloadEpisode = 'Season 1 • Ep 3 "Ghost Protocol"';
  final String _downloadSpeed = '28.4 MB/s • 2.4 / 3.5 GB (ETA 42s)';

  // Downloaded items list
  late List<DownloadItem> _downloads;

  // Trending offline recommendations
  static const List<Movie> _defaultTrendingOffline = [
    Movie(
      id: 'trend_off_01',
      title: 'Orbital Protocol: Redux',
      synopsis: 'Deep space station telemetry mystery.',
      backdropUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=800&q=80',
      posterUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=400&q=80',
      genres: ['Sci-Fi', 'Thriller'],
      rating: '9.4',
      year: '2026',
      duration: '2h 10m',
      maturityRating: '16+',
    ),
    Movie(
      id: 'trend_off_02',
      title: 'Shadow Nexus: 2099',
      synopsis: 'Underground cyber rebellion in Neo Tokyo.',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&q=80',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=400&q=80',
      genres: ['Action', 'Cyberpunk'],
      rating: '9.6',
      year: '2026',
      duration: '1h 55m',
      maturityRating: '18+',
    ),
    Movie(
      id: 'trend_off_03',
      title: 'Formula 1: Monaco GP Qualifiers',
      synopsis: 'Full 4K HDR onboard telemetry capture.',
      backdropUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800&q=80',
      posterUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=400&q=80',
      genres: ['Sports', 'F1 Racing'],
      rating: '9.9',
      year: '2026',
      duration: '1h 45m',
      maturityRating: 'All',
    ),
    Movie(
      id: 'trend_off_04',
      title: 'The Infinite Dimension',
      synopsis: 'Cosmic multiverse voyage through black hole accretion.',
      backdropUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&q=80',
      posterUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&q=80',
      genres: ['Documentary', 'Cosmic'],
      rating: '9.9',
      year: '2026',
      duration: '1h 38m',
      maturityRating: 'All',
    ),
  ];

  late List<Movie> _trendingOffline;
  final Set<String> _downloadingIds = {};

  @override
  void initState() {
    super.initState();
    _trendingOffline = List.from(_defaultTrendingOffline);
    _loadCloudRecommendations();
    _downloads = [
      DownloadItem(
        id: 'dl_01',
        title: 'Chrono Horizon',
        episode: 'Season 1 • Episode 1 "Event Horizon"',
        size: '4.2 GB',
        format: '4K UHD • Dolby Atmos',
        imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&q=80',
        movie: const Movie(
          id: 'chrono_horizon',
          title: 'Chrono Horizon',
          synopsis: 'The boundaries of space-time shatter in the deep orbit of Saturn.',
          backdropUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1600&q=80',
          posterUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&q=80',
          genres: ['Sci-Fi', 'Action'],
          rating: '9.9',
          year: '2026',
          duration: '2h 30m',
          maturityRating: '16+',
        ),
      ),
      DownloadItem(
        id: 'dl_02',
        title: 'Quantum Singularity',
        episode: 'Feature Film (Director\'s Cut)',
        size: '5.8 GB',
        format: '4K IMAX • Dolby Vision',
        imageUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=400&q=80',
        movie: const Movie(
          id: 'quantum_singularity',
          title: 'Quantum Singularity',
          synopsis: 'Theoretical physicists open a stable wormhole in the Alps.',
          backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&q=80',
          posterUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=400&q=80',
          genres: ['Sci-Fi', 'Thriller'],
          rating: '9.8',
          year: '2026',
          duration: '2h 45m',
          maturityRating: '16+',
        ),
      ),
      DownloadItem(
        id: 'dl_03',
        title: 'Blade of the Ronin',
        episode: 'Season 1 • Episode 1 & 2',
        size: '3.4 GB',
        format: '4K HDR • Spatial Audio',
        imageUrl: 'https://images.unsplash.com/photo-1514539079130-25950c84af65?w=400&q=80',
        movie: const Movie(
          id: 'blade_ronin',
          title: 'Blade of the Ronin',
          synopsis: 'Feudal cyberpunk action in neon Neo-Kyoto.',
          backdropUrl: 'https://images.unsplash.com/photo-1514539079130-25950c84af65?w=1600&q=80',
          posterUrl: 'https://images.unsplash.com/photo-1514539079130-25950c84af65?w=400&q=80',
          genres: ['Action', 'Anime'],
          rating: '9.5',
          year: '2025',
          duration: '1h 40m',
          maturityRating: '18+',
        ),
      ),
      DownloadItem(
        id: 'dl_04',
        title: 'Champions League: Real vs Man City',
        episode: 'Full Match Replay • Atmos Broadcast',
        size: '4.6 GB',
        format: '4K UHD 60 FPS • Multi-Audio',
        imageUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&q=80',
        movie: const Movie(
          id: 'live_01',
          title: 'Champions League: Real Madrid vs Man City',
          synopsis: 'Semifinal Leg 2 • Santiago Bernabéu',
          backdropUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=1600&q=80',
          posterUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&q=80',
          genres: ['Live Sports', 'Football'],
          rating: '10.0',
          year: '2026',
          duration: '1h 50m',
          maturityRating: 'All',
        ),
      ),
    ];
  }

  Future<void> _loadCloudRecommendations() async {
    try {
      final cloudMovies = await SupabaseMediaService().fetchMovies();
      if (cloudMovies.isNotEmpty && mounted) {
        setState(() {
          _trendingOffline = cloudMovies;
        });
      }
    } catch (_) {}
  }

  void _playMedia(Movie movie) {
    try {
      context.push(RouteNames.player, extra: movie);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceDark,
          behavior: SnackBarBehavior.floating,
          content: Text('Starting offline playback: ${movie.title}'),
        ),
      );
    }
  }

  void _deleteDownload(DownloadItem item) {
    setState(() {
      _downloads.removeWhere((d) => d.id == item.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cyanPrimary, width: 0.8),
        ),
        content: Text('Deleted "${item.title}" (${item.size} freed)'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.cyanPrimary,
          onPressed: () {
            setState(() {
              _downloads.add(item);
            });
          },
        ),
      ),
    );
  }

  void _startDownload(Movie movie) {
    if (_downloadingIds.contains(movie.id)) return;

    setState(() {
      _downloadingIds.add(movie.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cyanPrimary, width: 0.8),
        ),
        content: Row(
          children: [
            const Icon(Icons.downloading_rounded, color: AppColors.cyanPrimary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Downloading "${movie.title}" in 4K UHD...',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // Simulate completion after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _downloadingIds.remove(movie.id);
          _downloads.insert(
            0,
            DownloadItem(
              id: 'dl_${DateTime.now().millisecondsSinceEpoch}',
              title: movie.title,
              episode: 'Downloaded in 4K UHD',
              size: '3.9 GB',
              format: '4K UHD • Dolby Atmos',
              imageUrl: movie.posterUrl,
              movie: movie,
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.success, width: 1.0),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '"${movie.title}" is ready to watch offline!',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TOP BAR & HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'AURA OFFLINE',
                                style: AppTypography.badge.copyWith(
                                  color: AppColors.cyanPrimary,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.cyanPrimary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.cyanPrimary.withOpacity(0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Text(
                                  '4K DOLBY',
                                  style: TextStyle(
                                    color: AppColors.cyanPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Downloads & Storage',
                            style: AppTypography.h2.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // Top Action Pill Buttons
                      Row(
                        children: [
                          _buildActionIconButton(
                            icon: Icons.search_rounded,
                            tooltip: 'Search Downloads',
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _buildActionIconButton(
                            icon: Icons.tune_rounded,
                            tooltip: 'Download Preferences',
                            onTap: _showPreferencesModal,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // --- STORAGE BREAKDOWN HOLOGRAM CARD ---
                  _buildStorageHologramCard(),

                  const SizedBox(height: 26),

                  // --- ACTIVE DOWNLOAD IN PROGRESS (IF ANY) ---
                  if (_isDownloading) ...[
                    _buildSectionHeader(
                      title: 'IN PROGRESS',
                      badge: '1 ACTIVE',
                      badgeColor: AppColors.cyanPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildActiveDownloadCard(),
                    const SizedBox(height: 28),
                  ],

                  // --- FILTER CHIPS FOR DOWNLOADED LIBRARY ---
                  _buildFilterChips(),

                  const SizedBox(height: 16),

                  // --- READY TO WATCH OFFLINE LIST ---
                  _buildSectionHeader(
                    title: 'READY TO WATCH OFFLINE',
                    badge: '${_downloads.length} TITLES • 18.0 GB',
                    badgeColor: AppColors.success,
                  ),
                  const SizedBox(height: 14),

                  if (_downloads.isEmpty)
                    _buildEmptyState()
                  else
                    ..._downloads.map((item) => _buildDownloadCard(item)),

                  const SizedBox(height: 32),

                  // --- TRENDING FOR OFFLINE TRIPS CAROUSEL ---
                  _buildSectionHeader(
                    title: 'TRENDING FOR OFFLINE TRIPS',
                    badge: 'RECOMMENDED 4K',
                    badgeColor: AppColors.neonPurple,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _trendingOffline.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final movie = _trendingOffline[index];
                        return _buildTrendingOfflineCard(movie);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder, width: 1.0),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      ),
    );
  }

  // --- STORAGE HOLOGRAM CARD ---
  Widget _buildStorageHologramCard() {
    return FrostedGlass(
      borderRadius: 22,
      blur: 20,
      backgroundColor: AppColors.surfaceDark.withOpacity(0.75),
      border: Border.all(color: AppColors.glassBorderCyan.withOpacity(0.4), width: 1.0),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.cyanPrimary.withOpacity(0.15),
                      border: Border.all(color: AppColors.cyanPrimary.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.sd_storage_rounded, color: AppColors.cyanPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Device Storage Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Fast NVMe • 85.2 GB Available',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.4),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Text(
                  '42.8 GB / 128 GB',
                  style: TextStyle(
                    color: AppColors.cyanPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Multi-Segmented Storage Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  // 4K Movies (Cyan)
                  Flexible(
                    flex: 28,
                    child: Container(
                      color: AppColors.cyanPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  // TV Shows (Purple)
                  Flexible(
                    flex: 16,
                    child: Container(
                      color: AppColors.neonPurple,
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Atmos Audio / Cache (Amber)
                  Flexible(
                    flex: 5,
                    child: Container(
                      color: AppColors.kidsModeAmber,
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Free space (Glass Dark)
                  Flexible(
                    flex: 51,
                    child: Container(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStorageLegendDot(color: AppColors.cyanPrimary, label: '4K Movies (28.4 GB)'),
              _buildStorageLegendDot(color: AppColors.neonPurple, label: 'Series (16.2 GB)'),
              _buildStorageLegendDot(color: Colors.white.withOpacity(0.3), label: 'Free (85.2 GB)'),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: 14),

          // Smart Downloads Switch Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.cyanPrimary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Downloads',
                            style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Auto-deletes watched episodes & auto-fetches next on Wi-Fi',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _smartDownloads,
                activeColor: AppColors.cyanPrimary,
                onChanged: (val) => setState(() => _smartDownloads = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageLegendDot({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  // --- ACTIVE DOWNLOAD IN PROGRESS ---
  Widget _buildActiveDownloadCard() {
    return FrostedGlass(
      borderRadius: 18,
      blur: 16,
      backgroundColor: AppColors.cardSurface.withOpacity(0.7),
      border: Border.all(
        color: _isDownloadPaused
            ? AppColors.warning.withOpacity(0.4)
            : AppColors.cyanPrimary.withOpacity(0.5),
        width: 1.0,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=400&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: Center(
                    child: _isDownloadPaused
                        ? const Icon(Icons.pause_circle_rounded, color: AppColors.warning, size: 24)
                        : const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyanPrimary),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _downloadTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: (_isDownloadPaused ? AppColors.warning : AppColors.cyanPrimary)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isDownloadPaused ? 'PAUSED' : '68%',
                            style: TextStyle(
                              color: _isDownloadPaused ? AppColors.warning : AppColors.cyanPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _downloadEpisode,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Pause / Resume Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isDownloadPaused = !_isDownloadPaused;
                  });
                },
                icon: Icon(
                  _isDownloadPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: _isDownloadPaused ? 'Resume' : 'Pause',
              ),
              // Cancel Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isDownloading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.surfaceDark,
                      behavior: SnackBarBehavior.floating,
                      content: Text('Canceled download for Cyberpunk: Neo Horizon'),
                    ),
                  );
                },
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                tooltip: 'Cancel Download',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Glowing Progress Bar
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _downloadProgress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isDownloadPaused ? AppColors.warning : AppColors.cyanPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isDownloadPaused ? 'Paused by user' : _downloadSpeed,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const Text(
                '4K HDR10+ • 10-Bit HEVC',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- FILTER CHIPS ---
  Widget _buildFilterChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return InkWell(
            onTap: () => setState(() => _selectedFilterIndex = index),
            borderRadius: BorderRadius.circular(17),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: isSelected ? AppColors.cyanPrimary : AppColors.surfaceDark.withOpacity(0.6),
                border: Border.all(
                  color: isSelected ? AppColors.cyanPrimary : AppColors.glassBorder,
                  width: 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.cyanPrimary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- DOWNLOADED ITEM CARD ---
  Widget _buildDownloadCard(DownloadItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: FrostedGlass(
        borderRadius: 18,
        blur: 16,
        backgroundColor: AppColors.cardSurface.withOpacity(0.65),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail with Play button overlay
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl,
                    width: 90,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 60,
                      color: AppColors.surfaceDark,
                      child: const Icon(Icons.movie_rounded, color: AppColors.textMuted),
                    ),
                  ),
                ),
                Container(
                  width: 90,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),
                InkWell(
                  onTap: () => _playMedia(item.movie),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cyanPrimary.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyanPrimary.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Title & Episode & Format Badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.episode,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.cyanPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.cyanPrimary.withOpacity(0.3),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          item.format,
                          style: const TextStyle(
                            color: AppColors.cyanPrimary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.size,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // More Options Popup Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
              color: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.glassBorder, width: 0.8),
              ),
              onSelected: (value) {
                if (value == 'play') {
                  _playMedia(item.movie);
                } else if (value == 'delete') {
                  _deleteDownload(item);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'play',
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_fill_rounded, color: AppColors.cyanPrimary, size: 18),
                      SizedBox(width: 10),
                      Text('Play Offline', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                      SizedBox(width: 10),
                      Text('Delete Download', style: TextStyle(color: AppColors.error, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TRENDING FOR OFFLINE TRIPS CARD ---
  Widget _buildTrendingOfflineCard(Movie movie) {
    final isDownloading = _downloadingIds.contains(movie.id);

    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.cardSurface.withOpacity(0.8),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster with 4K badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  movie.posterUrl,
                  height: 125,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 125,
                    width: 150,
                    color: AppColors.surfaceDark,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.neonPurple.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '4K UHD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details & 1-Tap Download Button
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _startDownload(movie),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDownloading
                          ? AppColors.cyanPrimary.withOpacity(0.2)
                          : AppColors.cyanPrimary,
                      borderRadius: BorderRadius.circular(8),
                      border: isDownloading
                          ? Border.all(color: AppColors.cyanPrimary, width: 0.8)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: isDownloading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyanPrimary),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download_rounded, color: Colors.black, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Download',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceDark,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(Icons.cloud_download_outlined, color: AppColors.textMuted, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Offline Downloads Yet',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Explore movies and series below to save for flights and road trips.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String badge,
    required Color badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.badge.copyWith(
            color: Colors.white,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: badgeColor.withOpacity(0.4), width: 0.8),
          ),
          child: Text(
            badge,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  void _showPreferencesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: AppColors.glassBorderCyan, width: 1.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Download Quality & Network',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Wi-Fi Only Downloads', style: TextStyle(color: Colors.white)),
                    subtitle: Text('Prevents high cellular data consumption', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    value: _wifiOnly,
                    activeColor: AppColors.cyanPrimary,
                    onChanged: (val) {
                      setModalState(() => _wifiOnly = val);
                      setState(() => _wifiOnly = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Smart Downloads', style: TextStyle(color: Colors.white)),
                    subtitle: Text('Deletes finished episodes automatically', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    value: _smartDownloads,
                    activeColor: AppColors.cyanPrimary,
                    onChanged: (val) {
                      setModalState(() => _smartDownloads = val);
                      setState(() => _smartDownloads = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
