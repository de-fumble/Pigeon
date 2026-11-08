import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';

class AdminSummaryCard extends StatelessWidget {
  const AdminSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.iconAsset,
    required this.backgroundColor,
    this.showChevron = true,
    this.onTap,
  });

  final String label;
  final String value;
  final String iconAsset;
  final Color backgroundColor;
  final bool showChevron;
  final VoidCallback? onTap;

  static const double _cardHeight = 120;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: SizedBox(
          height: _cardHeight,
          child: Stack(
            children: <Widget>[
              if (showChevron)
                const Positioned(
                  top: 20,
                  right: 20,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF6B7473),
                    size: 16,
                  ),
                ),
              Positioned(
                top: 30,
                left: 30,
                child: AppSvgIcon(asset: iconAsset, size: 25),
              ),
              Positioned(
                top: 65,
                left: 30,
                right: 12,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7473),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
              Positioned(
                top: 92,
                left: 30,
                right: 12,
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
