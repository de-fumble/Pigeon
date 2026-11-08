import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

class AdminEngagementCard extends StatelessWidget {
  const AdminEngagementCard({
    super.key,
    required this.backgroundColor,
    required this.iconAsset,
    required this.title,
    required this.value,
  });

  final Color backgroundColor;
  final String iconAsset;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      padding: const EdgeInsets.fromLTRB(30, 30, 16, 0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(7),
            ),
            child: AppSvgIcon(asset: iconAsset, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
