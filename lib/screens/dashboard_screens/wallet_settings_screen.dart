import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';

class WalletSettingsScreen extends StatelessWidget {
  const WalletSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: staggeredEntrance(<Widget>[
              Row(
                children: <Widget>[
                  Pressable(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Wallet Settings',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SettingsLinkRow(
                leadingIcon: Icons.sell_outlined,
                label: 'Direct Debits',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.directDebits),
              ),
              const SizedBox(height: 12),
              _SettingsLinkRow(
                leadingIcon: Icons.account_balance_outlined,
                label: 'Added Banks',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.addedBanks),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SettingsLinkRow extends StatelessWidget {
  const _SettingsLinkRow({
    required this.leadingIcon,
    required this.label,
    this.onTap,
  });

  final IconData leadingIcon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Icon(leadingIcon, color: const Color(0xFFFF2D55), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
