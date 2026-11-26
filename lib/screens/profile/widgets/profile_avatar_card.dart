import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/user_profile.dart';

/// Colorized square-rounded cinema profile card inside Minimal Noir framing.
class ProfileAvatarCard extends StatefulWidget {
  final UserProfile profile;
  final bool isEditMode;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ProfileAvatarCard({
    super.key,
    required this.profile,
    this.isEditMode = false,
    required this.onTap,
    this.onDelete,
  });

  @override
  State<ProfileAvatarCard> createState() => _ProfileAvatarCardState();
}

class _ProfileAvatarCardState extends State<ProfileAvatarCard> {
  bool _isHovered = false;

  IconData _resolveIcon(String name) {
    switch (name) {
      case 'child_care':
        return Icons.sentiment_satisfied_alt_rounded;
      case 'movie':
        return Icons.movie_creation_outlined;
      case 'group':
        return Icons.groups_rounded;
      case 'star':
        return Icons.star_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final secondaryTone = p.isKids
        ? AppColors.kidsModeOrange
        : Color.lerp(p.themeColor, Colors.black, 0.42)!;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 142,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          p.isKids ? AppColors.kidsModeAmber : p.themeColor,
                          secondaryTone,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: _isHovered
                            ? AppColors.noirWhite
                            : Colors.white.withValues(alpha: 0.16),
                        width: _isHovered ? 2.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (p.isKids ? AppColors.kidsModeAmber : p.themeColor)
                              .withValues(alpha: _isHovered ? 0.35 : 0.18),
                          blurRadius: _isHovered ? 24 : 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: p.isKids
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.sentiment_very_satisfied_rounded,
                                      size: 46,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'KIDS',
                                        style: AppTypography.badge.copyWith(
                                          color: Colors.white,
                                          fontSize: 10,
                                          letterSpacing: 1.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Icon(
                                  _resolveIcon(p.avatarIcon),
                                  size: 54,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                        ),
                        if (p.isPrimary)
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '4K',
                                style: AppTypography.badge.copyWith(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.isEditMode && !p.isPrimary && widget.onDelete != null)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.background,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                p.name,
                style: AppTypography.titleLarge.copyWith(
                  color: _isHovered
                      ? AppColors.noirWhite
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Text(
                p.contentRating,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11,
                  color: p.isKids
                      ? AppColors.kidsModeAmber
                      : AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
