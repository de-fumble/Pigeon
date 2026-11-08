import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class LegalTextBlock extends StatelessWidget {
  const LegalTextBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.35,
        ),
        children: [
          TextSpan(text: 'By clicking “Enter Pigeon,” you agree to Pigeon’s '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(color: AppColors.accent),
          ),
          TextSpan(text: ' and have read the '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
