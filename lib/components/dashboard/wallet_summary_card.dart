import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class WalletSummaryCard extends StatelessWidget {
  const WalletSummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.avatar,
    this.width = double.infinity,
  });

  final String label;
  final String amount;
  final String avatar;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFF9D4DC),
            child: Text(avatar, style: const TextStyle(fontSize: 19)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
