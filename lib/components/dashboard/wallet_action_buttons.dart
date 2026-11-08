import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class WalletActionButtons extends StatelessWidget {
  const WalletActionButtons({
    super.key,
    required this.onWithdraw,
    required this.onDeposit,
  });

  final VoidCallback onWithdraw;
  final VoidCallback onDeposit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 183,
          height: 50,
          child: FilledButton(
            onPressed: onWithdraw,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.backgroundSecondary,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Withdraw'),
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 183,
          height: 50,
          child: FilledButton(
            onPressed: onDeposit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.backgroundSecondary,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Deposit'),
          ),
        ),
      ],
    );
  }
}
