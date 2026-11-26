import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/profile_provider.dart';
import '../common/aura_glow_button.dart';
import '../common/aura_text_field.dart';

class AddProfileDialog extends StatefulWidget {
  const AddProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => const AddProfileDialog(),
    );
  }

  @override
  State<AddProfileDialog> createState() => _AddProfileDialogState();
}

class _AddProfileDialogState extends State<AddProfileDialog> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = const Color(0xFF2563EB);
  String _selectedIcon = 'person';
  bool _isKids = false;
  String? _errorText;

  static const List<Color> _paletteColors = [
    Color(0xFF2563EB),
    Color(0xFFE11D48),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF7C3AED),
  ];

  static const Map<String, IconData> _iconOptions = {
    'person': Icons.person_rounded,
    'movie': Icons.movie_creation_outlined,
    'child_care': Icons.sentiment_satisfied_alt_rounded,
    'star': Icons.star_rounded,
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      setState(() => _errorText = 'Enter at least 2 characters');
      return;
    }

    context.read<ProfileProvider>().addProfile(
          name: name,
          color: _isKids ? AppColors.kidsModeAmber : _selectedColor,
          icon: _isKids ? 'child_care' : _selectedIcon,
          isKids: _isKids,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Profile', style: AppTypography.h2),
                const SizedBox(height: 6),
                Text(
                  'Create an individualized viewing space with custom preferences.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 20),

                AuraTextField(
                  controller: _nameController,
                  labelText: 'Profile Name',
                  hintText: 'e.g. Sarah',
                  prefixIcon: Icons.badge_outlined,
                  errorText: _errorText,
                  onChanged: (_) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                ),
                const SizedBox(height: 20),

                Text('Profile Color', style: AppTypography.bodySmall),
                const SizedBox(height: 10),
                Row(
                  children: _paletteColors.map((c) {
                    final selected = _selectedColor == c && !_isKids;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedColor = c;
                        _isKids = false;
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.noirWhite
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                Text('Avatar Icon', style: AppTypography.bodySmall),
                const SizedBox(height: 10),
                Row(
                  children: _iconOptions.entries.map((entry) {
                    final selected = _selectedIcon == entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = entry.key),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.noirWhite
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Icon(
                          entry.value,
                          color: selected
                              ? AppColors.background
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kids Profile', style: AppTypography.titleMedium),
                          Text(
                            'PG-only library & PIN exit lock',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      Switch(
                        value: _isKids,
                        activeThumbColor: AppColors.kidsModeAmber,
                        onChanged: (v) => setState(() => _isKids = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: AuraGlowButton(
                        label: 'Cancel',
                        isSecondary: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuraGlowButton(
                        label: 'Create',
                        onPressed: _saveProfile,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
