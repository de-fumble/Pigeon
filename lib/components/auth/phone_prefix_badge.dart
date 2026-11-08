import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class PhonePrefixBadge extends StatelessWidget {
  const PhonePrefixBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: const Text('🇳🇬', style: TextStyle(fontSize: 28)),
    );
  }
}
