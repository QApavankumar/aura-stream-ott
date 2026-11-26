import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/dialogs/add_profile_dialog.dart';
import '../../widgets/dialogs/kids_pin_dialog.dart';
import 'widgets/profile_avatar_card.dart';

class WhoIsWatchingScreen extends StatelessWidget {
  const WhoIsWatchingScreen({super.key});

  Future<void> _handleProfileSelection(
    BuildContext context,
    ProfileProvider provider,
    UserProfile targetProfile,
  ) async {
    final current = provider.activeProfile;
    if (current != null &&
        current.isKids &&
        !targetProfile.isKids &&
        provider.isKidsPinEnabled) {
      final verified = await KidsPinDialog.show(
        context,
        expectedPin: provider.kidsPin,
      );
      if (!verified) return;
    }

    provider.setActiveProfileDirectly(targetProfile);
    if (context.mounted) {
      context.go(RouteNames.home);
    }
  }

  Future<void> _toggleKidsPin(
    BuildContext context,
    ProfileProvider provider,
  ) async {
    if (provider.isKidsPinEnabled) {
      final verified = await KidsPinDialog.show(
        context,
        expectedPin: provider.kidsPin,
      );
      if (verified) {
        provider.updateKidsPinSettings(isEnabled: false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kids Mode PIN Exit Lock Disabled')),
          );
        }
      }
    } else {
      provider.updateKidsPinSettings(isEnabled: true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kids Mode PIN Exit Lock Enabled')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profiles = profileProvider.profiles;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AURA',
                    style: AppTypography.brandLogo(
                      fontSize: 22,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "Who's Watching?",
                    style: AppTypography.h1.copyWith(fontSize: 34),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a profile to sync your watchlist & playback history.',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  Wrap(
                    spacing: 24,
                    runSpacing: 28,
                    alignment: WrapAlignment.center,
                    children: [
                      ...profiles.map((profile) {
                        return ProfileAvatarCard(
                          profile: profile,
                          isEditMode: profileProvider.isEditMode,
                          onTap: () {
                            if (profileProvider.isEditMode) return;
                            _handleProfileSelection(
                              context,
                              profileProvider,
                              profile,
                            );
                          },
                          onDelete: () {
                            profileProvider.deleteProfile(profile.id);
                          },
                        );
                      }),
                      if (profiles.length < 5)
                        _AddProfileTile(
                          onTap: () => AddProfileDialog.show(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: 44),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: profileProvider.toggleEditMode,
                        icon: Icon(
                          profileProvider.isEditMode
                              ? Icons.check_rounded
                              : Icons.edit_outlined,
                          size: 16,
                        ),
                        label: Text(
                          profileProvider.isEditMode ? 'Done' : 'Manage Profiles',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _toggleKidsPin(context, profileProvider),
                        icon: Icon(
                          profileProvider.isKidsPinEnabled
                              ? Icons.lock_outline_rounded
                              : Icons.lock_open_rounded,
                          size: 16,
                          color: profileProvider.isKidsPinEnabled
                              ? AppColors.kidsModeAmber
                              : AppColors.textSecondary,
                        ),
                        label: Text(
                          profileProvider.isKidsPinEnabled
                              ? 'Kids PIN: ON'
                              : 'Kids PIN: OFF',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddProfileTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 142,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.glassBorderBright,
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add Profile',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Up to 5 viewers',
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
