import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common/aura_glow_button.dart';

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

/// Edge-to-edge full-color cinema hero fading cleanly into #000000 obsidian.
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
    _autoTimer = Timer.periodic(const Duration(seconds: 7), (_) {
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
    final bannerHeight = isDesktop ? 560.0 : 450.0;

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
              final isLive = item.badgeText.toUpperCase().contains('LIVE');

              return GestureDetector(
                onTap: () => widget.onTap?.call(item),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Full-color theatrical photography
                    Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.surfaceDark),
                    ),

                    // Subtle side vignette on desktop + deep bottom fade to pure #000000
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.42),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.72),
                            AppColors.background,
                          ],
                          stops: const [0.0, 0.35, 0.72, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // Left readability scrim
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.72),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.65],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),

                    // Editorial metadata & CTA overlay
                    Positioned(
                      left: isDesktop ? 40 : 20,
                      right: isDesktop ? 40 : 20,
                      bottom: 34,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: AppColors.glassBorderBright,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isLive) ...[
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: AppColors.liveRed,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Text(
                                        item.badgeText.toUpperCase(),
                                        style: AppTypography.badge.copyWith(
                                          color: AppColors.noirWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  item.formatInfo,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.noirSilver,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.h1.copyWith(
                                fontSize: isDesktop ? 48 : 32,
                                letterSpacing: -1.1,
                                height: 1.04,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.noirSilver,
                                fontSize: isDesktop ? 15 : 13.5,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                AuraGlowButton(
                                  label: 'Play',
                                  icon: Icons.play_arrow_rounded,
                                  height: 46,
                                  onPressed: () => widget.onWatchNow?.call(item),
                                ),
                                AuraGlowButton(
                                  label: 'Watchlist',
                                  icon: Icons.add_rounded,
                                  isSecondary: true,
                                  height: 46,
                                  onPressed: () => widget.onAddList?.call(item),
                                ),
                              ],
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

          // Pagination Dots (Bottom-Right)
          if (widget.items.length > 1)
            Positioned(
              right: isDesktop ? 40 : 20,
              bottom: 42,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.items.length, (i) {
                  final active = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(left: 6),
                    width: active ? 20 : 6,
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
