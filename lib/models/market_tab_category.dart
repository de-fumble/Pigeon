import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';

class MarketTabCategory {
  const MarketTabCategory({
    required this.title,
    required this.slug,
    required this.iconEmoji,
    required this.iconColor,
    required this.iconBgColor,
    required this.topIconAsset,
    required this.primaryChips,
    this.primaryIcons = const <String, IconData>{},
    this.primaryIconAssets = const <String, String>{},
    required this.secondaryChips,
  });

  final String title;

  /// `categories.slug` in the database, used when showing live data.
  final String slug;
  final String iconEmoji;
  final Color iconColor;
  final Color iconBgColor;
  final String topIconAsset;
  final List<String> primaryChips;
  final Map<String, IconData> primaryIcons;
  final Map<String, String> primaryIconAssets;
  final List<String> secondaryChips;
}

const MarketTabCategory kMarketTabSports = MarketTabCategory(
  title: 'Sports',
  slug: 'sports',
  iconEmoji: '⚽',
  iconColor: Color(0xFF1A1A1A),
  iconBgColor: Color(0xFF00C34E),
  topIconAsset: AppIcons.tabSports,
  primaryChips: <String>['All', 'Football', 'Basketball', 'Tennis'],
  primaryIconAssets: <String, String>{
    'All': AppIcons.tabBasketball,
    'Football': AppIcons.tabSports,
    'Basketball': AppIcons.tabBasketball,
    'Tennis': AppIcons.tabTennis,
  },
  secondaryChips: <String>[
    'Trending',
    'Premier League',
    'World Cup',
    'NBA Finals',
  ],
);

const MarketTabCategory kMarketTabPolitics = MarketTabCategory(
  title: 'Politics',
  slug: 'politics',
  iconEmoji: '🏛️',
  iconColor: Color(0xFF1A1A1A),
  iconBgColor: Color(0xFFFFD300),
  topIconAsset: AppIcons.tabPolitics,
  primaryChips: <String>['Trending', 'Elections', 'Iran', 'Donald Trump'],
  secondaryChips: <String>['Trending'],
);

const MarketTabCategory kMarketTabCulture = MarketTabCategory(
  title: 'Culture',
  slug: 'culture',
  iconEmoji: '🦩',
  iconColor: Color(0xFF1A1A1A),
  iconBgColor: Color(0xFFFF3C63),
  topIconAsset: AppIcons.tabCulture,
  primaryChips: <String>['Trending', 'Headies', 'Grammy', 'Afrobeats', 'Rap'],
  secondaryChips: <String>['Trending'],
);

const MarketTabCategory kMarketTabTechAndScience = MarketTabCategory(
  title: 'Tech & Science',
  slug: 'tech-science',
  iconEmoji: '❄',
  iconColor: Color(0xFF1A1A1A),
  iconBgColor: Color(0xFF00FFFF),
  topIconAsset: AppIcons.tabTech,
  primaryChips: <String>['Trending', 'A.I', 'Elon Musk', 'ChatGPT'],
  secondaryChips: <String>['Trending'],
);

const MarketTabCategory kMarketTabEconomics = MarketTabCategory(
  title: 'Economics',
  slug: 'economics',
  iconEmoji: '📋',
  iconColor: Color(0xFF1A1A1A),
  iconBgColor: Color(0xFFFA4E00),
  topIconAsset: AppIcons.tabEconomics,
  primaryChips: <String>['Trending', 'World debt', 'Crypto', 'Inflation'],
  secondaryChips: <String>['Trending'],
);
