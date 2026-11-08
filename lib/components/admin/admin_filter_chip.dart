import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';

class AdminFilterChip extends StatelessWidget {
  const AdminFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: AppMotion.medium,
        curve: AppMotion.standard,
        style: TextStyle(
          color: selected ? AppColors.textPrimary : const Color(0xFFB0B0B0),
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          height: 1.2,
        ),
        child: Text(label),
      ),
    );
  }
}
