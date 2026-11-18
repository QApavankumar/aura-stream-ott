import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class OtpInputBox extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInputBox({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputBox> createState() => _OtpInputBoxState();
}

class _OtpInputBoxState extends State<OtpInputBox> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onFieldChanged(int index, String value) {
    if (value.isNotEmpty) {
      // If user pasted multi-digit string
      if (value.length > 1) {
        final digits = value.split('');
        for (int i = 0; i < widget.length; i++) {
          if (i < digits.length) {
            _controllers[i].text = digits[i];
          }
        }
        _focusNodes[widget.length - 1].requestFocus();
      } else {
        // Single digit entered, advance focus
        if (index < widget.length - 1) {
          _focusNodes[index + 1].requestFocus();
        } else {
          _focusNodes[index].unfocus();
        }
      }
    } else {
      // Backspace entered
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    final otp = _currentOtp;
    widget.onChanged?.call(otp);
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
    setState(() {});
  }

  void setDemoOtp(String demoCode) {
    for (int i = 0; i < widget.length && i < demoCode.length; i++) {
      _controllers[i].text = demoCode[i];
    }
    setState(() {});
    widget.onChanged?.call(demoCode);
    widget.onCompleted(demoCode);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        final isFocused = _focusNodes[index].hasFocus;
        final hasValue = _controllers[index].text.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isFocused
                ? AppColors.cardSurface.withOpacity(0.9)
                : AppColors.cardSurface.withOpacity(0.5),
            border: Border.all(
              color: isFocused
                  ? AppColors.cyanPrimary
                  : (hasValue
                      ? AppColors.cyanPrimary.withOpacity(0.5)
                      : AppColors.glassBorder),
              width: isFocused ? 2.0 : 1.2,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.cyanPrimary.withOpacity(0.35),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: AppTypography.h3.copyWith(
                color: isFocused || hasValue ? AppColors.cyanPrimary : Colors.white,
                fontWeight: FontWeight.w700,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => _onFieldChanged(index, val),
            ),
          ),
        );
      }),
    );
  }
}
