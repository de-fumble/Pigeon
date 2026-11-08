import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class ResendCodeRow extends StatelessWidget {
  const ResendCodeRow({super.key, this.onResend});

  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textDim,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        children: [
          const TextSpan(text: 'Didn\u2019t receive any code? '),
          TextSpan(
            text: 'Resend Code',
            style: const TextStyle(color: AppColors.accent),
            recognizer: onResend != null
                ? (TapGestureRecognizer()..onTap = onResend)
                : null,
          ),
        ],
      ),
    );
  }
}
