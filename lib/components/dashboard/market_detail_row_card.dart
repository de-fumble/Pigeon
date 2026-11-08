import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketDetailRowCard extends StatelessWidget {
  const MarketDetailRowCard({super.key, required this.items});

  final List<MarketDetailRowData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (int index = 0; index < items.length; index++) ...[
            _DetailRow(label: items[index].label, value: items[index].value),
            if (index != items.length - 1)
              Container(
                height: 1,
                color: AppColors.divider.withValues(alpha: 0.18),
              ),
          ],
        ],
      ),
    );
  }
}

class MarketDetailRowData {
  const MarketDetailRowData(this.label, this.value);

  final String label;
  final String value;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

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
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
