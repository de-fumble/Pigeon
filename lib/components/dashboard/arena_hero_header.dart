import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class ArenaHeroHeader extends StatelessWidget {
  const ArenaHeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Today\'s Biggest Market',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 24,
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          'Move with the Flock!',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
