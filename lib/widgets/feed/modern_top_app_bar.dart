import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_profile.dart';

/// Minimal Cinema Noir header bar (used on mobile or standalone feed views).
class ModernTopAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  Size get preferredSize => const Size.fromHeight(68);

  @override
  State<ModernTopAppBar> createState() => _ModernTopAppBarState();
}

class _ModernTopAppBarState extends State<ModernTopAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchField = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final profile = widget.activeProfile;
    final initial =
        (profile?.name.isNotEmpty ?? false) ? profile!.name[0].toUpperCase() : 'A';

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 10, 20, 10),
      color: Colors.transparent,
      child: Row(
        children: [
          if (!_showSearchField) ...[
            Text(
              'AURA',
              style: AppTypography.brandLogo(fontSize: 20, letterSpacing: 4.5),
            ),
            const Spacer(),
          ] else
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.glassBorderBright),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: widget.onSearch,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        cursorColor: AppColors.noirWhite,
                        decoration: InputDecoration(
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          hintText: 'Search films, sports, 4K...',
                          hintStyle: AppTypography.bodySmall,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        widget.onSearch?.call('');
                        setState(() => _showSearchField = false);
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (!_showSearchField) ...[
            _NoirIconCircle(
              icon: Icons.search_rounded,
              onTap: () => setState(() => _showSearchField = true),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: widget.onProfileTap ??
                  () => context.push(RouteNames.whoIsWatching),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: profile?.themeColor ?? AppColors.cardSurface,
                  border: Border.all(color: AppColors.glassBorderBright),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoirIconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NoirIconCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDark,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
