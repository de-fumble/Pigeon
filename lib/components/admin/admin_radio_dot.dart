import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

/// Background of the market creation flow screens.
const Color kAdminFlowBackground = Color(0xFF131514);

/// 21px radio indicator: grey outline, or a solid accent dot when selected.
class AdminRadioDot extends StatelessWidget {
  const AdminRadioDot({super.key, required this.selected, this.size = 21});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.accent : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: const Color(0xFFB0B0B0), width: 1),
      ),
    );
  }
}
