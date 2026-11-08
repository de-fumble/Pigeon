import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class InterestChip extends StatelessWidget {
  const InterestChip({
    super.key,
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD9D9D9)
              : AppColors.surfaceMutedAlt,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFF2F2F34),
          ),
        ),
        child: Text(
          '$emoji $label',
          style: TextStyle(
            color: isSelected ? AppColors.buttonText : AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
