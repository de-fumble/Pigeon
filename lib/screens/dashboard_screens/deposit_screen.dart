import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/dashboard/bank_transfer_sheet.dart';
import 'package:pigeon/components/dashboard/funding_direct_debit_sheet.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

class DepositScreen extends StatelessWidget {
  const DepositScreen({super.key});

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
                    'Deposit',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DepositMethodRow(
                iconAsset: AppIcons.directDebit,
                label: 'Direct Debit',
                subtitle: 'Deposits directly from your bank',
                onTap: () => showFundingDirectDebitSheet(context),
              ),
              const SizedBox(height: 12),
              _DepositMethodRow(
                fallbackIcon: Icons.account_balance_outlined,
                label: 'Bank Transfer',
                subtitle: 'Transfer from your bank',
                onTap: () => showBankTransferSheet(context),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DepositMethodRow extends StatelessWidget {
  const _DepositMethodRow({
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.iconAsset,
    this.fallbackIcon,
  });

  final String? iconAsset;
  final IconData? fallbackIcon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

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
            SizedBox(
              width: 24,
              height: 24,
              child: fallbackIcon != null
                  ? Icon(fallbackIcon, color: const Color(0xFFFF2D55), size: 22)
                  : iconAsset != null
                  ? AppSvgIcon(asset: iconAsset!, size: 24)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
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
