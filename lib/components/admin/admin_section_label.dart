import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class AdminSectionLabel extends StatelessWidget {
  const AdminSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }
}

class AdminFieldValue extends StatelessWidget {
  const AdminFieldValue(this.value, {super.key, this.color});

  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        color: color ?? AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class AdminFieldTrailing extends StatelessWidget {
  const AdminFieldTrailing({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
    );
  }
}
