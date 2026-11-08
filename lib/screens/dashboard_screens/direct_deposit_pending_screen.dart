import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

class DirectDepositPendingScreen extends StatelessWidget {
  const DirectDepositPendingScreen({super.key});

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
                'Your payment is pending.',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We\'ll let you know when the transaction is complete.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
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
