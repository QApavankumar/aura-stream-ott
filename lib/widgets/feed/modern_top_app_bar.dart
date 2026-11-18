import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/route_names.dart';
import '../../models/user_profile.dart';

class ModernTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserProfile? activeProfile;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const ModernTopAppBar({
    super.key,
    this.activeProfile,
    this.onSearch,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 680;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 14 : 24,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 1.0,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Row(
            children: [
              // 1. AURA STREAM Brand Logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AURA',
                    style: AppTypography.brandLogo(
                      fontSize: isCompact ? 18 : 22,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'STREAM',
                    style: TextStyle(
                      fontFamily: AppTypography.h1.fontFamily,
                      fontSize: isCompact ? 16 : 20,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // 2. Centered Frosted Search Bar
              if (!isCompact)
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 380),
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        onChanged: onSearch,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        cursorColor: AppColors.cyanPrimary,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textSecondary,
                            size: 19,
                          ),
                          hintText: 'Search movies, live matches, studios...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 12.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),

              // 3. Right Icons (Notifications + Glowing Avatar)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Compact search icon if on mobile
                  if (isCompact)
                    IconButton(
                      icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                      onPressed: () => context.go(RouteNames.explore),
                    ),

                  // Notification Bell with Dot
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                        onPressed: onNotificationTap ?? () {},
                      ),
                      Positioned(
                        top: 10,
                        right: 11,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.liveRed,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.liveRed.withOpacity(0.8),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // User Profile Avatar with Glowing Halo Ring
                  GestureDetector(
                    onTap: onProfileTap ?? () => context.go(RouteNames.whoIsWatching),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00F2FE), Color(0xFF9D4EDD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (activeProfile?.themeColor ?? AppColors.cyanPrimary).withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0F1522),
                        ),
                        child: Center(
                          child: Icon(
                            activeProfile?.isKids == true
                                ? Icons.child_care_rounded
                                : Icons.person_rounded,
                            size: 20,
                            color: activeProfile?.themeColor ?? AppColors.cyanPrimary,
                          ),
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
