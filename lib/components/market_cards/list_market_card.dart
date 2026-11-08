import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class ListMarketCard extends StatelessWidget {
  const ListMarketCard({
    super.key,
    required this.thumbnail,
    required this.thumbnailColor,
    required this.question,
    required this.subtitle,
    required this.options,
    required this.volume,
    this.status = ListMarketStatus.active,
  });

  final String thumbnail;
  final Color thumbnailColor;
  final String question;
  final String subtitle;
  final List<MarketOption> options;
  final String volume;
  final ListMarketStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: thumbnailColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(thumbnail, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      question,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < options.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    options[i].label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34343A),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    options[i].percentage ?? '-',
                    style: TextStyle(
                      color: options[i].percentage == null
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _Footer(volume: volume, status: status),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.volume, required this.status});

  final String volume;
  final ListMarketStatus status;

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == ListMarketStatus.active;
    final bool isComing = status == ListMarketStatus.comingSoon;
    final Color color = isActive || isComing
        ? const Color(0xFFEF9520)
        : AppColors.textMuted;

    return Row(
      children: <Widget>[
        Icon(
          isComing ? Icons.schedule_rounded : Icons.receipt_long_rounded,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          volume,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '•',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isComing ? 'Coming soon' : (isActive ? 'Active' : 'Closed'),
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

enum ListMarketStatus { active, comingSoon, closed }

class MarketOption {
  const MarketOption({required this.label, this.percentage});

  final String label;
  final String? percentage;
}
