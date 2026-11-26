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

/// Edge-to-edge Minimal Cinema Noir hero matching the Obsidian reference layout.
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
    _autoTimer = Timer.periodic(const Duration(seconds: 9), (_) {
      if (!mounted || widget.items.isEmpty) return;
      final next = (_currentIndex + 1) % widget.items.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
        );
      }
    });
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
                      alignment: const Alignment(0.12, -0.05),
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.surfaceDark),
                    ),

                    // Top subtle nav shade + smooth bottom fade to #000000
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.68),
                            AppColors.background,
                          ],
                          stops: const [0.0, 0.32, 0.78, 1.0],
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
                            Colors.black.withValues(alpha: 0.58),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),

                    // Editorial Title, Spec Line & Action Pills (Screenshot Panel 1)
                    Positioned(
                      left: isDesktop ? 36 : 20,
                      right: isDesktop ? 36 : 20,
                      bottom: isDesktop ? 36 : 24,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.h1.copyWith(
                                fontSize: isDesktop ? 44 : 30,
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

          if (widget.items.length > 1)
            Positioned(
              right: isDesktop ? 36 : 20,
              bottom: isDesktop ? 42 : 76,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.items.length, (i) {
                  final active = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(left: 6),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.noirWhite
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
