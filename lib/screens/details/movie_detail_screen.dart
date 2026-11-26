import 'dart:ui';
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
import '../../widgets/common/frosted_glass.dart';
import '../../widgets/feed/frosted_glass_card.dart';

/// The Next-Gen Movie & Series Detail Screen for Aura Stream.
///
/// Features:
/// - Hero Backdrop with atmospheric cyber vignette gradient
/// - Sound & Vision Tech Badges (4K Ultra HD, Dolby Vision, Dolby Atmos 7.1.4, IMAX)
/// - Primary "Watch Now" action with glowing cyan gradient & "Watch Trailer"
/// - Interactive Watchlist, Offline Download, and Share buttons
/// - Expandable Synopsis with Genre tag pills
/// - Cast & Crew avatar rail with cyan neon glow
/// - Season selector dropdown & vertical episode cards
/// - "More Like This" recommended content carousel
class MovieDetailScreen extends StatefulWidget {
  final Movie? item;
  final String? movieId;
  final void Function(Movie item)? onPlayPressed;

  const MovieDetailScreen({
    super.key,
    this.item,
    this.movieId,
    this.onPlayPressed,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie? _resolvedMovie;
  bool _isLoading = false;
  int _selectedSeasonIndex = 0;
  bool _isInWatchlist = false;
  bool _isDownloaded = false;
  List<Movie> _moreLikeThis = [];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _resolvedMovie = widget.item;
      _loadRecommendations();
      _checkCloudWatchlist();
    } else if (widget.movieId != null) {
      _loadMovieById(widget.movieId!);
    }
  }

  Future<void> _checkCloudWatchlist() async {
    final movie = _resolvedMovie;
    if (movie == null) return;
    try {
      final profile = context.read<ProfileProvider>().activeProfile;
      if (profile != null) {
        final isSaved = await SupabaseMediaService().isMovieInWatchlist(
          profileId: profile.id,
          movieId: movie.id,
        );
        if (mounted) {
          setState(() => _isInWatchlist = isSaved);
        }
      }
    } catch (_) {}
  }

  Future<void> _loadRecommendations() async {
    try {
      final feed = await MockDataService.loadHomeFeed();
      if (!mounted) return;
      setState(() {
        _moreLikeThis = [
          ...feed.top10,
          ...feed.featuredHeroes,
          if (feed.categories.isNotEmpty) ...feed.categories.first.movies,
        ].where((m) => m.id != _resolvedMovie?.id).take(6).toList();
      });
    } catch (_) {}
  }

  Future<void> _loadMovieById(String id) async {
    setState(() => _isLoading = true);
    final feed = await MockDataService.loadHomeFeed();

    Movie? found;
    if (feed.hero.id == id) {
      found = feed.hero;
    } else {
      found = feed.featuredHeroes.cast<Movie?>().firstWhere((m) => m?.id == id, orElse: () => null) ??
          feed.top10.cast<Movie?>().firstWhere((m) => m?.id == id, orElse: () => null) ??
          feed.continueWatching.cast<Movie?>().firstWhere((m) => m?.id == id, orElse: () => null);

      if (found == null) {
        for (final cat in feed.categories) {
          found = cat.movies.cast<Movie?>().firstWhere((m) => m?.id == id, orElse: () => null);
          if (found != null) break;
        }
      }
    }

    if (mounted) {
      setState(() {
        _resolvedMovie = found ?? feed.hero;
        _isLoading = false;
      });
      _loadRecommendations();
      _checkCloudWatchlist();
    }
  }

