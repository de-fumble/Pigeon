import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

class ArenaPillChip extends StatelessWidget {
  const ArenaPillChip({
    super.key,
    required this.label,
    required this.iconColor,
    this.icon,
    this.svgAsset,
    this.iconBgColor,
    this.selected = false,
  });

  final String label;
  final IconData? icon;
  final String? svgAsset;
  final Color iconColor;
  final Color? iconBgColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Widget? rawIcon = svgAsset != null
        ? AppSvgIcon(asset: svgAsset!, size: 16, color: iconColor)
        : (icon != null ? Icon(icon, size: 16, color: iconColor) : null);

    final Widget? iconWidget = rawIcon == null
        ? null
        : (iconBgColor != null
              ? Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: rawIcon,
                )
              : rawIcon);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: selected ? AppColors.surface : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? AppColors.divider.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (iconWidget != null) ...<Widget>[
            iconWidget,
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.buttonText : AppColors.textMuted,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
