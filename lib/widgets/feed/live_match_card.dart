import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common/cinema_image.dart';

class LiveMatchItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isRedBadge;
  final String statusText;
  final String channel;
  final bool showRightLiveBadge;

  const LiveMatchItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.isRedBadge = false,
    this.statusText = 'LIVE',
    this.channel = 'Aura Sports 1',
    this.showRightLiveBadge = true,
  });
}

/// Full-color live sports / broadcast card with crisp crimson LIVE indicator.
class LiveMatchCard extends StatefulWidget {
  final LiveMatchItem item;
  final VoidCallback? onTap;

  const LiveMatchCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  State<LiveMatchCard> createState() => _LiveMatchCardState();
}

class _LiveMatchCardState extends State<LiveMatchCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isLive = item.statusText.toUpperCase().contains('LIVE') ||
        item.isRedBadge ||
        item.showRightLiveBadge;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 300,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? AppColors.noirWhite : AppColors.glassBorder,
              width: _hovered ? 1.5 : 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 152,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CinemaImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.cardSurface),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isLive
                                    ? AppColors.liveRed
                                    : AppColors.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.statusText.toUpperCase(),
                              style: AppTypography.badge.copyWith(fontSize: 9.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.channel.toUpperCase(),
                      style: AppTypography.badge.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge.copyWith(fontSize: 14.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
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
