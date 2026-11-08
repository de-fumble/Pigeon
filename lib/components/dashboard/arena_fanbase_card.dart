import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class ArenaFanbaseCard extends StatelessWidget {
  const ArenaFanbaseCard({super.key, required this.title, required this.items});

  final String title;
  final List<ArenaFanbaseItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (int index = 0; index < items.length; index++) ...<Widget>[
            _FanbaseItem(
              avatar: items[index].avatar,
              title: items[index].title,
              avatarImage: items[index].avatarImage,
              avatarUrl: items[index].avatarUrl,
              avatarBgColor: items[index].avatarBgColor,
              onTap: items[index].onTap,
            ),
            if (index != items.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class ArenaFanbaseItemData {
  const ArenaFanbaseItemData({
    required this.avatar,
    required this.title,
    this.avatarImage,
    this.avatarBgColor,
    this.avatarUrl,
    this.onTap,
  });

  final String avatar;
  final String title;
  final String? avatarImage;
  final Color? avatarBgColor;
  final String? avatarUrl;
  final VoidCallback? onTap;
}

class _FanbaseItem extends StatelessWidget {
  const _FanbaseItem({
    required this.avatar,
    required this.title,
    this.avatarImage,
    this.avatarBgColor,
    this.avatarUrl,
    this.onTap,
  });

  final String avatar;
  final String title;
  final String? avatarImage;
  final Color? avatarBgColor;
  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool useImage = avatarImage != null;
    final Widget avatarWidget = avatarUrl != null
        ? LiveThumb(
            url: avatarUrl,
            fallback: avatar,
            size: 40,
            radius: 12,
            backgroundColor: avatarBgColor ?? AppColors.surface,
            fallbackStyle: const TextStyle(fontSize: 18),
          )
        : useImage
        ? Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: avatarBgColor ?? AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: AppSvgIcon(
              asset: avatarImage!,
              size: 40,
              color: const Color(0xFF1A1A1A),
            ),
          )
        : CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surface,
            child: Text(avatar, style: const TextStyle(fontSize: 18)),
          );

    final Widget row = Row(
      children: [
        avatarWidget,
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.north_east_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
      ],
    );
    if (onTap == null) return row;
    return Pressable(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}
