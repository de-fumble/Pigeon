import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class PostDetailPostCard extends StatelessWidget {
  const PostDetailPostCard({
    super.key,
    required this.avatar,
    required this.avatarColor,
    required this.handle,
    required this.timeLabel,
    required this.body,
    required this.reactions,
    this.showMenu = true,
    this.avatarImage,
    this.iconBgColor,
    this.avatarUrl,
    this.replyCount = '900',
    this.reactionCount = '406',
    this.onAddReaction,
  });

  final String avatar;
  final String? avatarUrl;
  final String replyCount;
  final String reactionCount;
  final VoidCallback? onAddReaction;
  final Color avatarColor;
  final String? avatarImage;
  final Color? iconBgColor;
  final String handle;
  final String timeLabel;
  final String body;
  final List<PostDetailReaction> reactions;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final Widget avatarWidget = avatarUrl != null
        ? LiveThumb(
            url: avatarUrl,
            fallback: avatar,
            size: 36,
            backgroundColor: avatarColor,
          )
        : avatarImage != null
        ? Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor ?? avatarColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: AppSvgIcon(
              asset: avatarImage!,
              size: 20,
              color: const Color(0xFF1A1A1A),
            ),
          )
        : CircleAvatar(
            radius: 18,
            backgroundColor: avatarColor,
            child: Text(avatar, style: const TextStyle(fontSize: 14)),
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
            if (showMenu)
              const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.textMuted,
                size: 22,
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
            Pressable(
              onTap: onAddReaction,
              behavior: HitTestBehavior.opaque,
              child: const Icon(
                Icons.add_reaction_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              reactionCount,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(width: 14),
            ...reactions.expand(
              (PostDetailReaction reaction) => <Widget>[
                Text(reaction.icon, style: const TextStyle(fontSize: 18)),
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

class PostDetailReaction {
  const PostDetailReaction({required this.icon, required this.count});

  final String icon;
  final String count;
}
