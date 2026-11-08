import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';

class AdminTabSwitcher extends StatelessWidget {
  const AdminTabSwitcher({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftSelected,
    required this.onLeftTap,
    required this.onRightTap,
  });

  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabLabel(label: leftLabel, selected: leftSelected, onTap: onLeftTap),
        const SizedBox(width: 20),
        _TabLabel(
          label: rightLabel,
          selected: !leftSelected,
          onTap: onRightTap,
        ),
      ],
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
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
          fontSize: 20,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          height: 1.2,
        ),
        child: Text(label),
      ),
    );
  }
}
