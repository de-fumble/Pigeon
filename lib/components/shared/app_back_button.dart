import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.backgroundSecondary,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(40, 40),
        ),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),
    );
  }
}
