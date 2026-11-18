import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../common/frosted_glass.dart';

class KidsPinDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String expectedPin;
  final ValueChanged<bool> onResult;

  const KidsPinDialog({
    super.key,
    this.title = 'Parental Lock',
    this.subtitle = 'Enter the 4-digit Kids PIN to continue',
    this.expectedPin = AppConstants.defaultKidsPin,
    required this.onResult,
  });

  static Future<bool> show(
    BuildContext context, {
    String title = 'Parental Lock',
    String subtitle = 'Enter the 4-digit Kids PIN to continue',
    String expectedPin = AppConstants.defaultKidsPin,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) => KidsPinDialog(
        title: title,
        subtitle: subtitle,
        expectedPin: expectedPin,
        onResult: (success) {
          Navigator.of(context).pop(success);
        },
      ),
    );
    return result ?? false;
  }

  @override
  State<KidsPinDialog> createState() => _KidsPinDialogState();
}

class _KidsPinDialogState extends State<KidsPinDialog> with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  bool _hasError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < AppConstants.kidsPinLength) {
      setState(() {
        _hasError = false;
        _enteredPin += digit;
      });

      if (_enteredPin.length == AppConstants.kidsPinLength) {
        _verifyPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _hasError = false;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    if (_enteredPin == widget.expectedPin) {
      widget.onResult(true);
    } else {
      setState(() {
        _hasError = true;
      });
      _shakeController.forward(from: 0.0).then((_) {
        setState(() {
          _enteredPin = '';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: FrostedGlass(
        borderRadius: 28,
        blur: 24,
        backgroundColor: AppColors.surfaceDark.withOpacity(0.88),
        border: Border.all(
          color: _hasError ? AppColors.error : AppColors.glassBorderCyan,
          width: 1.5,
        ),
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lock Icon with glowing background
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hasError
                      ? AppColors.error.withOpacity(0.15)
                      : AppColors.kidsModeAmber.withOpacity(0.15),
                  border: Border.all(
                    color: _hasError ? AppColors.error : AppColors.kidsModeAmber,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _hasError
                          ? AppColors.error.withOpacity(0.3)
                          : AppColors.kidsModeAmber.withOpacity(0.25),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Icon(
                  _hasError ? Icons.lock_clock_rounded : Icons.lock_outline_rounded,
                  color: _hasError ? AppColors.error : AppColors.kidsModeAmber,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                widget.title,
                style: AppTypography.h3.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // PIN Indicator Dots with shake animation on error
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_hasError ? _shakeAnimation.value : 0, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(AppConstants.kidsPinLength, (index) {
                    final isFilled = index < _enteredPin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _hasError
                            ? AppColors.error
                            : (isFilled ? AppColors.cyanPrimary : Colors.transparent),
                        border: Border.all(
                          color: _hasError
                              ? AppColors.error
                              : (isFilled
                                  ? AppColors.cyanPrimary
                                  : AppColors.glassBorder),
                          width: 2.0,
                        ),
                        boxShadow: isFilled && !_hasError
                            ? [
                                const BoxShadow(
                                  color: AppColors.cyanPrimary,
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 8),
              if (_hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Incorrect PIN. Default demo PIN: ${AppConstants.defaultKidsPin}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Default Demo PIN is ${AppConstants.defaultKidsPin}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.cyanPrimary.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Numeric Keypad
              _buildKeypad(),

              const SizedBox(height: 16),

              // Cancel button
              TextButton(
                onPressed: () => widget.onResult(false),
                child: Text(
                  'Cancel',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 12),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Clear all
            _KeypadButton(
              child: const Icon(Icons.clear, color: AppColors.textMuted, size: 20),
              onTap: () {
                setState(() {
                  _enteredPin = '';
                  _hasError = false;
                });
              },
            ),
            _KeypadButton(
              child: Text('0', style: AppTypography.h3),
              onTap: () => _onDigitPressed('0'),
            ),
            // Backspace
            _KeypadButton(
              child: const Icon(
                Icons.backspace_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onTap: _onBackspacePressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) {
        return _KeypadButton(
          child: Text(digit, style: AppTypography.h3),
          onTap: () => _onDigitPressed(digit),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassSurface,
            border: Border.all(
              color: AppColors.glassBorder.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
