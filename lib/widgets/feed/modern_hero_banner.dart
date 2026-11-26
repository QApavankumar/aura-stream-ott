import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common/aura_glow_button.dart';
import '../common/cinema_image.dart';

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

/// Edge-to-edge Minimal Cinema Noir hero carousel with interactive controls.
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
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoTimer?.cancel();
    if (widget.items.length <= 1) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || widget.items.isEmpty) return;
      _goToPage((_currentIndex + 1) % widget.items.length);
    });
  }

  void _goToPage(int index) {
    if (!mounted || widget.items.isEmpty) return;
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void didUpdateWidget(covariant ModernHeroBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Alignment _alignmentFor(String imageUrl) {
    if (imageUrl.contains('cinema_')) {
      return const Alignment(0.0, -0.22);
    }
    return const Alignment(0.12, -0.05);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 768;
    final bannerHeight = isDesktop ? 468.0 : 410.0;

    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final item = widget.items[index];

              return GestureDetector(
                onTap: () => widget.onTap?.call(item),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CinemaImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      alignment: _alignmentFor(item.imageUrl),
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.surfaceDark),
                    ),

                    // Top subtle nav shade + smooth bottom fade to #000000
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.42),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.72),
                            AppColors.background,
                          ],
                          stops: const [0.0, 0.32, 0.76, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // Subtle left readability vignette
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.62),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.58],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),

                    // Editorial Title, Spec Line & Action Pills
                    Positioned(
                      left: isDesktop ? 36 : 20,
                      right: isDesktop ? 36 : 20,
                      bottom: isDesktop ? 36 : 24,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.h1.copyWith(
                                fontSize: isDesktop ? 42 : 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                height: 1.04,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.formatInfo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.noirSilver,
                                fontSize: isDesktop ? 14 : 12.5,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (isDesktop)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AuraGlowButton(
                                    label: 'Play',
                                    icon: Icons.play_arrow_rounded,
                                    height: 42,
                                    onPressed: () =>
                                        widget.onWatchNow?.call(item),
                                  ),
                                  const SizedBox(width: 10),
                                  AuraGlowButton(
                                    label: 'Watchlist',
                                    icon: Icons.add_rounded,
                                    isSecondary: true,
                                    height: 42,
                                    onPressed: () =>
                                        widget.onAddList?.call(item),
                                  ),
                                ],
                              )
                            else
                              AuraGlowButton(
                                label: 'Play',
                                icon: Icons.play_arrow_rounded,
                                height: 42,
                                width: double.infinity,
                                onPressed: () => widget.onWatchNow?.call(item),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Carousel Arrows + Clickable Dots (Bottom-Right)
          if (widget.items.length > 1)
            Positioned(
              right: isDesktop ? 36 : 20,
              bottom: isDesktop ? 38 : 76,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDesktop) ...[
                    _CarouselArrowButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () {
                        final prev =
                            (_currentIndex - 1 + widget.items.length) %
                                widget.items.length;
                        _goToPage(prev);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  ...List.generate(widget.items.length, (i) {
                    final active = i == _currentIndex;
                    return GestureDetector(
                      onTap: () => _goToPage(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.noirWhite
                              : Colors.white.withValues(alpha: 0.32),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    );
                  }),
                  if (isDesktop) ...[
                    const SizedBox(width: 8),
                    _CarouselArrowButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: () {
                        final next =
                            (_currentIndex + 1) % widget.items.length;
                        _goToPage(next);
                      },
                    ),
                  ],
                ],
              ),
            ),
        ],
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0x9918181B),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
