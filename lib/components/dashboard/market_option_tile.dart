import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketOptionTile extends StatelessWidget {
  const MarketOptionTile({
    super.key,
    this.avatar,
    this.avatarAsset,
    required this.avatarColor,
    required this.label,
    required this.percentage,
    required this.price,
    this.onTap,
  });

  final String? avatar;
  final String? avatarAsset;
  final Color avatarColor;
  final String label;
  final String percentage;
  final String price;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget avatarWidget = avatarAsset != null
        ? Container(
            width: 38,
            height: 38,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(avatarColor, BlendMode.multiply),
              child: Image.asset(
                avatarAsset!,
                width: 38,
                height: 38,
                fit: BoxFit.cover,
              ),
            ),
          )
        : CircleAvatar(
            radius: 19,
            backgroundColor: avatarColor,
            child: Text(avatar ?? '', style: const TextStyle(fontSize: 18)),
          );
    return Row(
      children: [
        avatarWidget,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                percentage,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Pressable(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 64,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              price,
              style: const TextStyle(
                color: AppColors.buttonText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
