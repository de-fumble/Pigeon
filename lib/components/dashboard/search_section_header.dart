import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class SearchSectionHeader extends StatelessWidget {
  const SearchSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
