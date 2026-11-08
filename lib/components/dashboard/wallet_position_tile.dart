import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/constants/app_colors.dart';

class WalletPositionTile extends StatelessWidget {
  const WalletPositionTile({
    super.key,
    required this.avatar,
    required this.avatarColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.delta,
    this.onTap,
    this.iconAsset,
    this.iconUrl,
  });

  final String avatar;
  final Color avatarColor;
  final String title;
  final String subtitle;
  final String amount;
  final String delta;
  final VoidCallback? onTap;
  final String? iconAsset;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final Widget avatarWidget = iconUrl != null
        ? LiveThumb(
            url: iconUrl,
            fallback: avatar,
            size: 40,
            backgroundColor: avatarColor,
            fallbackStyle: const TextStyle(fontSize: 18),
          )
        : iconAsset != null
        ? ClipOval(
            child: Image.asset(
              iconAsset!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          )
        : CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            child: Text(avatar, style: const TextStyle(fontSize: 18)),
          );

    final Widget content = Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          avatarWidget,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                delta,
                style: TextStyle(
                  color: delta.startsWith('-')
                      ? const Color(0xFFFF2D55)
                      : const Color(0xFF1FD36B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
