import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';

class BankAccountLinkedScreen extends StatelessWidget {
  const BankAccountLinkedScreen({
    super.key,
    this.bankName = 'United Bank for Africa',
    this.accountNumber = '2039639364',
    this.accountName = 'ATABOH HAMID CHIDE',
    this.addedDate = '23rd May, 2026',
  });

  final String bankName;
  final String accountNumber;
  final String accountName;
  final String addedDate;

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
              const SizedBox(height: 22),
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
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppRouter.approvingActivity),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.buttonText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Continue',
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