  void _playMovie([Movie? movie]) {
    final target = movie ?? _resolvedMovie;
    if (target == null) return;

    if (widget.onPlayPressed != null) {
      widget.onPlayPressed!(target);
    } else {
      try {
        context.push(RouteNames.player, extra: target);
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceDark,
            content: Text('Starting player for "${target.title}"...'),
          ),
        );
      }
    }
  }

  List<Season> get _seasons {
    final item = _resolvedMovie;
    if (item != null && item.seasons.isNotEmpty) {
      return item.seasons;
    }
    if (item == null) return [];
    return [
      Season(
        seasonNumber: 1,
        seasonTitle: 'Season 1',
        episodes: [
          Episode(
            episodeNumber: 1,
            title: '${item.title} - Part 1: Convergence',
            duration: item.duration,
            synopsis: item.synopsis,
            thumbnailUrl: item.backdropUrl,
          ),
          Episode(
            episodeNumber: 2,
            title: '${item.title} - Part 2: The Singularity',
            duration: '52m',
            synopsis: 'Deep within the quantum matrix, unexpected anomalies threaten temporal coherence.',
            thumbnailUrl: item.posterUrl,
          ),
          Episode(
            episodeNumber: 3,
            title: '${item.title} - Part 3: Event Horizon',
            duration: '58m',
            synopsis: 'The final barrier collapses as the team races against systemic cascade failure.',
            thumbnailUrl: item.backdropUrl,
          ),
        ],
      ),
      Season(
        seasonNumber: 2,
        seasonTitle: 'Season 2 (New)',
        episodes: [
          Episode(
            episodeNumber: 1,
            title: 'Resurgence Protocol',
            duration: '1h 02m',
            synopsis: 'Three years after the anomaly, a new subspace signal originates from the outer asteroid belt.',
            thumbnailUrl: item.backdropUrl,
          ),
        ],
      ),
    ];
  }

  void _toggleWatchlist() {
    setState(() => _isInWatchlist = !_isInWatchlist);

    // Sync with Supabase Cloud if connected
    final profile = context.read<ProfileProvider>().activeProfile;
    final movie = _resolvedMovie;
    if (profile != null && movie != null) {
      SupabaseMediaService().toggleWatchlist(
        profileId: profile.id,
        movieId: movie.id,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cyanPrimary, width: 0.8),
        ),
        content: Text(
          _isInWatchlist ? 'Added to your Watchlist' : 'Removed from Watchlist',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleDownload() {
    setState(() => _isDownloaded = !_isDownloaded);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cyanPrimary, width: 0.8),
        ),
        content: Text(
          _isDownloaded
              ? '4K UHD stream downloaded for offline viewing!'
              : 'Download removed from local cache.',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showTrailerDialog(Movie media) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFF0F1524),
              border: Border.all(color: AppColors.cyanPrimary.withOpacity(0.5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyanPrimary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trailer Preview Header
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          media.backdropUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.35),
                          child: Center(
                            child: IconButton(
                              iconSize: 64,
                              icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.cyanPrimary),
                              onPressed: () {
                                Navigator.pop(context);
                                _playMovie(media);
                              },
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${media.title} — Official 4K Trailer',
                          style: AppTypography.titleLarge.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Streaming in full 4K UHD with Dolby Atmos on Aura Stream.',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyanPrimary,
                            foregroundColor: Colors.black,
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _playMovie(media);
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Play Full Movie', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.noirWhite)),
      );
    }

    final media = _resolvedMovie;
    if (media == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: Center(child: Text('Movie not found', style: AppTypography.titleLarge)),
      );
    }

    final seasons = _seasons;
    final currentSeason = seasons.isNotEmpty
        ? seasons[_selectedSeasonIndex.clamp(0, seasons.length - 1)]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.go(RouteNames.home);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.surfaceDark,
                          content: Text('Aura Stream share link copied to clipboard!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Large Hero Backdrop Header
            _buildBackdropHeader(context, media),

            // 2. Metadata, Specs, and Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Sound & Vision Badges (4K, Dolby Vision, Dolby Atmos, IMAX)
                  _buildSoundAndVisionRow(),
                  const SizedBox(height: 12),

                  // Metadata Row (Rating, Year, Maturity, Duration)
                  _buildMetadataRow(media),
                  const SizedBox(height: 20),

                  // Primary Action Buttons ("Watch Now", "Trailer", "Watchlist", "Download")
                  _buildActionButtons(context, media),
                  const SizedBox(height: 24),

                  // 3. Synopsis & Genre Tags
                  _buildSynopsis(media),
                  const SizedBox(height: 28),

                  // 4. Cast & Crew Rail
                  if (media.cast.isNotEmpty) ...[
                    _buildCastList(media.cast),
                    const SizedBox(height: 28),
                  ],

                  // 5. Season Dropdown & Episodes List
                  if (currentSeason != null) ...[
                    _buildSeasonAndEpisodes(seasons, currentSeason),
                    const SizedBox(height: 32),
                  ],

                  // 6. "More Like This" Recommendations Carousel
                  if (_moreLikeThis.isNotEmpty) ...[
                    _buildMoreLikeThisRail(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdropHeader(BuildContext context, Movie media) {
    final height = MediaQuery.of(context).size.height * 0.48;

    return Stack(
      children: [
        // Backdrop Image
        SizedBox(
          height: height,
          width: double.infinity,
          child: Image.network(
            media.backdropUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surfaceDark,
              child: const Icon(Icons.movie, size: 64, color: AppColors.textSecondary),
            ),
          ),
        ),

        // Deep Cinematic Vignette Gradient Overlay into Pure #000000
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.42),
                Colors.transparent,
                AppColors.background.withValues(alpha: 0.88),
                AppColors.background,
              ],
              stops: const [0.0, 0.35, 0.78, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Title at bottom of full-color backdrop (Panel 3)
        Positioned(
          left: 24,
          right: 24,
          bottom: 14,
          child: Text(
            media.title,
            style: AppTypography.h1.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.9,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundAndVisionRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildTechBadge('4K ULTRA HD', AppColors.noirWhite, Icons.hd_rounded),
          const SizedBox(width: 8),
          _buildTechBadge('DOLBY VISION', AppColors.noirSilver, Icons.remove_red_eye_outlined),
          const SizedBox(width: 8),
          _buildTechBadge('DOLBY ATMOS 7.1.4', AppColors.noirSilver, Icons.surround_sound_outlined),
          const SizedBox(width: 8),
          _buildTechBadge('IMAX ENHANCED', AppColors.textSecondary, Icons.aspect_ratio_rounded),
        ],
      ),
    );
  }

  Widget _buildTechBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(Movie media) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Rating pill (Obsidian + Gold Star)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.glassBorderBright),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 14, color: AppColors.kidsModeAmber),
              const SizedBox(width: 4),
              Text(
                '${media.rating} IMDb',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11.5),
              ),
            ],
          ),
        ),

        Text(
          media.year,
          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const Text('•', style: TextStyle(color: AppColors.textMuted)),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.24)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            media.maturityRating,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ),
        const Text('•', style: TextStyle(color: AppColors.textMuted)),

        Text(
          media.duration,
          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Movie media) {
    return Row(
      children: [
        // Primary White "Play" Pill (Panel 3)
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _playMovie(media),
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
              label: const Text(
                'Play',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.noirWhite,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Trailer Pill
        FrostedGlassCard(
          borderRadius: BorderRadius.circular(999),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: AppColors.surfaceDark,
          borderColor: AppColors.glassBorder,
          onTap: () => _showTrailerDialog(media),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'Trailer',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Watchlist Toggle Pill
        FrostedGlassCard(
          borderRadius: BorderRadius.circular(999),
          padding: const EdgeInsets.all(12),
          backgroundColor: _isInWatchlist ? AppColors.noirWhite : AppColors.surfaceDark,
          borderColor: _isInWatchlist ? AppColors.noirWhite : AppColors.glassBorder,
          onTap: _toggleWatchlist,
          child: Icon(
            _isInWatchlist ? Icons.check_rounded : Icons.add_rounded,
            color: _isInWatchlist ? Colors.black : Colors.white,
            size: 22,
          ),
        ),

        const SizedBox(width: 10),

        // Download Toggle Pill
        FrostedGlassCard(
          borderRadius: BorderRadius.circular(999),
          padding: const EdgeInsets.all(12),
          backgroundColor: AppColors.surfaceDark,
          borderColor: _isDownloaded ? AppColors.success : AppColors.glassBorder,
          onTap: _toggleDownload,
          child: Icon(
            _isDownloaded ? Icons.download_done_rounded : Icons.download_rounded,
            color: _isDownloaded ? AppColors.success : Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildSynopsis(Movie media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synopsis',
          style: AppTypography.titleLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          media.synopsis,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 14),

        // Genre Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: media.genres.map((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppColors.neonPurple.withOpacity(0.12),
                border: Border.all(color: AppColors.neonPurple.withOpacity(0.4), width: 1.0),
              ),
              child: Text(
                genre,
                style: const TextStyle(
                  color: AppColors.neonPurple,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCastList(List<CastMember> cast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast & Crew',
          style: AppTypography.titleLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 115,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final member = cast[index];
              return Container(
                width: 86,
                margin: const EdgeInsets.only(right: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circular avatar with neon gradient border
                    Container(
                      width: 58,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Image.network(
                          member.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.cardSurface,
                            child: const Icon(Icons.person, color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      member.character,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonAndEpisodes(List<Season> seasons, Season currentSeason) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Season Header Row with Dropdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Episodes',
              style: AppTypography.titleLarge.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
            ),

            // Season Dropdown Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.glassBorderBright),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedSeasonIndex.clamp(0, seasons.length - 1),
                  dropdownColor: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.noirWhite),
                  style: const TextStyle(
                    color: AppColors.noirWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  items: List.generate(seasons.length, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(seasons[index].seasonTitle),
                    );
                  }),
                  onChanged: (newIndex) {
                    if (newIndex != null) {
                      setState(() => _selectedSeasonIndex = newIndex);
                    }
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Vertical Episode Cards Rail
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currentSeason.episodes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final episode = currentSeason.episodes[index];
            return _buildEpisodeCard(episode);
          },
        ),
      ],
    );
  }

  Widget _buildEpisodeCard(Episode episode) {
    return GestureDetector(
      onTap: () => _playMovie(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surfaceDark,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode Thumbnail with Play Overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 114,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      episode.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardSurface,
                        child: const Icon(Icons.play_circle_outline, color: AppColors.textSecondary),
                      ),
                    ),
                    Container(color: Colors.black.withOpacity(0.35)),
                    const Center(
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.play_arrow_rounded, color: AppColors.cyanPrimary, size: 18),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          episode.duration,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Episode Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'E${episode.episodeNumber} • ${episode.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    episode.synopsis,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.35,
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

  Widget _buildMoreLikeThisRail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'More Like This',
              style: AppTypography.titleLarge.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _moreLikeThis.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final movie = _moreLikeThis[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _resolvedMovie = movie;
                  });
                  _loadRecommendations();
                },
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.cardSurface,
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          movie.posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.cardSurface,
                            child: const Icon(Icons.movie_rounded, color: AppColors.cyanPrimary),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
