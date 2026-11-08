import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.12,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
          ),
        ],
      ],
    );
  }
}
