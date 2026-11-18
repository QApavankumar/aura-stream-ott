import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/route_names.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/aura_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();

    // Auto-navigate after splash duration
    _navTimer = Timer(AppConstants.splashDuration, _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();

    if (auth.isAuthenticated) {
      if (profile.activeProfile != null) {
        context.go(RouteNames.home);
      } else {
        context.go(RouteNames.whoIsWatching);
      }
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Atmospheric Light Cones
          Positioned(
            top: -size.height * 0.15,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.9,
              height: size.height * 0.5,
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
            bottom: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.height * 0.5,
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

          // Central Logo with Glowing Cyan Animation
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const AuraLogo(
                  size: 110,
                  showTagline: true,
                  isAnimated: true,
                ),
              ),
            ),
          ),

          // Bottom Loading Laser Indicator & Skip button
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cyan Glow Progress Line
                Container(
                  width: 140,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.glassSurface,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyanPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Skip Button for quick testing
                TextButton(
                  onPressed: _navigateNext,
                  child: Text(
                    'Skip to Login >>',
                    style: TextStyle(
                      color: AppColors.textMuted.withOpacity(0.7),
                      fontSize: 12,
                      letterSpacing: 1.0,
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
