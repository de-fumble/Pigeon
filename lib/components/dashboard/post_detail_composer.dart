import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class PostDetailComposer extends StatelessWidget {
  const PostDetailComposer({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget row = Row(
      children: [
        const AppSvgIcon(asset: AppIcons.avatarProfile, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Comment',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const AppSvgIcon(
                  asset: AppIcons.pencilEdit,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
    if (onTap == null) return row;
    return Pressable(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}
