import 'package:flutter/material.dart';
import 'package:pigeon/components/dashboard/dashboard_shell.dart';
import 'package:pigeon/components/shared/account_buttons.dart';
import 'package:pigeon/constants/app_colors.dart';

/// Arena header: side menu on the left, account (or Join) on the right, and
/// an optional [title] between them.
class ArenaTopBar extends StatelessWidget {
  const ArenaTopBar({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    const Widget leading = SideMenuButton();
    const Widget trailing = AccountButton();

    // Beside the dashboard sidebar the menu and account buttons step aside,
    // so name the tab instead of leaving the bar empty.
    final String? heading =
        title ?? (DashboardScope.hasSideNav(context) ? 'Arena' : null);

    if (heading == null) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[leading, trailing],
      );
    }
    return Row(
      children: <Widget>[
        leading,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              heading,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
        ),
        trailing,
      ],
    );
  }
}
