import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_toast.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/data_source_service.dart';
import 'package:pigeon/services/supabase_service.dart';

/// Admin Panel switch for what the user dashboard shows: the built-in stock
/// content or live data from the database. Applies to every user, so a
/// change is confirmed first.
class AdminDataSourceCard extends StatefulWidget {
  const AdminDataSourceCard({super.key});

  @override
  State<AdminDataSourceCard> createState() => _AdminDataSourceCardState();
}

class _AdminDataSourceCardState extends State<AdminDataSourceCard> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Pick up changes made elsewhere since the app started.
    DataSourceService.refresh().catchError((_) {});
  }

  Future<void> _select(UserDataSource next) async {
    if (_saving || next == DataSourceService.current.value) return;
    // The RPC is only granted to signed-in users (and then checks for admin).
    if (!SupabaseService.isSignedIn) {
      AppToast.show(
        context,
        message: 'Log in with an admin account to change this.',
      );
      Navigator.of(context).pushNamed(AppRouter.login);
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          next == UserDataSource.live
              ? 'Switch users to live data?'
              : 'Switch users to stock data?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          next == UserDataSource.live
              ? 'Every user will see real markets, posts, wallets and '
                    'notifications from the database. Trades will move real '
                    'balances.'
              : 'Every user will see the built-in demo content. Nothing in '
                    'the database is changed.',
          style: const TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Switch',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await DataSourceService.setSource(next);
      if (!mounted) return;
      AppToast.show(
        context,
        variant: AppToastVariant.success,
        message: next == UserDataSource.live
            ? 'Users now see live data.'
            : 'Users now see stock data.',
      );
    } catch (e) {
      if (mounted) AppToast.show(context, message: liveErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserDataSource>(
      valueListenable: DataSourceService.current,
      builder: (BuildContext context, UserDataSource source, _) {
        final bool live = source == UserDataSource.live;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'User data',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: AppMotion.medium,
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: live
                          ? const Color(0xFF1FD36B)
                          : const Color(0xFFEF9520),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _saving ? 'Saving…' : (live ? 'Live' : 'Stock'),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                live
                    ? 'The user dashboard reads markets, posts, wallets and '
                          'notifications from the database.'
                    : 'The user dashboard shows the built-in demo content.',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: <Widget>[
                    _Segment(
                      label: 'Stock data',
                      selected: !live,
                      onTap: () => _select(UserDataSource.stock),
                    ),
                    _Segment(
                      label: 'Live database',
                      selected: live,
                      onTap: () => _select(UserDataSource.live),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.standard,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.buttonText : AppColors.textMuted,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
