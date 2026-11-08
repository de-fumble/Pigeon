import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketPositionStatsCard extends StatelessWidget {
  const MarketPositionStatsCard({
    super.key,
    required this.chance,
    required this.cost,
    required this.value,
    required this.change,
    required this.payout,
    this.changeColor,
  });

  final String chance;
  final String cost;
  final String value;
  final String change;
  final String payout;
  final Color? changeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _Row(label: 'Chance', value: chance),
          const _Divider(),
          _Row(label: 'Cost', value: cost),
          const _Divider(),
          _Row(label: 'Value', value: value),
          const _Divider(),
          _Row(
            label: 'Change',
            value: change,
            valueColor:
                changeColor ??
                (change.startsWith('-')
                    ? Colors.orangeAccent
                    : const Color(0xFF1FD36B)),
          ),
          const _Divider(),
          _Row(label: 'Payout if right', value: payout),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.divider.withValues(alpha: 0.18),
    );
  }
}
