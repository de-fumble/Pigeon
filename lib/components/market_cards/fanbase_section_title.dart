import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class FanbaseSectionTitle extends StatelessWidget {
  const FanbaseSectionTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
