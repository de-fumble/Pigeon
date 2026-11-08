import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/dob_picker_sheet.dart';
import 'package:pigeon/components/shared/app_dialogs.dart';
import 'package:pigeon/components/shared/app_profile_avatar.dart';
import 'package:pigeon/components/shared/app_toast.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/sign_out_flow.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/account_service.dart';
import 'package:pigeon/services/auth_service.dart';
import 'package:pigeon/services/supabase_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

/// The one place for everything about the signed-in user: profile, sign-in
/// details, wallet, notifications, support and logging out. Visitors get a
/// log-in prompt instead.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Object? _loadError;
  NotificationPrefs? _prefs;

  @override
  void initState() {
    super.initState();
    if (SupabaseService.isSignedIn) _load();
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    try {
      final (_, NotificationPrefs prefs) = await (
        AccountService.refresh(),
        AccountService.fetchNotificationPrefs(),
      ).wait;
      if (mounted) setState(() => _prefs = prefs);
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Profile
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _editUsername(AccountState account) async {
    final String? value = await showTextInputDialog(
      context,
      title: 'Username',
      hint: 'Letters, numbers, dots or underscores',
      initial: account.profile.username,
    );
    if (value == null || value == account.profile.username || !mounted) return;
    await runWithToast(
      context,
      () => AccountService.updateUsername(value),
      success: 'Username updated.',
    );
  }

  Future<void> _editBio(AccountState account) async {
    final String? value = await showTextInputDialog(
      context,
      title: 'Bio',
      hint: 'Tell people about yourself',
      initial: account.profile.bio ?? '',
      maxLines: 4,
      maxLength: 160,
      allowEmpty: true,
    );
    if (value == null || value == (account.profile.bio ?? '') || !mounted) {
      return;
    }
    await runWithToast(
      context,
      () => AccountService.updateBio(value),
      success: 'Bio updated.',
    );
  }

  Future<void> _editDateOfBirth(AccountState account) async {
    final DateTime? picked = await showDateOfBirthPicker(
      context,
      initial: account.dateOfBirth,
    );
    if (picked == null || picked == account.dateOfBirth || !mounted) return;
    await runWithToast(
      context,
      () => AccountService.updateDateOfBirth(picked),
      success: 'Date of birth updated.',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sign-in details
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _changeEmail(AccountState account) async {
    final String? email = await showTextInputDialog(
      context,
      title: 'Change email',
      hint: 'New email address',
      initial: account.email ?? '',
      keyboardType: TextInputType.emailAddress,
    );
    if (email == null || email == account.email || !mounted) return;
    await runWithToast(
      context,
      () => AuthService.updateEmail(email),
      success: 'Check $email for a link to confirm the change.',
    );
  }

  Future<void> _changePassword() async {
    final String? password = await showTextInputDialog(
      context,
      title: 'New password',
      hint: 'At least 6 characters',
      obscureText: true,
    );
    if (password == null || !mounted) return;
    final String? again = await showTextInputDialog(
      context,
      title: 'Confirm password',
      hint: 'Type it again',
      obscureText: true,
    );
    if (again == null || !mounted) return;
    if (again != password) {
      AppToast.show(context, message: "Passwords don't match.");
      return;
    }
    await runWithToast(
      context,
      () => AuthService.updatePassword(password),
      success: 'Password updated.',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Notifications & account
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _setPrefs(NotificationPrefs next) async {
    final NotificationPrefs? previous = _prefs;
    setState(() => _prefs = next);
    final bool ok = await runWithToast(
      context,
      () => AccountService.updateNotificationPrefs(next),
    );
    if (!ok && mounted) setState(() => _prefs = previous);
  }

  Future<void> _deleteAccount() async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete your account?',
      message:
          'Your account is scheduled for deletion and you are logged out. '
          'Withdraw your balance and close open positions first.',
    );
    if (!confirmed || !mounted) return;
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    final bool ok = await runWithToast(context, () async {
      await AccountService.requestDeletion();
      await AuthService.signOut();
    }, success: 'Account deletion requested.');
    if (ok) {
      navigator.pushNamedAndRemoveUntil(
        AppRouter.onboarding,
        (Route<dynamic> route) => false,
      );
    }
  }

  void _open(String route) => Navigator.of(context).pushNamed(route);

  // ─────────────────────────────────────────────────────────────────────────
  // Layout
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Row(
                children: <Widget>[
                  Pressable(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Account',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<AccountState?>(
                valueListenable: AccountService.current,
                builder: (BuildContext context, AccountState? account, _) {
                  if (!SupabaseService.isSignedIn) return _buildGuest();
                  if (account == null) {
                    return _loadError != null
                        ? LiveErrorState(error: _loadError!, onRetry: _load)
                        : const Padding(
                            padding: EdgeInsets.fromLTRB(18, 24, 18, 0),
                            child: LiveSkeleton(cards: 1, rows: 6),
                          );
                  }
                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: _load,
                    child: _buildAccount(account),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuest() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
      children: staggeredEntrance(<Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "You're not logged in",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Log in to manage your profile, wallet and settings.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _open(AppRouter.login),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.buttonText,
                        minimumSize: const Size(0, 46),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Log in'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _open(AppRouter.register),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        minimumSize: const Size(0, 46),
                        side: const BorderSide(color: AppColors.textMuted),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Create account'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const _SectionTitle('Support'),
        _Group(
          children: <Widget>[
            _Row(
              icon: Icons.headset_mic_outlined,
              label: 'Help Center / FAQs',
              onTap: () => _open(AppRouter.getSupport),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildAccount(AccountState account) {
    final NotificationPrefs? prefs = _prefs;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
      children: staggeredEntrance(<Widget>[
        _ProfileHeader(
          account: account,
          onViewProfile: () => _open(AppRouter.userProfile),
        ),
        const _SectionTitle('Profile'),
        _Group(
          children: <Widget>[
            _Row(
              label: 'Username',
              value: account.handle,
              onTap: () => _editUsername(account),
            ),
            _Row(
              label: 'Bio',
              value: account.profile.bio ?? 'Add a bio',
              muted: account.profile.bio == null,
              onTap: () => _editBio(account),
            ),
            _Row(
              label: 'Date of birth',
              value: account.dateOfBirth == null
                  ? 'Not set'
                  : LiveFormatters.shortDate(account.dateOfBirth!),
              muted: account.dateOfBirth == null,
              onTap: () => _editDateOfBirth(account),
            ),
          ],
        ),
        const _SectionTitle('Sign-in & security'),
        _Group(
          children: <Widget>[
            if (account.email != null || account.phone == null)
              _Row(
                label: 'Email',
                value: account.email ?? 'Not set',
                muted: account.email == null,
                onTap: () => _changeEmail(account),
              ),
            if (account.phone != null)
              _Row(label: 'Phone', value: account.phone!),
            _Row(label: 'Password', value: 'Change', onTap: _changePassword),
          ],
        ),
        const _SectionTitle('Wallet'),
        _Group(
          children: <Widget>[
            _Row(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Balance & predictions',
              onTap: () => _open(AppRouter.wallet),
            ),
            _Row(
              icon: Icons.account_balance_outlined,
              label: 'Banks & direct debits',
              onTap: () => _open(AppRouter.walletSettings),
            ),
          ],
        ),
        const _SectionTitle('Notifications'),
        _Group(
          children: prefs == null
              ? const <Widget>[_Row(label: 'Loading…', muted: true)]
              : <Widget>[
                  _SwitchRow(
                    label: 'Push',
                    value: prefs.push,
                    onChanged: (bool v) => _setPrefs((
                      push: v,
                      sms: prefs.sms,
                      email: prefs.email,
                    )),
                  ),
                  _SwitchRow(
                    label: 'SMS',
                    value: prefs.sms,
                    onChanged: (bool v) => _setPrefs((
                      push: prefs.push,
                      sms: v,
                      email: prefs.email,
                    )),
                  ),
                  _SwitchRow(
                    label: 'Email',
                    value: prefs.email,
                    onChanged: (bool v) =>
                        _setPrefs((push: prefs.push, sms: prefs.sms, email: v)),
                  ),
                ],
        ),
        const _SectionTitle('Support'),
        _Group(
          children: <Widget>[
            _Row(
              icon: Icons.headset_mic_outlined,
              label: 'Help Center / FAQs',
              onTap: () => _open(AppRouter.getSupport),
            ),
            if (account.isAdmin)
              _Row(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Admin Panel',
                onTap: () => _open(AppRouter.adminPanel),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _Group(
          children: <Widget>[
            _Row(
              icon: Icons.logout_rounded,
              label: 'Log out',
              color: AppColors.accent,
              onTap: () => confirmAndSignOut(context),
            ),
            _Row(
              icon: Icons.delete_outline_rounded,
              label: 'Delete account',
              color: const Color(0xFFFF2D55),
              onTap: _deleteAccount,
            ),
          ],
        ),
      ]),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.account, required this.onViewProfile});

  final AccountState account;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const AppProfileAvatar(size: 64),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                account.handle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Joined ${LiveFormatters.shortDate(account.profile.createdAt)}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Pressable(
                onTap: onViewProfile,
                child: const Text(
                  'View public profile',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 26, 4, 10),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Rounded card holding rows separated by hairlines.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0)
              const Divider(
                height: 1,
                indent: 18,
                endIndent: 18,
                color: AppColors.surfaceMutedAlt,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Label on the left, optional value and chevron on the right.
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    this.value,
    this.icon,
    this.onTap,
    this.color,
    this.muted = false,
  });

  final String label;
  final String? value;
  final IconData? icon;
  final VoidCallback? onTap;

  /// Tints icon and label, e.g. for Log out.
  final Color? color;

  /// Dims [value] (placeholders like "Not set").
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, color: color ?? AppColors.textMuted, size: 20),
            const SizedBox(width: 12),
          ],
          Text(
            label,
            style: TextStyle(
              color:
                  color ??
                  (value == null ? AppColors.textPrimary : AppColors.textMuted),
              fontSize: 16,
              fontWeight: color == null ? FontWeight.w400 : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: muted ? AppColors.textMuted : AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          if (onTap != null && color == null) ...<Widget>[
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return content;
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 10, 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.textPrimary,
            activeTrackColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
