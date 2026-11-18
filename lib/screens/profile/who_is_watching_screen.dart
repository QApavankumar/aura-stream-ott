import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/route_names.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/frosted_glass.dart';
import '../../widgets/common/aura_logo.dart';
import '../../widgets/dialogs/kids_pin_dialog.dart';
import '../../widgets/dialogs/add_profile_dialog.dart';
import 'widgets/profile_avatar_card.dart';

class WhoIsWatchingScreen extends StatelessWidget {
  const WhoIsWatchingScreen({super.key});

  Future<void> _handleProfileSelection(
    BuildContext context,
    UserProfile profile,
    ProfileProvider provider,
  ) async {
    // Check if coming from a Kids profile to a non-kids profile and Kids PIN is enabled
    final currentProfile = provider.activeProfile;
    final isEscapingKidsMode = currentProfile != null && currentProfile.isKids && !profile.isKids;

    if (isEscapingKidsMode && provider.isKidsPinEnabled) {
      final success = await KidsPinDialog.show(
        context,
        title: 'Exit Kids Profile',
        subtitle: 'Enter the 4-digit Kids PIN to access ${profile.name}',
        expectedPin: provider.kidsPin,
      );

      if (!success) {
        return; // Stay on screen if PIN failed
      }
    }

    provider.setActiveProfileDirectly(profile);
    if (context.mounted) {
      context.go(RouteNames.home);
    }
  }

  Future<void> _toggleKidsPin(BuildContext context, ProfileProvider provider) async {
    if (provider.isKidsPinEnabled) {
      // Prompt PIN to disable
      final success = await KidsPinDialog.show(
        context,
        title: 'Disable Kids PIN',
        subtitle: 'Enter current PIN to disable parental protection',
        expectedPin: provider.kidsPin,
      );
      if (success) {
        provider.updateKidsPinSettings(isEnabled: false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kids PIN protection disabled'),
              backgroundColor: AppColors.surfaceDark,
            ),
          );
        }
      }
    } else {
      // Enable PIN
      provider.updateKidsPinSettings(isEnabled: true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kids PIN protection active (Default: 1234)'),
            backgroundColor: AppColors.cyanPrimary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profiles = profileProvider.profiles;
    final isEditMode = profileProvider.isEditMode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Glow Background
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyanPrimary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.neonPurple.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AuraLogo(size: 38, showTagline: false, isAnimated: false),
                      // Edit Profiles Toggle Button
                      TextButton.icon(
                        onPressed: () => profileProvider.toggleEditMode(),
                        icon: Icon(
                          isEditMode ? Icons.done_all_rounded : Icons.edit_rounded,
                          size: 18,
                          color: isEditMode ? AppColors.cyanPrimary : AppColors.textSecondary,
                        ),
                        label: Text(
                          isEditMode ? 'Done' : 'Manage',
                          style: AppTypography.titleMedium.copyWith(
                            color: isEditMode ? AppColors.cyanPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Who's Watching?",
                              style: AppTypography.h1.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                shadows: const [
                                  Shadow(color: AppColors.cyanPrimary, blurRadius: 20),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose your aura to load custom recommendations, 4K audio/video settings & watchlist.',
                              style: AppTypography.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 36),

                            // Multi-Profile Grid
                            Wrap(
                              spacing: 28,
                              runSpacing: 28,
                              alignment: WrapAlignment.center,
                              children: [
                                ...profiles.map((profile) {
                                  return ProfileAvatarCard(
                                    profile: profile,
                                    isEditMode: isEditMode,
                                    onTap: () {
                                      if (isEditMode) {
                                        // Edit profile could open edit dialog
                                      } else {
                                        _handleProfileSelection(context, profile, profileProvider);
                                      }
                                    },
                                    onDelete: () => profileProvider.deleteProfile(profile.id),
                                  );
                                }),

                                // Add Profile Card
                                _AddProfileButton(
                                  onTap: () => AddProfileDialog.show(context),
                                ),
                              ],
                            ),

                            const SizedBox(height: 48),

                            // Kids PIN Toggle Bar
                            FrostedGlass(
                              borderRadius: 20,
                              blur: 16,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              backgroundColor: AppColors.surfaceDark.withOpacity(0.65),
                              border: Border.all(
                                color: profileProvider.isKidsPinEnabled
                                    ? AppColors.kidsModeAmber.withOpacity(0.4)
                                    : AppColors.glassBorder,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: profileProvider.isKidsPinEnabled
                                          ? AppColors.kidsModeAmber.withOpacity(0.15)
                                          : AppColors.glassSurface,
                                    ),
                                    child: Icon(
                                      Icons.security_rounded,
                                      size: 22,
                                      color: profileProvider.isKidsPinEnabled
                                          ? AppColors.kidsModeAmber
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kids PIN Protection',
                                          style: AppTypography.titleMedium.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          profileProvider.isKidsPinEnabled
                                              ? 'PIN Lock Active (Default: 1234)'
                                              : 'Parental PIN is currently turned off',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: profileProvider.isKidsPinEnabled
                                                ? AppColors.kidsModeAmber
                                                : AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: profileProvider.isKidsPinEnabled,
                                    activeColor: AppColors.kidsModeAmber,
                                    onChanged: (_) => _toggleKidsPin(context, profileProvider),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddProfileButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddProfileButton({required this.onTap});

  @override
  State<_AddProfileButton> createState() => _AddProfileButtonState();
}

class _AddProfileButtonState extends State<_AddProfileButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
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
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.glassSurface,
                  border: Border.all(
                    color: _isHovered ? AppColors.cyanPrimary : AppColors.glassBorder,
                    width: 1.5,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.cyanPrimary.withOpacity(0.3),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 36,
                    color: _isHovered ? AppColors.cyanPrimary : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add Profile',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: _isHovered ? AppColors.cyanPrimary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create New',
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
