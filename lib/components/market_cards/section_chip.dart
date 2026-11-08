import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_spacing.dart';

enum SectionChipVariant { shelves, comingSoon, listMarket, cardMarkets }

class SectionChip extends StatelessWidget {
  const SectionChip({super.key, required this.variant, this.label});

  final SectionChipVariant variant;
  final String? label;

  static const double _chipMaxWidth = 230;

  String _resolveLabel() {
    if (label != null) return label!;
    switch (variant) {
      case SectionChipVariant.shelves:
        return 'SHELVES';
      case SectionChipVariant.comingSoon:
        return 'COMING SOON MARKETS';
      case SectionChipVariant.listMarket:
        return 'LIST MARKET';
      case SectionChipVariant.cardMarkets:
        return 'CARD MARKETS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _chipMaxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE6E6E6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _resolveLabel(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.buttonText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
