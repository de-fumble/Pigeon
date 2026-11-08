import 'package:flutter/material.dart';
import 'package:pigeon/components/dashboard/post_detail_post_card.dart';
import 'package:pigeon/constants/app_colors.dart';

class PostDetailReplyItem extends StatelessWidget {
  const PostDetailReplyItem({
    super.key,
    required this.avatar,
    required this.avatarColor,
    required this.handle,
    required this.timeLabel,
    required this.body,
    required this.reactions,
    this.showConnector = false,
    this.replyCountLabel,
    this.avatarImage,
    this.iconBgColor,
  });

  final String avatar;
  final String? avatarImage;
  final Color? iconBgColor;
  final Color avatarColor;
  final String handle;
  final String timeLabel;
  final String body;
  final List<PostDetailReaction> reactions;
  final bool showConnector;
  final String? replyCountLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              avatarImage != null
                  ? Container(
                      width: 32,
                      height: 32,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: iconBgColor ?? avatarColor,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          avatarImage!,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 16,
                      backgroundColor: avatarColor,
                      child: Text(avatar, style: const TextStyle(fontSize: 12)),
                    ),
              if (showConnector)
                Container(
                  width: 2,
                  height: 84,
                  margin: const EdgeInsets.only(top: 4),
                  color: AppColors.divider.withValues(alpha: 0.6),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
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
                    const Icon(
                      Icons.more_horiz_rounded,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.add_reaction_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    ...reactions.expand(
                      (PostDetailReaction reaction) => <Widget>[
                        Text(
                          reaction.icon,
                          style: const TextStyle(fontSize: 17),
                        ),
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
                if (replyCountLabel != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    replyCountLabel!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
