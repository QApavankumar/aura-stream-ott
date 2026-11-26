import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/supabase_config.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/aura_glow_button.dart';
import '../../widgets/common/aura_logo.dart';
import '../../widgets/common/aura_text_field.dart';
import 'widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  bool _isPhoneMode = false;

  static const String _backdropUrl =
      'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=1400&q=80';

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _switchMode(bool isPhone) {
    if (_isPhoneMode == isPhone) return;
    setState(() {
      _isPhoneMode = isPhone;
      _identifierController.clear();
    });
    context.read<AuthProvider>().clearError();
  }

  Future<void> _handleSendOtp() async {
    final auth = context.read<AuthProvider>();
    final input = _identifierController.text.trim();
    final ok = await auth.sendOtp(input, isPhone: _isPhoneMode);
    if (ok && mounted) {
      context.push('${RouteNames.login}/verify');
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
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isWide
          ? Row(
              children: [
                Expanded(
                  flex: 6,
                  child: _AtmosphericCinemaPane(backdropUrl: _backdropUrl),
                ),
                Expanded(
                  flex: 5,
                  child: _buildAuthFormContainer(auth, isWide: true),
                ),
              ],
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.34,
                    child: Image.network(
                      _backdropUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.background),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.black.withValues(alpha: 0.92),
                          AppColors.background,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                _buildAuthFormContainer(auth, isWide: false),
              ],
            ),
    );
  }

  Widget _buildAuthFormContainer(AuthProvider auth, {required bool isWide}) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 44 : 20,
          vertical: 32,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AuraLogo(
                      size: 38,
                      showTagline: false,
                      isAnimated: false,
                    ),
                    _ConnectionStatusPill(
                      isConnected: SupabaseConfig.isConfigured,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Welcome back',
                  style: AppTypography.h1.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to continue your 4K HDR cinema library across devices.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Email / Phone Segmented Toggle
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SegmentTab(
                          label: 'Email',
                          isSelected: !_isPhoneMode,
                          onTap: () => _switchMode(false),
                        ),
                      ),
                      Expanded(
                        child: _SegmentTab(
                          label: 'Phone',
                          isSelected: _isPhoneMode,
                          onTap: () => _switchMode(true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                AuraTextField(
                  controller: _identifierController,
                  labelText: _isPhoneMode ? 'Mobile Number' : 'Email Address',
                  hintText:
                      _isPhoneMode ? '+1 (555) 234-5678' : 'alex@cinema.io',
                  prefixIcon:
                      _isPhoneMode ? Icons.phone_outlined : Icons.mail_outline,
                  keyboardType: _isPhoneMode
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  errorText: auth.errorMessage,
                  onChanged: (_) {
                    if (auth.errorMessage != null) auth.clearError();
                  },
                  onSubmitted: (_) => _handleSendOtp(),
                ),
                const SizedBox(height: 20),

                AuraGlowButton(
                  label: 'Continue',
                  isLoading: auth.isLoading,
                  onPressed: _handleSendOtp,
                  width: double.infinity,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.glassBorder),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: AppTypography.bodySmall.copyWith(
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.glassBorder),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SocialLoginButton(
                        icon: Icons.apple_rounded,
                        label: 'Apple',
                        onTap: _handleGuestLogin,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SocialLoginButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: 'Google',
                        onTap: _handleGuestLogin,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                TextButton.icon(
                  onPressed: auth.isLoading ? null : _handleGuestLogin,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  label: Text(
                    'Continue as Guest',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AtmosphericCinemaPane extends StatelessWidget {
  final String backdropUrl;

  const _AtmosphericCinemaPane({required this.backdropUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          backdropUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceDark),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.65),
                AppColors.background,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'AURA',
                style: AppTypography.brandLogo(fontSize: 22, letterSpacing: 6),
              ),
              const SizedBox(height: 16),
              Text(
                'Cinema without\nthe noise.',
                style: AppTypography.h1.copyWith(fontSize: 42),
              ),
              const SizedBox(height: 12),
              Text(
                '4K Dolby Vision • Spatial Atmos • Zero distraction.',
                style: AppTypography.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConnectionStatusPill extends StatelessWidget {
  final bool isConnected;

  const _ConnectionStatusPill({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final dotColor = isConnected ? AppColors.success : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isConnected ? 'Connected' : 'Demo Mode',
            style: AppTypography.bodySmall.copyWith(
              color: isConnected ? AppColors.success : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: isSelected ? AppColors.noirWhite : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.dockLabel.copyWith(
              fontSize: 12.5,
              color: isSelected ? AppColors.background : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
