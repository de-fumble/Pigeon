import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class PostDetailActionSheet extends StatelessWidget {
  const PostDetailActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _SheetItem(label: 'Share post'),
          _DividerLine(),
          _SheetItem(label: 'Delete post'),
          _DividerLine(),
          _SheetItem(label: 'Hide post'),
        ],
      ),
    );
  }
}

class _SheetItem extends StatelessWidget {
  const _SheetItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.divider.withValues(alpha: 0.18),
    );
  }
}
