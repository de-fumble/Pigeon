import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

enum BankDetailSource { directDebits, addedBanks }

class BankDetailScreen extends StatelessWidget {
  const BankDetailScreen({
    super.key,
    this.bankName = 'United Bank for Africa',
    this.accountNumber = '2039639364',
    this.accountName = 'ATABOH HAMID CHIDE',
    this.addedDate = '23rd May, 2026',
    this.source = BankDetailSource.addedBanks,
  });

  final String bankName;
  final String accountNumber;
  final String accountName;
  final String addedDate;
  final BankDetailSource source;

  String get _title =>
      source == BankDetailSource.directDebits ? 'Direct Debits' : 'Added Banks';

  void _confirmRemove(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundSecondary,
          title: const Text(
            'Remove bank account?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'This will remove the bank account from your wallet.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Remove',
                style: TextStyle(
                  color: Color(0xFFFF2D55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Pressable(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  Text(
                    _title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                alignment: Alignment.center,
                child: const AppSvgIcon(asset: AppIcons.ubaLarge, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                bankName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                accountNumber,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                accountName,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: <Widget>[
                    const Text(
                      'Added',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      addedDate,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => _confirmRemove(context),
                  child: const Text(
                    'Remove bank account',
                    style: TextStyle(
                      color: Color(0xFFFF2D55),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
