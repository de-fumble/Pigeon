import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketActionMenu extends StatelessWidget {
  const MarketActionMenu({super.key, required this.onDetailsTap});

  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Item(label: 'Market details', onTap: onDetailsTap),
          const _Divider(),
          const _Item(label: 'Inactivate'),
          const _Divider(),
          const _Item(label: 'Pause'),
          const _Divider(),
          const _Item(label: 'Hide'),
          const _Divider(),
          const _Item(label: 'Conclude'),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
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
