import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/aura_glow_button.dart';
import 'widgets/otp_input_box.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _enteredOtp = '';
  int _secondsRemaining = AppConstants.otpTimeoutSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = AppConstants.otpTimeoutSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsRemaining = 0);
      } else {
        if (mounted) setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleVerify([String? code]) async {
    final otp = code ?? _enteredOtp;
    if (otp.length != AppConstants.otpLength) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(otp);
    if (ok && mounted) {
      context.go(RouteNames.whoIsWatching);
    }
  }

  void _autoFillDemoOtp() {
    setState(() => _enteredOtp = AppConstants.demoOtp);
    _handleVerify(AppConstants.demoOtp);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final identifier = auth.pendingIdentifier ?? 'your account';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardSurface,
                      border: Border.all(color: AppColors.glassBorderBright),
                    ),
                    child: const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.noirWhite,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Verify your identity', style: AppTypography.h2),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTypography.bodyMedium,
                      children: [
                        const TextSpan(
                          text: 'Enter the 6-digit verification code sent to\n',
                        ),
                        TextSpan(
                          text: identifier,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  OtpInputBox(
                    length: AppConstants.otpLength,
                    onChanged: (val) {
                      setState(() => _enteredOtp = val);
                      if (auth.errorMessage != null) auth.clearError();
                    },
                    onCompleted: (val) {
                      _enteredOtp = val;
                      _handleVerify(val);
                    },
                  ),

                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      auth.errorMessage!,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: _autoFillDemoOtp,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 15,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Auto-fill Demo Code (${AppConstants.demoOtp})',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  AuraGlowButton(
                    label: 'Verify & Continue',
                    isLoading: auth.isLoading,
                    onPressed: _enteredOtp.length == AppConstants.otpLength
                        ? () => _handleVerify()
                        : null,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 18),

                  TextButton(
                    onPressed: _secondsRemaining == 0 ? _startTimer : null,
                    child: Text(
                      _secondsRemaining > 0
                          ? 'Resend code in ${_secondsRemaining}s'
                          : 'Resend verification code',
                      style: AppTypography.bodySmall.copyWith(
                        color: _secondsRemaining > 0
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
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
    );
  }
}
