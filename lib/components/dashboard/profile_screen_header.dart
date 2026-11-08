import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class ProfileScreenHeader extends StatelessWidget {
  const ProfileScreenHeader({
    super.key,
    required this.handle,
    required this.onBack,
    required this.onWalletTap,
    required this.onMoreTap,
  });

  final String handle;
  final VoidCallback onBack;
  final VoidCallback onWalletTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Pressable(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          handle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Pressable(
          onTap: onWalletTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Pressable(
          onTap: onMoreTap,
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.backgroundSecondary,
            child: Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
