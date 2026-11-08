import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/constants/app_colors.dart';

class CardMarketCard extends StatelessWidget {
  const CardMarketCard({
    super.key,
    required this.thumbnail,
    required this.thumbnailColor,
    required this.question,
    required this.subtitle,
    required this.options,
    required this.volume,
    this.status = CardMarketStatus.active,
    this.liveLabel,
    this.showStatus = true,
    this.thumbnailAsset,
    this.thumbnailUrl,
  });

  final String thumbnail;
  final String? thumbnailAsset;
  final String? thumbnailUrl;
  final Color thumbnailColor;
  final String question;
  final String subtitle;
  final List<CardMarketOption> options;
  final String volume;
  final CardMarketStatus status;
  final String? liveLabel;
  final bool showStatus;

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
                decoration: BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: thumbnailUrl != null
                    ? LiveThumb(url: thumbnailUrl, fallback: thumbnail)
                    : thumbnailAsset != null
                    ? Image.asset(
                        thumbnailAsset!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Text(
                          thumbnail,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
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
          if (liveLabel != null) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF1740),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: const TextStyle(
                    color: Color(0xFFFF1740),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  liveLabel!,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          for (int i = 0; i < options.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: <Widget>[
                if (options[i].imageUrl != null) ...<Widget>[
                  LiveThumb(
                    url: options[i].imageUrl,
                    fallback: options[i].imageGlyph,
                    size: 28,
                    backgroundColor: options[i].imageColor,
                  ),
                  const SizedBox(width: 10),
                ] else if (options[i].imageAsset != null) ...<Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: options[i].imageColor,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppSvgIcon(asset: options[i].imageAsset!, size: 28),
                  ),
                  const SizedBox(width: 10),
                ] else if (options[i].imageGlyph.isNotEmpty) ...<Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: options[i].imageColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      options[i].imageGlyph,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
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
                if (options[i].count != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34343A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      options[i].count!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
          _Footer(volume: volume, status: status, showStatus: showStatus),
        ],
      ),
    );
  }
}

enum CardMarketStatus { active, comingSoon, closed }

class CardMarketOption {
  const CardMarketOption({
    required this.label,
    required this.imageGlyph,
    required this.imageColor,
    this.count,
    this.percentage,
    this.imageAsset,
    this.imageUrl,
  });

  final String label;
  final String imageGlyph;
  final Color imageColor;
  final String? count;
  final String? percentage;
  final String? imageAsset;
  final String? imageUrl;
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.volume,
    required this.status,
    required this.showStatus,
  });

  final String volume;
  final CardMarketStatus status;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == CardMarketStatus.active;
    final bool isComing = status == CardMarketStatus.comingSoon;
    final Color color = isActive || isComing
        ? const Color(0xFFEF9520)
        : AppColors.textMuted;

    final Widget volumeText = Text(
      volume,
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
    );

    if (!showStatus) {
      return Row(
        children: [
          Icon(
            isComing ? Icons.schedule_rounded : Icons.receipt_long_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          volumeText,
        ],
      );
    }

    return Row(
      children: [
        Icon(
          isComing ? Icons.schedule_rounded : Icons.receipt_long_rounded,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 6),
        volumeText,
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
