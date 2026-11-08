import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/account_buttons.dart';
import 'package:pigeon/constants/app_colors.dart';

class SearchScreenTopBar extends StatelessWidget {
  const SearchScreenTopBar({super.key, required this.showTitle});

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    if (!showTitle) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const SideMenuButton(),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Search',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const AccountButton(),
        ],
      ),
    );
  }
}
