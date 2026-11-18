import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/route_names.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/frosted_glass.dart';
import '../../widgets/common/aura_glow_button.dart';
import 'widgets/otp_input_box.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final GlobalKey<_OtpVerificationScreenState> _key = GlobalKey();
  String _enteredOtp = '';
  int _secondsRemaining = AppConstants.otpTimeoutSeconds;
  Timer? _timer;
  final GlobalKey<State<OtpInputBox>> _otpKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = AppConstants.otpTimeoutSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleVerify([String? code]) async {
    final otpToVerify = code ?? _enteredOtp;
    if (otpToVerify.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(otpToVerify);

    if (success && mounted) {
      context.go(RouteNames.whoIsWatching);
    }
  }

  void _useDemoOtp() {
    setState(() {
      _enteredOtp = AppConstants.demoOtp;
    });
    _handleVerify(AppConstants.demoOtp);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final identifier = auth.pendingIdentifier ?? '+1 (555) 019-2834';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: FrostedGlass(
                borderRadius: 24,
                blur: 20,
                backgroundColor: AppColors.surfaceDark.withOpacity(0.8),
                border: Border.all(color: AppColors.glassBorderCyan, width: 1.2),
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Shield Icon with cyan glow
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cyanPrimary.withOpacity(0.12),
                        border: Border.all(color: AppColors.cyanPrimary, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyanPrimary.withOpacity(0.35),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.cyanPrimary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('Two-Step Security', style: AppTypography.h2.copyWith(fontSize: 22)),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTypography.bodySmall,
                        children: [
                          const TextSpan(text: 'Enter the 6-digit verification code sent to\n'),
                          TextSpan(
                            text: identifier,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.cyanPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // OTP 6-digit input
                    OtpInputBox(
                      length: AppConstants.otpLength,
                      onChanged: (val) {
                        setState(() => _enteredOtp = val);
                        if (auth.errorMessage != null) {
                          auth.clearError();
                        }
                      },
                      onCompleted: (val) {
                        _enteredOtp = val;
                        _handleVerify(val);
                      },
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        auth.errorMessage!,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Quick Demo auto-fill helper
                    GestureDetector(
                      onTap: _useDemoOtp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.cyanPrimary.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.cyanPrimary.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: AppColors.cyanPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Auto-fill Demo Code (${AppConstants.demoOtp})',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.cyanPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Verify Button
                    AuraGlowButton(
                      label: 'Verify & Access Hub',
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: auth.isLoading,
                      onPressed: _enteredOtp.length == AppConstants.otpLength
                          ? () => _handleVerify()
                          : null,
                    ),

                    const SizedBox(height: 20),

                    // Resend Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _secondsRemaining > 0
                              ? 'Resend code in ${_secondsRemaining}s'
                              : "Didn't receive the code? ",
                          style: AppTypography.bodySmall,
                        ),
                        if (_secondsRemaining == 0)
                          GestureDetector(
                            onTap: () {
                              _startTimer();
                              auth.sendOtp(identifier);
                            },
                            child: Text(
                              'Resend OTP',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.cyanPrimary,
                                fontWeight: FontWeight.w700,
                              ),
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
      ),
    );
  }
}
