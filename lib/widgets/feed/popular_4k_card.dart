import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common/cinema_image.dart';

class Popular4kItem {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String imageUrl;
  final String rating;
  final String year;

  const Popular4kItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.tag = '4K HDR',
    required this.imageUrl,
    this.rating = '9.8',
    this.year = '2026',
  });
}

/// Editorial Featured in 4K theatrical poster card matching screenshot layout.
class Popular4kCard extends StatefulWidget {
  final Popular4kItem item;
  final VoidCallback? onTap;

  const Popular4kCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  State<Popular4kCard> createState() => _Popular4kCardState();
}

class _Popular4kCardState extends State<Popular4kCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final cardWidth = isDesktop ? 204.0 : 172.0;
    final cardHeight = isDesktop ? 138.0 : 118.0;
    final hasEmbeddedPosterTitle =
        item.imageUrl.startsWith('assets/images/poster_') ||
        item.imageUrl.contains('cinema_baahubali_poster') ||
        item.imageUrl.contains('cinema_ramayana') ||
        item.imageUrl.contains('cinema_dragon');

    return Tooltip(
      message: '${item.title} (${item.year})',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isHovered
                    ? AppColors.noirWhite
                    : Colors.white.withValues(alpha: 0.1),
                width: _isHovered ? 1.5 : 1.0,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CinemaImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  alignment: item.imageUrl.contains('cinema_')
                      ? const Alignment(0.0, -0.25)
                      : Alignment.center,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.cardSurface),
                ),
                if (!hasEmbeddedPosterTitle) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Text(
                      item.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
