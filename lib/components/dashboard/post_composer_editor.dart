import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

class PostComposerEditor extends StatelessWidget {
  const PostComposerEditor({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const AppSvgIcon(asset: AppIcons.avatarProfile, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: null,
            cursorColor: AppColors.accent,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: 'Say it before it happens.',
              hintStyle: TextStyle(
                color: AppColors.textMuted,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
