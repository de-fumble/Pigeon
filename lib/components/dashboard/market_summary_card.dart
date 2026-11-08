import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketSummaryCard extends StatelessWidget {
  const MarketSummaryCard({
    super.key,
    required this.question,
    required this.position,
    this.avatar,
    this.avatarAsset,
    this.avatarColor = const Color(0xFFD9D9D9),
    this.compact = false,
  });

  final String question;
  final String position;
  final String? avatar;
  final String? avatarAsset;
  final Color avatarColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double radius = compact ? 18 : 22;
    final Widget avatarWidget = avatarAsset != null
        ? Container(
            width: radius * 2,
            height: radius * 2,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(avatarColor, BlendMode.multiply),
              child: Image.asset(
                avatarAsset!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
              ),
            ),
          )
        : CircleAvatar(
            radius: radius,
            backgroundColor: avatarColor,
            child: Text(
              avatar ?? '',
              style: TextStyle(fontSize: compact ? 16 : 18),
            ),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatarWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: compact ? 24 : 30,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Your position',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: compact ? 15 : 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          position,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: compact ? 20 : 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
