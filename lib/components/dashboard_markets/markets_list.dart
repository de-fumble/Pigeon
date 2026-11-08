import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketListItem {
  const MarketListItem({
    required this.title,
    required this.subtitle,
    required this.options,
    this.thumbnail,
    this.thumbnailColor = const Color(0xFFD9D9D9),
    this.volume,
    this.status = MarketListStatus.active,
    this.showAction = false,
    this.thumbnailUrl,
    this.marketId,
  });

  final String? thumbnail;

  /// Network image for live markets; takes precedence over [thumbnail].
  final String? thumbnailUrl;

  /// Set for live markets so taps can open the right market.
  final String? marketId;
  final String title;
  final String subtitle;
  final List<MarketListOption> options;
  final Color thumbnailColor;
  final String? volume;
  final MarketListStatus status;
  final bool showAction;
}

enum MarketListStatus { active, comingSoon, closed }

class MarketListOption {
  const MarketListOption({
    required this.label,
    required this.percentage,
    this.percentageColor = const Color(0xFF34343A),
  });

  final String label;
  final String percentage;
  final Color percentageColor;
}

class MarketsList extends StatelessWidget {
  const MarketsList({super.key, required this.items, this.onItemTap});

  final List<MarketListItem> items;
  final ValueChanged<MarketListItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 16),
            _MarketsCard(item: items[i], onTap: onItemTap),
          ],
        ],
      ),
    );
  }
}

class _MarketsCard extends StatelessWidget {
  const _MarketsCard({required this.item, this.onTap});

  final MarketListItem item;
  final ValueChanged<MarketListItem>? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget body = Container(
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
                  color: item.thumbnailColor,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: item.thumbnailUrl != null
                    ? LiveThumb(url: item.thumbnailUrl, fallback: '🗳️')
                    : item.thumbnail != null
                    ? ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          item.thumbnailColor,
                          BlendMode.multiply,
                        ),
                        child: Image.asset(
                          item.thumbnail!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          '🗳️',
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
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
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
          const SizedBox(height: 14),
          for (int j = 0; j < item.options.length; j++) ...<Widget>[
            if (j > 0) const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.options[j].label,
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
                    color: item.options[j].percentageColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.options[j].percentage,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (item.volume != null) ...<Widget>[
            const SizedBox(height: 14),
            _MarketFooter(
              volume: item.volume!,
              status: item.status,
              showAction: item.showAction,
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return body;
    return Pressable(
      onTap: () => onTap!(item),
      behavior: HitTestBehavior.opaque,
      child: body,
    );
  }
}

class _MarketFooter extends StatelessWidget {
  const _MarketFooter({
    required this.volume,
    required this.status,
    this.showAction = false,
  });

  final String volume;
  final MarketListStatus status;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == MarketListStatus.active;
    final bool isComing = status == MarketListStatus.comingSoon;
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
        if (showAction) ...<Widget>[
          const Spacer(),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ],
      ],
    );
  }
}
