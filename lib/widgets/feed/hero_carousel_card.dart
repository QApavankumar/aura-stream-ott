import 'package:flutter/material.dart';
import 'package:aura_stream/models/media_item.dart';
import 'package:aura_stream/theme/aura_theme.dart';
import 'frosted_glass_card.dart';

/// Hero Featured Movie Carousel with auto-swipe / page indicator,
/// featuring "Play" (Watch Now), "Details", and "My List" action buttons.
class HeroCarouselCard extends StatefulWidget {
  final List<Movie> items;
  final Movie? item; // Backward-compatibility single item
  final void Function(Movie item)? onPlay;
  final void Function(Movie item)? onDetails;
  final void Function(Movie item, bool isAdded)? onMyListToggle;

  // Backward-compatibility callbacks
  final VoidCallback? onWatchNow;
  final VoidCallback? onCardTap;

  const HeroCarouselCard({
    super.key,
    this.items = const [],
    this.item,
    this.onPlay,
    this.onDetails,
    this.onMyListToggle,
    this.onWatchNow,
    this.onCardTap,
  });

  @override
  State<HeroCarouselCard> createState() => _HeroCarouselCardState();
}

class _HeroCarouselCardState extends State<HeroCarouselCard> {
  late final PageController _pageController;
  int _currentPage = 0;
  final Set<String> _myListMovieIds = {};

  List<Movie> get _carouselItems {
    if (widget.items.isNotEmpty) return widget.items;
    if (widget.item != null) return [widget.item!];
    return [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePlay(Movie movie) {
    if (widget.onPlay != null) {
      widget.onPlay!(movie);
    } else if (widget.onWatchNow != null) {
      widget.onWatchNow!();
    }
  }

  void _handleDetails(Movie movie) {
    if (widget.onDetails != null) {
      widget.onDetails!(movie);
    } else if (widget.onCardTap != null) {
      widget.onCardTap!();
    }
  }

  void _handleMyListToggle(Movie movie) {
    final willBeInList = !_myListMovieIds.contains(movie.id);
    setState(() {
      if (willBeInList) {
        _myListMovieIds.add(movie.id);
      } else {
        _myListMovieIds.remove(movie.id);
      }
    });

    if (widget.onMyListToggle != null) {
      widget.onMyListToggle!(movie, willBeInList);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AuraTheme.surfaceDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AuraTheme.neonCyan, width: 0.8),
          ),
          content: Text(
            willBeInList
                ? 'Added "${movie.title}" to My List'
                : 'Removed "${movie.title}" from My List',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _carouselItems;
    if (items.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final carouselHeight = screenWidth * (9 / 16) + 110;

    return SizedBox(
      height: carouselHeight,
      width: screenWidth,
      child: Stack(
        children: [
          // Swipable Carousel Pages
          PageView.builder(
            controller: _pageController,
            itemCount: items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final movie = items[index];
              return _buildHeroSlide(context, movie, screenWidth, carouselHeight);
            },
          ),

          // Carousel Page Indicator Dots (when multiple items)
          if (items.length > 1)
            Positioned(
              top: 48,
              right: 20,
              child: Row(
                children: List.generate(items.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 22 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive ? AuraTheme.neonCyan : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: isActive ? AuraTheme.cyanGlow(blur: 6) : null,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSlide(
    BuildContext context,
    Movie item,
    double screenWidth,
    double height,
  ) {
    final isInList = _myListMovieIds.contains(item.id);

    return GestureDetector(
      onTap: () => _handleDetails(item),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 16:9 Curved Backdrop Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Image.network(
              item.backdropUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF161B26), Color(0xFF08090C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.movie_outlined, size: 64, color: AuraTheme.neonCyan),
                  ),
                );
              },
            ),
          ),

          // Gradient Fade to Dark Obsidian
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0x4008090C),
                    Color(0xD008090C),
                    AuraTheme.darkObsidian,
                  ],
                  stops: [0.0, 0.40, 0.75, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Content Overlay
          Positioned(
            left: 20,
            right: 20,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Tag Badge
                if (item.badge != null)
                  FrostedGlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    borderRadius: BorderRadius.circular(20),
                    borderColor: AuraTheme.purpleAura.withValues(alpha: 0.5),
                    backgroundColor: AuraTheme.purpleAura.withValues(alpha: 0.18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: AuraTheme.neonCyan,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.badge!,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Title
                Text(
                  item.title,
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 24,
                    shadows: const [
                      Shadow(
                        color: Colors.black87,
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Genres & Meta Info Row
                Row(
                  children: [
                    Text(
                      item.genres.join(' • '),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AuraTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AuraTheme.neonCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.year,
                      style: AppTypography.bodyMedium.copyWith(color: AuraTheme.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        border: Border.all(color: AuraTheme.textMuted, width: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.maturityRating,
                        style: AppTypography.bodySmall.copyWith(
                          color: AuraTheme.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Three Action Buttons: [Play / Watch Now] + [Details] + [My List]
                Row(
                  children: [
                    // 1. Primary "Play" / "Watch Now" Button
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AuraTheme.auraCyanVioletGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AuraTheme.cyanGlow(blur: 14),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _handlePlay(item),
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                          label: Text(
                            'Watch Now',
                            style: AppTypography.buttonText,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 2. "Details" Button
                    FrostedGlassCard(
                      borderRadius: BorderRadius.circular(14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      borderColor: AuraTheme.neonCyan.withValues(alpha: 0.4),
                      onTap: () => _handleDetails(item),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AuraTheme.neonCyan,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Details',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 3. "My List" Action Button (Task Requirement)
                    FrostedGlassCard(
                      borderRadius: BorderRadius.circular(14),
                      padding: const EdgeInsets.all(11),
                      borderColor: isInList
                          ? AuraTheme.neonCyan
                          : AuraTheme.glassBorder,
                      backgroundColor: isInList
                          ? AuraTheme.neonCyan.withValues(alpha: 0.15)
                          : null,
                      onTap: () => _handleMyListToggle(item),
                      child: Icon(
                        isInList ? Icons.check_rounded : Icons.bookmark_add_outlined,
                        color: isInList ? AuraTheme.neonCyan : Colors.white,
                        size: 22,
                      ),
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
}
