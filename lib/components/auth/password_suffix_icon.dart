import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class PasswordSuffixIcon extends StatelessWidget {
  const PasswordSuffixIcon({
    super.key,
    required this.obscureText,
    required this.onToggle,
  });

  final bool obscureText;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}
