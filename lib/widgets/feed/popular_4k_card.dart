import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

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

/// Editorial full-color 4K poster card framed cleanly on pure black.
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 176,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 248,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isHovered
                        ? AppColors.noirWhite
                        : AppColors.glassBorder,
                    width: _isHovered ? 1.5 : 1.0,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.cardSurface),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '4K',
                          style: AppTypography.badge.copyWith(fontSize: 9.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleLarge.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.year} • ${item.subtitle}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
