import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/frosted_glass.dart';
import '../../widgets/common/aura_glow_button.dart';
import '../../widgets/common/aura_text_field.dart';
import '../../widgets/common/aura_logo.dart';
import 'widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _inputController = TextEditingController(text: '+1 (555) 019-2834');
  bool _isPhoneMode = true;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _switchMode(bool isPhone) {
    if (_isPhoneMode != isPhone) {
      setState(() {
        _isPhoneMode = isPhone;
        _inputController.text = isPhone ? '+1 (555) 019-2834' : 'alex.stream@auramedia.io';
      });
      context.read<AuthProvider>().clearError();
    }
  }

  Future<void> _handleSendOtp() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.sendOtp(
      _inputController.text,
      isPhone: _isPhoneMode,
    );

    if (success && mounted) {
      context.push(RouteNames.login + '/verify');
    }
  }

  Future<void> _handleGuestLogin() async {
    final auth = context.read<AuthProvider>();
    await auth.loginAsGuest();
    if (mounted) {
      context.go(RouteNames.whoIsWatching);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background atmospheric glows
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyanPrimary.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.neonPurple.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Logo
                      const AuraLogo(
                        size: 72,
                        showTagline: false,
                        isAnimated: false,
                      ),
                      const SizedBox(height: 12),

                      // Cloud Connection Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SupabaseConfig.isConfigured
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.kidsModeAmber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: SupabaseConfig.isConfigured
                                ? AppColors.success.withOpacity(0.5)
                                : AppColors.kidsModeAmber.withOpacity(0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: SupabaseConfig.isConfigured
                                    ? AppColors.success
                                    : AppColors.kidsModeAmber,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              SupabaseConfig.isConfigured
                                  ? 'SUPABASE CLOUD: CONNECTED'
                                  : 'DEMO MODE: LOCAL ENGINE',
                              style: TextStyle(
                                color: SupabaseConfig.isConfigured
                                    ? AppColors.success
                                    : AppColors.kidsModeAmber,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Glassmorphic Auth Card
                      FrostedGlass(
                        borderRadius: 24,
                        blur: 20,
                        backgroundColor: AppColors.surfaceDark.withOpacity(0.75),
                        border: Border.all(
                          color: AppColors.glassBorder.withOpacity(0.4),
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: AppTypography.h2.copyWith(fontSize: 22),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to access your synchronized profiles, watchlist & 4K streams.',
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: 22),

                            // Segmented Phone / Email Switcher
                            Container(
                              height: 44,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _SegmentTab(
                                      label: 'Phone Number',
                                      isSelected: _isPhoneMode,
                                      onTap: () => _switchMode(true),
                                    ),
                                  ),
                                  Expanded(
                                    child: _SegmentTab(
                                      label: 'Email Address',
                                      isSelected: !_isPhoneMode,
                                      onTap: () => _switchMode(false),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Input Field
                            AuraTextField(
                              controller: _inputController,
                              hintText: _isPhoneMode
                                  ? 'Enter mobile number'
                                  : 'Enter email address',
                              labelText: _isPhoneMode ? 'MOBILE NUMBER' : 'EMAIL ADDRESS',
                              prefixIcon: _isPhoneMode
                                  ? Icons.phone_android_rounded
                                  : Icons.alternate_email_rounded,
                              keyboardType: _isPhoneMode
                                  ? TextInputType.phone
                                  : TextInputType.emailAddress,
                              errorText: auth.errorMessage,
                            ),
                            const SizedBox(height: 24),

                            // Send OTP Button
                            AuraGlowButton(
                              label: 'Send Verification Code',
                              icon: Icons.lock_clock_outlined,
                              isLoading: auth.isLoading,
                              onPressed: _handleSendOtp,
                            ),
                            const SizedBox(height: 22),

                            // Or Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppColors.glassBorder)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(
                                    'OR SIGN IN WITH',
                                    style: AppTypography.badge.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppColors.glassBorder)),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Social Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: SocialLoginButton(
                                    icon: Icons.g_mobiledata_rounded,
                                    iconColor: Colors.redAccent,
                                    label: 'Google',
                                    onTap: _handleGuestLogin,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SocialLoginButton(
                                    icon: Icons.apple_rounded,
                                    label: 'Apple',
                                    onTap: _handleGuestLogin,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Guest Mode / Skip Link
                      TextButton.icon(
                        onPressed: _handleGuestLogin,
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.cyanPrimary,
                          size: 16,
                        ),
                        label: Text(
                          'Skip & Browse as Guest (Instant Access)',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.cyanPrimary,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: isSelected ? AppColors.cyanPrimary : Colors.transparent,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.cyanPrimary.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.dockLabel.copyWith(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
