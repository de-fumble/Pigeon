import 'package:flutter/material.dart';
import 'package:pigeon/components/dashboard/arena_pill_chip.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/models/market_tab_category.dart';
import 'package:pigeon/router/app_router.dart';

class MarketsCategoryRow extends StatelessWidget {
  const MarketsCategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          _MarketsChip(
            label: 'Sports',
            svgAsset: AppIcons.sports,
            iconColor: const Color(0xFF1A1A1A),
            iconBgColor: const Color(0xFF00C34E),
            onTap: () => _openTab(context, kMarketTabSports),
          ),
          const SizedBox(width: 12),
          _MarketsChip(
            label: 'Politics',
            svgAsset: AppIcons.politics,
            iconColor: const Color(0xFF1A1A1A),
            iconBgColor: const Color(0xFFFFD300),
            onTap: () => _openTab(context, kMarketTabPolitics),
          ),
          const SizedBox(width: 12),
          _MarketsChip(
            label: 'Culture',
            svgAsset: AppIcons.culture,
            iconColor: const Color(0xFF1A1A1A),
            iconBgColor: const Color(0xFFFF3C63),
            onTap: () => _openTab(context, kMarketTabCulture),
          ),
          const SizedBox(width: 12),
          _MarketsChip(
            label: 'Tech & Science',
            svgAsset: AppIcons.tech,
            iconColor: const Color(0xFF1A1A1A),
            iconBgColor: const Color(0xFF00FFFF),
            onTap: () => _openTab(context, kMarketTabTechAndScience),
          ),
          const SizedBox(width: 12),
          _MarketsChip(
            label: 'Economics',
            svgAsset: AppIcons.economicsChip,
            iconColor: const Color(0xFF1A1A1A),
            iconBgColor: const Color(0xFFFA4E00),
            onTap: () => _openTab(context, kMarketTabEconomics),
          ),
        ],
      ),
    );
  }

  void _openTab(BuildContext context, MarketTabCategory category) {
    Navigator.of(context).pushNamed(AppRouter.marketsTab, arguments: category);
  }
}

class _MarketsChip extends StatelessWidget {
  const _MarketsChip({
    required this.label,
    required this.svgAsset,
    required this.iconColor,
    required this.iconBgColor,
    this.onTap,
  });

  final String label;
  final String svgAsset;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = ArenaPillChip(
      label: label,
      svgAsset: svgAsset,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}
