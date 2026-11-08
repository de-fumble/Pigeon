import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketTopBar extends StatelessWidget {
  const MarketTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.onMore,
    this.onShare,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onMore;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Pressable(
          onTap: onBack ?? () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (onMore != null) ...[
          Pressable(
            onTap: onMore,
            child: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 18),
        ],
        if (onShare != null)
          Pressable(
            onTap: onShare,
            child: const Icon(
              Icons.open_in_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
      ],
    );
  }
}
