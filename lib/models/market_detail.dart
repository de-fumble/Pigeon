import 'package:flutter/material.dart';

class MarketCandidate {
  const MarketCandidate({
    this.avatar,
    this.avatarAsset,
    required this.name,
    required this.percentageLabel,
    this.percentageColor = const Color(0xFF808085),
    this.avatarColor = const Color(0xFFCB3D59),
    this.amount,
    this.outcomeId,
    this.avatarUrl,
    this.price,
  });

  final String? avatar;
  final String? avatarAsset;

  // Live data only.
  final String? outcomeId;
  final String? avatarUrl;
  final double? price;
  final String name;
  final String percentageLabel;
  final Color percentageColor;
  final Color avatarColor;
  final String? amount;
}

class MarketDetailRow {
  const MarketDetailRow({required this.label});
  final String label;
}

class RelatedMarket {
  const RelatedMarket({
    this.thumbnail,
    this.thumbnailAsset,
    required this.title,
    this.marketId,
    this.thumbnailUrl,
  });
  final String? thumbnail;
  final String? thumbnailAsset;
  final String title;

  // Live data only.
  final String? marketId;
  final String? thumbnailUrl;
}

class MarketDetail {
  const MarketDetail({
    required this.subtitle,
    required this.question,
    required this.candidates,
    required this.details,
    this.moreMarkets = const <RelatedMarket>[],
    this.volume,
    this.showOptionsSection = false,
    this.joinDiscussion = true,
    this.isSports = false,
    this.liveTime,
    this.homeScore,
    this.awayScore,
    this.homeTeamName,
    this.awayTeamName,
    this.homeTeamAsset,
    this.awayTeamAsset,
    this.homeTeamColor = const Color(0xFF6CABDD),
    this.awayTeamColor = const Color(0xFFEB0000),
    this.timeOptions = const <String>['NOW', '1D'],
    this.marketId,
    this.homeTeamBadgeUrl,
    this.awayTeamBadgeUrl,
    this.resolutionText,
    this.settlementText,
    this.wagerText,
    this.openLabel,
    this.closeLabel,
  });

  final String subtitle;
  final String question;
  final List<MarketCandidate> candidates;
  final List<MarketDetailRow> details;
  final List<RelatedMarket> moreMarkets;
  final String? volume;
  final bool showOptionsSection;
  final bool joinDiscussion;
  final bool isSports;
  final String? liveTime;
  final String? homeScore;
  final String? awayScore;
  final String? homeTeamName;
  final String? awayTeamName;
  final String? homeTeamAsset;
  final String? awayTeamAsset;
  final Color homeTeamColor;
  final Color awayTeamColor;
  final List<String> timeOptions;

  // Live data only: set when the detail was built from the database.
  final String? marketId;
  final String? homeTeamBadgeUrl;
  final String? awayTeamBadgeUrl;
  final String? resolutionText;
  final String? settlementText;
  final String? wagerText;
  final String? openLabel;
  final String? closeLabel;
}
