import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketPositionTopBar extends StatelessWidget {
  const MarketPositionTopBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Pressable(
        onTap: onBack,
        child: const Padding(
          padding: EdgeInsets.all(2),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
