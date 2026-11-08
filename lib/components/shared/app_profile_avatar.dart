import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/services/account_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

/// The signed-in user's avatar: their photo, or their initial on their
/// colour. Shows the default artwork while signed out.
class AppProfileAvatar extends StatelessWidget {
  const AppProfileAvatar({super.key, this.size = 40, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget image = ValueListenableBuilder<AccountState?>(
      valueListenable: AccountService.current,
      builder: (BuildContext context, AccountState? account, _) {
        final LiveProfile? profile = account?.profile;
        if (profile == null) {
          return AppSvgIcon(asset: AppIcons.avatarProfile, size: size);
        }
        return LiveThumb(
          url: profile.avatarUrl,
          fallback: profile.username.isEmpty
              ? '?'
              : profile.username[0].toUpperCase(),
          size: size,
          backgroundColor: profile.avatarColor != null
              ? LiveFormatters.color(profile.avatarColor)
              : LiveFormatters.avatarColorFor(profile.username),
        );
      },
    );
    if (onTap == null) return image;
    return Pressable(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: image,
    );
  }
}
