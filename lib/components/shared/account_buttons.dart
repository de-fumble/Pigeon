import 'package:flutter/material.dart';
import 'package:pigeon/components/dashboard/dashboard_shell.dart';
import 'package:pigeon/components/shared/app_profile_avatar.dart';
import 'package:pigeon/components/shared/app_side_menu.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/account_service.dart';
import 'package:pigeon/services/supabase_service.dart';

// The two buttons every dashboard tab puts in its top bar: the side menu on
// the left, the account on the right. On tablets and laptops the dashboard
// sidebar offers both, so they step aside there (see DashboardScope).

/// Opens the side menu.
class SideMenuButton extends StatelessWidget {
  const SideMenuButton({super.key, this.size = 30, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (DashboardScope.hasSideNav(context)) return const SizedBox.shrink();
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: () => showSidebar(context),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: AppSvgIcon(
          asset: AppIcons.menu,
          size: size,
          color: color ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// The user's avatar, opening the Account screen; a "Join" button instead
/// while signed out.
class AccountButton extends StatelessWidget {
  const AccountButton({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    if (DashboardScope.hasSideNav(context)) return const SizedBox.shrink();
    return ValueListenableBuilder<AccountState?>(
      valueListenable: AccountService.current,
      builder: (BuildContext context, AccountState? account, _) {
        // The session is known before the profile finishes loading.
        if (account == null && !SupabaseService.isSignedIn) {
          return FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.login),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size(78, 40),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Join'),
          );
        }
        return AppProfileAvatar(
          size: size,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.account),
        );
      },
    );
  }
}
