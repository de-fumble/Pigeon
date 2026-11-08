import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class AdminMarketCreateDetailRow extends StatelessWidget {
  const AdminMarketCreateDetailRow({
    super.key,
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
    if (onTap == null) {
      return content;
    }
    return InkWell(onTap: onTap, child: content);
  }
}
