import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class SearchRecentItem extends StatelessWidget {
  const SearchRecentItem({super.key, this.circularAvatar = false});

  final bool circularAvatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedAlt,
            shape: circularAvatar ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circularAvatar ? null : BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6),
              _Line(width: 88),
              SizedBox(height: 8),
              _Line(width: 72),
            ],
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
