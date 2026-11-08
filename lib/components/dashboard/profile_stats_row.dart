import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/constants/app_colors.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.avatar,
    required this.avatarColor,
    required this.volume,
    required this.posts,
    required this.activity,
    this.avatarUrl,
  });

  final String avatar;
  final Color avatarColor;
  final String volume;
  final String posts;
  final String activity;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (avatarUrl != null)
          LiveThumb(
            url: avatarUrl,
            fallback: avatar,
            size: 56,
            backgroundColor: avatarColor,
            fallbackStyle: const TextStyle(fontSize: 26),
          )
        else
          CircleAvatar(
            radius: 28,
            backgroundColor: avatarColor,
            child: Text(avatar, style: const TextStyle(fontSize: 26)),
          ),
        const SizedBox(width: 18),
        _StatColumn(label: 'VOLUME', value: volume),
        const SizedBox(width: 22),
        _StatColumn(label: 'POSTS', value: posts),
        const SizedBox(width: 22),
        _StatColumn(label: 'ACTIVITY', value: activity),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
