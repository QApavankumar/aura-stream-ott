import 'package:flutter/material.dart';
import 'package:aura_stream/models/media_item.dart';
import 'package:aura_stream/core/theme/app_colors.dart';
import 'package:aura_stream/core/theme/app_typography.dart';

/// Editorial Top 10 ranked poster card with bold architectural numeral.
class TopTenCard extends StatefulWidget {
  final Movie item;
  final VoidCallback onTap;

  const TopTenCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<TopTenCard> createState() => _TopTenCardState();
}

class _TopTenCardState extends State<TopTenCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final rank = widget.item.rank ?? 1;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 190,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 222,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Positioned(
                      left: 0,
                      bottom: -6,
                      child: Text(
                        '$rank',
                        style: AppTypography.h1.copyWith(
                          fontSize: 82,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.16),
                          height: 0.9,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 146,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _hovered
                                ? AppColors.noirWhite
                                : AppColors.glassBorder,
                            width: _hovered ? 1.5 : 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          widget.item.posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColors.cardSurface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge.copyWith(fontSize: 14),
                    ),
                    Text(
                      '${widget.item.year} • ${widget.item.genres.isNotEmpty ? widget.item.genres.first : '4K HDR'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
