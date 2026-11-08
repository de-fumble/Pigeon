import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

class SearchInputBar extends StatelessWidget {
  const SearchInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.active,
    required this.onTap,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                cursorColor: AppColors.accent,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIconConstraints: BoxConstraints(minWidth: 24),
                  prefixIcon: AppSvgIcon(
                    asset: AppIcons.search,
                    size: 22,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Pressable(
            onTap: onCancel,
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return Pressable(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          children: [
            AppSvgIcon(
              asset: AppIcons.search,
              size: 22,
              color: AppColors.textMuted,
            ),
            SizedBox(width: 10),
            Text(
              'Markets, Users, Topics, Events and More',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
