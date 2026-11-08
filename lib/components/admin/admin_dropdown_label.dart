import 'package:flutter/cupertino.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

/// Tappable "Label ⌄" used to open admin filter dropdowns.
class AdminDropdownLabel extends StatelessWidget {
  const AdminDropdownLabel({
    super.key,
    required this.label,
    required this.onTap,
    this.fontSize = 20,
    this.color = AppColors.textPrimary,
    this.fontWeight = FontWeight.w500,
  });

  final String label;
  final VoidCallback onTap;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 2),
          Icon(CupertinoIcons.chevron_down, color: color, size: 12),
        ],
      ),
    );
  }
}
