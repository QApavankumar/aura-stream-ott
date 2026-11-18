import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/profile_provider.dart';
import '../common/frosted_glass.dart';
import '../common/aura_glow_button.dart';
import '../common/aura_text_field.dart';

class AddProfileDialog extends StatefulWidget {
  const AddProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) => const AddProfileDialog(),
    );
  }

  @override
  State<AddProfileDialog> createState() => _AddProfileDialogState();
}

class _AddProfileDialogState extends State<AddProfileDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _isKids = false;
  int _selectedColorIndex = 0;
  int _selectedIconIndex = 0;
  String? _errorMessage;

  final List<Color> _palette = [
    AppColors.cyanPrimary,
    AppColors.neonMagenta,
    AppColors.neonPurple,
    AppColors.neonBlue,
    AppColors.kidsModeAmber,
    AppColors.success,
  ];

  final List<String> _iconOptions = [
    'person',
    'movie',
    'child_care',
    'sports_esports',
    'rocket_launch',
    'auto_awesome',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onCreateProfile() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a profile name';
      });
      return;
    }

    final provider = context.read<ProfileProvider>();
    provider.addProfile(
      name: name,
      color: _palette[_selectedColorIndex],
      icon: _iconOptions[_selectedIconIndex],
      isKids: _isKids,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: FrostedGlass(
        borderRadius: 28,
        blur: 24,
        backgroundColor: AppColors.surfaceDark.withOpacity(0.92),
        border: Border.all(color: AppColors.glassBorderCyan, width: 1.2),
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Profile', style: AppTypography.h3),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name Input
                AuraTextField(
                  controller: _nameController,
                  hintText: "Enter profile name (e.g. Alex, Sci-Fi Fan)",
                  labelText: "PROFILE NAME",
                  prefixIcon: Icons.badge_outlined,
                  errorText: _errorMessage,
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Avatar Color Selection
                Text(
                  'AVATAR AURA COLOR',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_palette.length, (index) {
                    final color = _palette[index];
                    final isSelected = index == _selectedColorIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.6),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 20, color: Colors.black)
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Avatar Icon Selector
                Text(
                  'AVATAR SYMBOL',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_iconOptions.length, (index) {
                    final iconKey = _iconOptions[index];
                    final isSelected = index == _selectedIconIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconIndex = index),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? _palette[_selectedColorIndex].withOpacity(0.2)
                              : AppColors.glassSurface,
                          border: Border.all(
                            color: isSelected
                                ? _palette[_selectedColorIndex]
                                : AppColors.glassBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _getIconData(iconKey),
                          size: 22,
                          color: isSelected
                              ? _palette[_selectedColorIndex]
                              : AppColors.textMuted,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Kids Profile Toggle
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _isKids
                        ? AppColors.kidsModeAmber.withOpacity(0.12)
                        : AppColors.glassSurface,
                    border: Border.all(
                      color: _isKids
                          ? AppColors.kidsModeAmber.withOpacity(0.4)
                          : AppColors.glassBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.child_care_rounded,
                        color: _isKids ? AppColors.kidsModeAmber : AppColors.textMuted,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kids Safe Mode',
                              style: AppTypography.titleMedium.copyWith(
                                color: _isKids ? AppColors.kidsModeAmber : Colors.white,
                              ),
                            ),
                            Text(
                              'Filters content to age-appropriate titles and locks switching with a 4-digit PIN',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isKids,
                        activeColor: AppColors.kidsModeAmber,
                        onChanged: (val) {
                          setState(() {
                            _isKids = val;
                            if (val) {
                              _selectedIconIndex = 2; // Child care icon
                              _selectedColorIndex = 4; // Amber color
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action Buttons
                AuraGlowButton(
                  label: 'Create Profile',
                  icon: Icons.person_add_rounded,
                  onPressed: _onCreateProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'movie':
        return Icons.movie_creation_outlined;
      case 'child_care':
        return Icons.child_care_rounded;
      case 'sports_esports':
        return Icons.sports_esports_outlined;
      case 'rocket_launch':
        return Icons.rocket_launch_outlined;
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      case 'person':
      default:
        return Icons.person_rounded;
    }
  }
}
