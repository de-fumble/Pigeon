import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class PostDetailTopBar extends StatelessWidget {
  const PostDetailTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Pressable(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSecondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Reply',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
