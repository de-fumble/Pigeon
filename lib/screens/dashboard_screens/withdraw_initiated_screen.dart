import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

class WithdrawInitiatedScreen extends StatelessWidget {
  const WithdrawInitiatedScreen({
    super.key,
    this.amount = 400,
    this.bankName = 'United Bank For Africa',
    this.accountNumber = '2039639364',
  });

  final int amount;
  final String bankName;
  final String accountNumber;

  String get _formattedAmount {
    final String s = amount.toString();
    final reversed = s.split('').reversed.toList();
    final withCommas = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        withCommas.add(',');
      }
      withCommas.add(reversed[i]);
    }
    return withCommas.reversed.join();
  }

  String get _shortAccount {
    if (accountNumber.length <= 4) return accountNumber;
    return '... (${accountNumber.substring(accountNumber.length - 4)})';
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
              Pressable(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFB48CFF),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: const AppSvgIcon(asset: AppIcons.hourglass, size: 30),
              ),
              const SizedBox(height: 18),
              const Text(
                'Withdrawal Initiated',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your withdrawal request of N$_formattedAmount is on its way to your bank account: $bankName$_shortAccount.',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).popUntil((Route<dynamic> r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.buttonText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: AppColors.buttonText,
                      fontSize: 16,
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
