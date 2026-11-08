import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class VerificationBanner extends StatelessWidget {
  const VerificationBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
