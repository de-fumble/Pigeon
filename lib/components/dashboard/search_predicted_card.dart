import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class SearchPredictedCard extends StatelessWidget {
  const SearchPredictedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Text(
            'Champions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16),
          _PredictedItem(
            iconBackground: Color(0xFFFFFFFF),
            iconLabel: 'PL',
            iconColor: Color(0xFF5F2C82),
            title: 'Premier League',
          ),
          SizedBox(height: 18),
          _PredictedItem(
            iconBackground: Color(0xFF1A74D9),
            iconLabel: 'NBA',
            iconColor: Color(0xFFFFFFFF),
            title: 'NBA Kickoff',
          ),
          SizedBox(height: 18),
          _PredictedItem(
            iconBackground: Color(0xFF111111),
            iconLabel: 'WC',
            iconColor: Color(0xFFD9B35E),
            title: 'World Cup 2026',
          ),
          SizedBox(height: 18),
          _PredictedItem(
            iconBackground: Color(0xFF111111),
            iconLabel: 'W',
            iconColor: Color(0xFFFFFFFF),
            title: 'WWE Wrestlemania',
          ),
        ],
      ),
    );
  }
}

class _PredictedItem extends StatelessWidget {
  const _PredictedItem({
    required this.iconBackground,
    required this.iconLabel,
    required this.iconColor,
    required this.title,
  });

  final Color iconBackground;
  final String iconLabel;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            iconLabel,
            style: TextStyle(
              color: iconColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.north_east_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
      ],
    );
  }
}
