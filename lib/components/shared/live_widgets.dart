import 'package:flutter/material.dart';
import 'package:pigeon/components/dashboard/arena_post_card.dart';
import 'package:pigeon/components/dashboard_markets/markets_list.dart';
import 'package:pigeon/components/market_cards/card_market_card.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/utils/live_formatters.dart';

// Builds the app's existing widgets from database rows, so live screens look
// exactly like their stock counterparts.

void openLiveMarket(BuildContext context, String marketId) {
  Navigator.of(
    context,
  ).pushNamed(AppRouter.marketDetails, arguments: LiveMarketRef(marketId));
}

String _marketGlyph(LiveMarket m) =>
    m.outcomes.isNotEmpty && m.outcomes.first.emoji != null
    ? m.outcomes.first.emoji!
    : '🗳️';

MarketListItem liveMarketListItem(LiveMarket m) {
  return MarketListItem(
    marketId: m.id,
    thumbnailUrl: m.imageUrl,
    title: m.title,
    subtitle: m.subtitle(),
    options: <MarketListOption>[
      for (final LiveOutcome o in m.outcomes)
        MarketListOption(
          label: o.label,
          percentage: m.isComingSoon ? '-' : LiveFormatters.percent(o.price),
        ),
    ],
    volume: m.isComingSoon ? 'Coming soon' : LiveFormatters.naira(m.volumeKobo),
    status: switch (m.status) {
      'coming_soon' => MarketListStatus.comingSoon,
      'active' || 'live' => MarketListStatus.active,
      _ => MarketListStatus.closed,
    },
    showAction: m.isComingSoon,
  );
}

CardMarketCard liveMarketCard(LiveMarket m) {
  return CardMarketCard(
    thumbnail: _marketGlyph(m),
    thumbnailUrl: m.imageUrl,
    thumbnailColor: const Color(0xFF1F2A1F),
    question: m.title,
    subtitle: m.subtitle(separator: ' · '),
    liveLabel: m.event?.liveLabel,
    showStatus: m.event?.liveLabel == null,
    status: switch (m.status) {
      'coming_soon' => CardMarketStatus.comingSoon,
      'active' || 'live' => CardMarketStatus.active,
      _ => CardMarketStatus.closed,
    },
    options: <CardMarketOption>[
      for (final LiveOutcome o in m.outcomes)
        CardMarketOption(
          label: o.label,
          imageGlyph: o.emoji ?? '',
          imageColor: LiveFormatters.color(o.color),
          imageUrl: o.imageUrl,
          percentage: m.isComingSoon ? null : LiveFormatters.percent(o.price),
        ),
    ],
    volume: LiveFormatters.naira(m.volumeKobo),
  );
}

/// Emoji and bundled artwork for each `reaction_type`.
const Map<String, ({String emoji, String? asset})> kReactionArt =
    <String, ({String emoji, String? asset})>{
      'eyes': (emoji: '👀', asset: AppIcons.cultureEyes),
      'ok_hand': (emoji: '👌', asset: AppIcons.cultureOkHand),
      'clown': (emoji: '🤡', asset: AppIcons.cultureClown),
      'broken_heart': (emoji: '💔', asset: AppIcons.cultureBrokenHeart),
      'smile': (emoji: '😊', asset: null),
      'cap': (emoji: '🧢', asset: null),
    };

List<ArenaReaction> liveReactions(LivePost post) => <ArenaReaction>[
  for (final MapEntry<String, int> r in post.visibleReactions)
    ArenaReaction(
      icon: kReactionArt[r.key]?.emoji ?? '❤️',
      iconAsset: kReactionArt[r.key]?.asset,
      count: LiveFormatters.countCompact(r.value),
    ),
];

Color livePostAvatarColor(LivePost post) => post.authorAvatarColor != null
    ? LiveFormatters.color(post.authorAvatarColor)
    : LiveFormatters.avatarColorFor(post.authorUsername);

ArenaPostCard livePostCard(LivePost post, {Widget? embedded}) {
  return ArenaPostCard(
    avatar: post.authorUsername.isEmpty
        ? '?'
        : post.authorUsername[0].toUpperCase(),
    avatarColor: livePostAvatarColor(post),
    avatarUrl: post.authorAvatarUrl,
    handle: post.handle,
    timeLabel: LiveFormatters.timeAgo(post.createdAt),
    body: post.body,
    replyCount: LiveFormatters.countCompact(post.replyCount),
    quoteCount: LiveFormatters.countCompact(post.reactionCount),
    reactions: liveReactions(post),
    embedded: embedded,
  );
}

/// Shown in place of signed-in-only content (wallet, notifications…) when
/// nobody is logged in.
class LiveSignInPrompt extends StatelessWidget {
  const LiveSignInPrompt({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textMuted,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.login),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.buttonText,
              shape: const StadiumBorder(),
            ),
            child: const Text('Log in'),
          ),
        ],
      ),
    );
  }
}
