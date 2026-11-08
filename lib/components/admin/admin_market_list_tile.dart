import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/utils/live_formatters.dart';

/// Grey avatar + bar skeleton row used for market lists without data yet.
class AdminMarketPlaceholder extends StatelessWidget {
  const AdminMarketPlaceholder({super.key, this.trailing, this.showDivider});

  final Widget? trailing;
  final bool? showDivider;

  @override
  Widget build(BuildContext context) {
    return AdminMarketListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFFC4C4C4),
          shape: BoxShape.circle,
        ),
      ),
      showDivider: showDivider ?? false,
      contentGap: 8,
      trailing: trailing,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 159,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }
}

/// 50px avatar row with an optional divider underneath the content,
/// laid out on the 70px rhythm used by the admin market lists.
class AdminMarketListTile extends StatelessWidget {
  const AdminMarketListTile({
    super.key,
    required this.leading,
    required this.child,
    this.showDivider = false,
    this.contentGap = 10,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final Widget child;
  final bool showDivider;
  final double contentGap;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 70,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: 50,
              child: Row(
                children: [
                  leading,
                  SizedBox(width: contentGap),
                  Expanded(child: child),
                  ?trailing,
                ],
              ),
            ),
            if (showDivider)
              const Positioned(
                left: 60,
                right: 0,
                top: 60,
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFF202020),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A database market on the 70px admin list rhythm: thumbnail, title, and a
/// "Category · Status · Volume" line.
class AdminMarketRow extends StatelessWidget {
  const AdminMarketRow({
    super.key,
    required this.market,
    this.showDivider = false,
    this.trailing,
    this.onTap,
  });

  final AdminMarket market;
  final bool showDivider;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String status =
        kAdminMarketStatusLabels[market.status] ?? market.status;
    return AdminMarketListTile(
      leading: LiveThumb(
        url: market.imageUrl,
        fallback: market.glyph,
        size: 50,
        backgroundColor: const Color(0xFF34343A),
        fallbackStyle: const TextStyle(fontSize: 22),
      ),
      showDivider: showDivider,
      trailing: trailing,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            market.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            <String>[
              market.subcategoryName ?? market.categoryName,
              status,
              if (market.isHidden) 'Hidden',
              LiveFormatters.naira(market.volumeKobo),
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
