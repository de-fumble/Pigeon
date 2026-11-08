import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class PostComposerTopBar extends StatelessWidget {
  const PostComposerTopBar({
    super.key,
    required this.canPost,
    required this.onClose,
  });

  final bool canPost;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Pressable(
          onTap: onClose,
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
        Container(
          width: 84,
          height: 40,
          decoration: BoxDecoration(
            color: canPost ? AppColors.surface : AppColors.surfaceDisabled,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            'Post',
            style: TextStyle(
              color: canPost
                  ? AppColors.buttonText
                  : AppColors.buttonText.withValues(alpha: 0.4),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
