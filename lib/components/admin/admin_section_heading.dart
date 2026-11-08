import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class AdminSectionHeading extends StatelessWidget {
  const AdminSectionHeading({
    super.key,
    required this.title,
    required this.onDelete,
  });

  final String title;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        Pressable(
          onTap: onDelete,
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFD90125),
            size: 24,
          ),
        ),
      ],
    );
  }
}
