import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_profile_avatar.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/sign_out_flow.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/account_service.dart';
import 'package:pigeon/services/supabase_service.dart';

/// Slides the app's side menu in from the left. Signed-in users get their
/// account and its shortcuts; visitors get a log-in prompt. Admins (or any
/// caller passing [showAdminLink]) also see the Admin Panel link.
void showSidebar(BuildContext context, {bool showAdminLink = false}) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Menu',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder:
        (
          BuildContext dialogContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          final double width = MediaQuery.sizeOf(dialogContext).width * 0.78;
          return Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: AppColors.background,
              child: SizedBox(
                width: width,
                height: double.infinity,
                child: SidebarSheet(showAdminLink: showAdminLink),
              ),
            ),
          );
        },
    transitionBuilder:
        (
          BuildContext transitionContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final Animation<Offset> slide =
              Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
  );
}

class SidebarSheet extends StatelessWidget {
  const SidebarSheet({super.key, this.showAdminLink = false});

  /// Always show the Admin Panel link (the Admin Panel's own menu).
  final bool showAdminLink;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<AccountState?>(
        valueListenable: AccountService.current,
        builder: (BuildContext context, AccountState? account, _) {
          final bool signedIn = account != null || SupabaseService.isSignedIn;
          final bool admin = showAdminLink || (account?.isAdmin ?? false);
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (signedIn)
                  _AccountHeader(account: account)
                else
                  const _GuestHeader(),
                const SizedBox(height: 22),
                const Divider(color: AppColors.surfaceMutedAlt, height: 1),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      if (signedIn) ...<Widget>[
                        _MenuItem(
                          icon: Icons.person_outline_rounded,
                          label: 'My profile',
                          route: AppRouter.userProfile,
                        ),
                        _MenuItem(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Wallet',
                          route: AppRouter.wallet,
                        ),
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          label: 'Account & settings',
                          route: AppRouter.account,
                        ),
                      ],
                      _MenuItem(
                        icon: Icons.headset_mic_outlined,
                        label: 'Help & Support',
                        route: AppRouter.getSupport,
                      ),
                      if (admin) ...<Widget>[
                        const SizedBox(height: 8),
                        _MenuItem(
                          icon: Icons.admin_panel_settings_outlined,
                          label: 'Admin Panel',
                          route: AppRouter.adminPanel,
                        ),
                      ],
                    ],
                  ),
                ),
                if (signedIn) ...<Widget>[
                  const Divider(color: AppColors.surfaceMutedAlt, height: 1),
                  const SizedBox(height: 8),
                  Pressable(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => confirmAndSignOut(context),
                    child: const _MenuRow(
                      icon: Icons.logout_rounded,
                      label: 'Log out',
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Avatar, handle and contact; opens the Account screen.
class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.account});

  /// Null while the profile is still loading.
  final AccountState? account;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(AppRouter.account);
      },
      child: Row(
        children: <Widget>[
          const AppProfileAvatar(size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  account?.handle ?? 'Loading…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'View account',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
            size: 22,
          ),
        ],
      ),
    );
  }
}

/// Welcome text with Log in / Create account.
class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const AppSvgIcon(asset: AppIcons.adminEye, size: 50),
        const SizedBox(height: 16),
        const Text(
          'Welcome to Pigeon',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Log in to trade, post and manage your wallet.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton(
                onPressed: () => _go(context, AppRouter.login),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.buttonText,
                  minimumSize: const Size(0, 44),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Log in'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _go(context, AppRouter.register),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size(0, 44),
                  side: const BorderSide(color: AppColors.textMuted),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Sign up'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A menu row that closes the menu and opens [route].
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(route);
      },
      child: _MenuRow(icon: icon, label: label),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;

  /// Tints icon and label, e.g. for Log out.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color ?? AppColors.textMuted, size: 22),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontSize: 16,
              fontWeight: color == null ? FontWeight.w400 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
