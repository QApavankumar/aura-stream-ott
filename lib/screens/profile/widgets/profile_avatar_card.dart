import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/user_profile.dart';

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

class _ProfileAvatarCardState extends State<ProfileAvatarCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  IconData _getIcon(String iconKey) {
    switch (iconKey) {
      case 'movie':
        return Icons.movie_creation_outlined;
      case 'child_care':
        return Icons.child_care_rounded;
      case 'group':
        return Icons.group_rounded;
      case 'sports_esports':
        return Icons.sports_esports_outlined;
      case 'rocket_launch':
        return Icons.rocket_launch_outlined;
      case 'person':
      default:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final primaryColor = profile.themeColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar Circle Container
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Outer Glow Aura
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(_isHovered ? 0.6 : 0.25),
                          blurRadius: _isHovered ? 26 : 14,
                          spreadRadius: _isHovered ? 4 : 0,
                        ),
                      ],
                    ),
                  ),

                  // Avatar Body
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceDark,
                      border: Border.all(
                        color: _isHovered ? primaryColor : primaryColor.withOpacity(0.6),
                        width: 2.5,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.35),
                          AppColors.surfaceDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getIcon(profile.avatarIcon),
                        size: 44,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  // Kids Lock / Mode Badge
                  if (profile.isKids)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.kidsModeAmber,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.kidsModeAmber,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded, size: 10, color: Colors.black),
                            SizedBox(width: 3),
                            Text(
                              'KIDS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Delete button in edit mode
                  if (widget.isEditMode && !profile.isPrimary)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.error,
                            boxShadow: [
                              BoxShadow(color: AppColors.error, blurRadius: 8),
                            ],
                          ),
                          child: const Icon(Icons.remove, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                profile.name,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _isHovered ? AppColors.cyanPrimary : Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Subtitle / Rating
              Text(
                profile.contentRating,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11,
                  color: profile.isKids ? AppColors.kidsModeAmber : AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
