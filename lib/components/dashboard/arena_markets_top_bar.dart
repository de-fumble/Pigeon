import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class ArenaMarketsTopBar extends StatelessWidget {
  const ArenaMarketsTopBar({super.key, this.onMenuTap, this.onJoinPressed});

  final VoidCallback? onMenuTap;
  final VoidCallback? onJoinPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Pressable(
          behavior: HitTestBehavior.opaque,
          onTap: onMenuTap,
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(
              Icons.menu_rounded,
              color: AppColors.textPrimary,
              size: 30,
            ),
          ),
        ),
        FilledButton(
          onPressed: onJoinPressed ?? () {},
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(78, 40),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Join'),
        ),
      ],
    );
  }
}
