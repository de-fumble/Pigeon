import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketPositionActionButtons extends StatelessWidget {
  const MarketPositionActionButtons({
    super.key,
    required this.onCashOut,
    required this.onBuy,
  });

  final VoidCallback onCashOut;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onCashOut,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.backgroundSecondary,
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Sell'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: FilledButton(
            onPressed: onBuy,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.buttonText,
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Buy'),
          ),
        ),
      ],
    );
  }
}
