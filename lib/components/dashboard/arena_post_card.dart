import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/constants/app_colors.dart';

class ArenaPostCard extends StatelessWidget {
  const ArenaPostCard({
    super.key,
    required this.avatar,
    required this.avatarColor,
    required this.handle,
    required this.timeLabel,
    required this.body,
    required this.reactions,
    this.embedded,
    this.avatarImage,
    this.iconBgColor,
    this.onMenuTap,
    this.avatarUrl,
    this.replyCount = '900',
    this.quoteCount = '406',
  });

  final String avatar;
  final String? avatarUrl;
  final String replyCount;
  final String quoteCount;
  final Color avatarColor;
  final String? avatarImage;
  final Color? iconBgColor;
  final String handle;
  final String timeLabel;
  final String body;
  final List<ArenaReaction> reactions;
  final Widget? embedded;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final Widget avatarWidget = avatarUrl != null
        ? LiveThumb(
            url: avatarUrl,
            fallback: avatar,
            size: 32,
            backgroundColor: avatarColor,
          )
        : avatarImage != null
        ? Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor ?? avatarColor,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: AppSvgIcon(
              asset: avatarImage!,
              size: 18,
              color: const Color(0xFF1A1A1A),
            ),
          )
        : CircleAvatar(
            radius: 16,
            backgroundColor: avatarColor,
            child: Text(avatar, style: const TextStyle(fontSize: 13)),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            avatarWidget,
            const SizedBox(width: 10),
            Text(
              handle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '• $timeLabel',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Pressable(
              onTap: onMenuTap,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            height: 1.35,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (embedded != null) ...<Widget>[
          const SizedBox(height: 14),
          embedded!,
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.mode_comment_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              replyCount,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(width: 14),
            const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              quoteCount,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(width: 14),
            ...reactions.expand(
              (reaction) => <Widget>[
                reaction.iconAsset != null
                    ? Image.asset(
                        reaction.iconAsset!,
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      )
                    : Text(reaction.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  reaction.count,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ArenaReaction {
  const ArenaReaction({
    required this.icon,
    required this.count,
    this.iconAsset,
  });

  final String icon;
  final String? iconAsset;
  final String count;
}
