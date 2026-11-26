import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class KidsPinDialog extends StatefulWidget {
  final String title;
  final String expectedPin;

  const KidsPinDialog({
    super.key,
    this.title = 'Parent Verification',
    this.expectedPin = AppConstants.defaultKidsPin,
  });

  static Future<bool> show(
    BuildContext context, {
    String title = 'Parent Verification',
    String expectedPin = AppConstants.defaultKidsPin,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => KidsPinDialog(title: title, expectedPin: expectedPin),
    );
    return result ?? false;
  }

  @override
  State<KidsPinDialog> createState() => _KidsPinDialogState();
}

class _KidsPinDialogState extends State<KidsPinDialog> {
  String _enteredPin = '';
  bool _hasError = false;

  void _onDigitTap(String digit) {
    if (_enteredPin.length < AppConstants.kidsPinLength) {
      setState(() {
        _hasError = false;
        _enteredPin += digit;
      });
      if (_enteredPin.length == AppConstants.kidsPinLength) {
        Future.delayed(const Duration(milliseconds: 120), () {
          if (!mounted) return;
          if (_enteredPin == widget.expectedPin) {
            Navigator.of(context).pop(true);
          } else {
            setState(() {
              _hasError = true;
              _enteredPin = '';
            });
          }
        });
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _hasError = false;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
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
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 32,
                color: AppColors.kidsModeAmber,
              ),
              const SizedBox(height: 12),
              Text(widget.title, style: AppTypography.h2),
              const SizedBox(height: 6),
              Text(
                'Enter your 4-digit PIN to exit Kids Mode.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(AppConstants.kidsPinLength, (index) {
                  final filled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.noirWhite : Colors.transparent,
                      border: Border.all(
                        color: _hasError
                            ? AppColors.error
                            : filled
                                ? AppColors.noirWhite
                                : AppColors.glassBorderBright,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                _hasError
                    ? 'Incorrect PIN. Default PIN: ${AppConstants.defaultKidsPin}'
                    : 'Default PIN: ${AppConstants.defaultKidsPin}',
                style: AppTypography.bodySmall.copyWith(
                  color: _hasError ? AppColors.error : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...List.generate(9, (i) => '${i + 1}').map((d) {
                    return _PinKeyButton(
                      label: d,
                      onTap: () => _onDigitTap(d),
                    );
                  }),
                  _PinKeyButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                  _PinKeyButton(
                    label: '0',
                    onTap: () => _onDigitTap('0'),
                  ),
                  _PinKeyButton(
                    icon: Icons.backspace_outlined,
                    onTap: _onBackspace,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinKeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _PinKeyButton({
    this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          alignment: Alignment.center,
          child: label != null
              ? Text(label!, style: AppTypography.h3)
              : Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
