import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

/// White pill button used for admin actions ("Create", "Next", ...).
class AdminCreateButton extends StatelessWidget {
  const AdminCreateButton({
    super.key,
    required this.onPressed,
    this.label = 'Create',
    this.height = 40,
    this.minWidth = 89,
    this.fontSize = 15,
  });

  final VoidCallback? onPressed;
  final String label;
  final double height;
  final double minWidth;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.textPrimary,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Container(
          height: height,
          constraints: BoxConstraints(minWidth: minWidth),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
