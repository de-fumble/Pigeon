import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class SectionSubtitle extends StatelessWidget {
  const SectionSubtitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
