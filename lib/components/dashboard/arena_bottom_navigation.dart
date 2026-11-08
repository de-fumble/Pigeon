import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';

class ArenaBottomNavigation extends StatelessWidget {
  const ArenaBottomNavigation({
    super.key,
    required this.activeIndex,
    this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    const List<_ArenaNavItem> items = <_ArenaNavItem>[
      _ArenaNavItem(label: 'Arena', svgAsset: AppIcons.arena),
      _ArenaNavItem(label: 'Markets', svgAsset: AppIcons.markets),
      _ArenaNavItem(label: 'Notifications', svgAsset: AppIcons.notifications),
      _ArenaNavItem(label: 'Search', svgAsset: AppIcons.search),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List<Widget>.generate(items.length, (int index) {
          final _ArenaNavItem item = items[index];
          final bool selected = index == activeIndex;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap == null
                  ? null
                  : () {
                      if (!selected) HapticFeedback.selectionClick();
                      onTap!(index);
                    },
              child: TweenAnimationBuilder<double>(
                // Starting partway lets the active tab settle in when a tab screen mounts.
                tween: Tween<double>(
                  begin: selected ? 0.4 : 0,
                  end: selected ? 1 : 0,
                ),
                duration: AppMotion.slow,
                curve: AppMotion.spring,
                builder: (BuildContext context, double t, Widget? _) {
                  final Color iconColor = Color.lerp(
                    AppColors.textMuted,
                    AppColors.accent,
                    t.clamp(0, 1),
                  )!;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: Offset(0, -2 * t),
                        child: Transform.scale(
                          scale: 1 + 0.08 * t,
                          child: AppSvgIcon(
                            asset: item.svgAsset,
                            size: 24,
                            color: iconColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: iconColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ArenaNavItem {
  const _ArenaNavItem({required this.label, required this.svgAsset});

  final String label;
  final String svgAsset;
}
