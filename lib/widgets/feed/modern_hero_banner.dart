import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ModernHeroItem {
  final String id;
  final String title;
  final String subtitle;
  final String badgeText;
  final String formatInfo;
  final String imageUrl;

  const ModernHeroItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.formatInfo,
    required this.imageUrl,
  });
}

class ModernHeroBanner extends StatefulWidget {
  final List<ModernHeroItem> items;
  final void Function(ModernHeroItem item)? onWatchNow;
  final void Function(ModernHeroItem item)? onAddList;
  final void Function(ModernHeroItem item)? onTap;

  const ModernHeroBanner({
    super.key,
    required this.items,
    this.onWatchNow,
    this.onAddList,
    this.onTap,
  });

  @override
  State<ModernHeroBanner> createState() => _ModernHeroBannerState();
}

class _ModernHeroBannerState extends State<ModernHeroBanner> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final Set<String> _inListIds = {};

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

  void _nextPage() {
    if (_currentIndex < widget.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive height
    final double bannerHeight = screenWidth > 900 ? 360 : 300;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyanPrimary.withOpacity(0.18),
              blurRadius: 36,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. PageView for carousel artwork
              PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.movie_filter_rounded, size: 70, color: AppColors.cyanPrimary),
                          ),
                        ),
                      ),
                      // Atmospheric Vignette & Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.35),
                              Colors.transparent,
                              Colors.black.withOpacity(0.85),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // 2. Carousel Chevrons (< and >)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _CarouselArrowButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _prevPage,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _CarouselArrowButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _nextPage,
                  ),
                ),
              ),

              // 3. Centered Floating Glass HUD Card
              Positioned(
                left: 24,
                right: 24,
                bottom: 18,
                child: Center(
                  child: _buildFloatingGlassHUD(widget.items[_currentIndex]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingGlassHUD(ModernHeroItem item) {
    final bool isInList = _inListIds.contains(item.id);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1522).withOpacity(0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.cyanPrimary.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyanPrimary.withOpacity(0.12),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title & Live Premiere Badge Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h2.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // LIVE PREMIERE Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0x33FF334B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.liveRed, width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.liveRed,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Format Info (4K Ultra HD • Dolby Atmos)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hd_rounded, size: 14, color: AppColors.cyanPrimary),
                  const SizedBox(width: 4),
                  Text(
                    item.formatInfo,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.cyanElectric,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. "Watch Now" Glowing Cyan Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => widget.onWatchNow?.call(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanPrimary.withOpacity(0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Watch Now',
                              style: AppTypography.button.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. "+ List" Frosted Glass Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        setState(() {
                          if (isInList) {
                            _inListIds.remove(item.id);
                          } else {
                            _inListIds.add(item.id);
                          }
                        });
                        widget.onAddList?.call(item);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isInList ? AppColors.cyanPrimary : Colors.white.withOpacity(0.25),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isInList ? Icons.check_rounded : Icons.add_rounded,
                              color: isInList ? AppColors.cyanPrimary : Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isInList ? 'Added' : '+ List',
                              style: AppTypography.bodySmall.copyWith(
                                color: isInList ? AppColors.cyanPrimary : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
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

class _CarouselArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselArrowButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.35),
                border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
