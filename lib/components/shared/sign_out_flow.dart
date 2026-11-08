import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_toast.dart';
import 'package:pigeon/components/shared/motion/submit_state.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/auth_service.dart';

/// Asks the user to confirm, signs them out, and returns them to onboarding
/// with the navigation history cleared.
Future<void> confirmAndSignOut(BuildContext context) async {
  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
  final bool? signedOut = await showDialog<bool>(
    context: context,
    builder: (BuildContext _) => const _SignOutDialog(),
  );
  if (signedOut != true) return;
  navigator.pushNamedAndRemoveUntil(
    AppRouter.onboarding,
    (Route<dynamic> route) => false,
  );
}

class _SignOutDialog extends StatefulWidget {
  const _SignOutDialog();

  @override
  State<_SignOutDialog> createState() => _SignOutDialogState();
}

class _SignOutDialogState extends State<_SignOutDialog> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await AuthService.signOut();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _signingOut = false);
      AppToast.show(context, message: 'Couldn’t log out. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundSecondary,
      title: const Text(
        'Log out?',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: const Text(
        'You’ll need to sign in again to trade and post.',
        style: TextStyle(color: AppColors.textMuted),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _signingOut ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: _signOut,
          child: ButtonLoadingContent(
            isLoading: _signingOut,
            dotsColor: AppColors.accent,
            child: const Text(
              'Log out',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
