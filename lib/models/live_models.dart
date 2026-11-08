// Typed views of the rows the user dashboard reads from Supabase. Field names
// follow supabase/schema.sql; money stays in kobo until it's formatted.

int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
double? _doubleOrNull(Object? v) =>
    v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
double _double(Object? v) => _doubleOrNull(v) ?? 0;
DateTime? _date(Object? v) => v == null ? null : DateTime.tryParse('$v');
String? _str(Object? v) => v == null || '$v'.isEmpty ? null : '$v';

/// `market_status` values users can trade on.
const Set<String> kTradableStatuses = <String>{'active', 'live'};

/// Statuses shown in user-facing market lists.
const List<String> kListedStatuses = <String>[
  'active',
  'live',
  'coming_soon',
  'paused',
  'closed',
  'resolved',
];

class LiveOutcome {
  const LiveOutcome({
    required this.id,
    required this.label,
    this.shortLabel,
    this.imageUrl,
    this.emoji,
    this.color,
    this.price,
    this.isWinner,
  });

  factory LiveOutcome.fromJson(Map<String, dynamic> j) => LiveOutcome(
    id: '${j['id']}',
    label: '${j['label'] ?? ''}',
    shortLabel: _str(j['short_label']),
    imageUrl: _str(j['image_url']),
    emoji: _str(j['emoji']),
    color: _str(j['color']),
    price: _doubleOrNull(j['price']),
    isWinner: j['is_winner'] as bool?,
  );

  final String id;
  final String label;
  final String? shortLabel;
  final String? imageUrl;
  final String? emoji;
  final String? color;

  /// Probability in [0, 1]; null until the market is published.
  final double? price;
  final bool? isWinner;
}

class LiveTeam {
  const LiveTeam({
    required this.name,
    this.shortName,
    this.badgeUrl,
    this.color,
  });

  static LiveTeam? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    return LiveTeam(
      name: '${raw['name'] ?? ''}',
      shortName: _str(raw['short_name']),
      badgeUrl: _str(raw['badge_url']),
      color: _str(raw['color']),
    );
  }

  final String name;
  final String? shortName;
  final String? badgeUrl;
  final String? color;
}

class LiveEvent {
  const LiveEvent({
    required this.status,
    this.homeTeam,
    this.awayTeam,
    this.homeScore,
    this.awayScore,
    this.livePeriod,
    this.liveClock,
  });

  static LiveEvent? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    return LiveEvent(
      status: '${raw['status'] ?? 'scheduled'}',
      homeTeam: LiveTeam.fromJson(raw['home_team']),
      awayTeam: LiveTeam.fromJson(raw['away_team']),
      homeScore: raw['home_score'] == null ? null : _int(raw['home_score']),
      awayScore: raw['away_score'] == null ? null : _int(raw['away_score']),
      livePeriod: _str(raw['live_period']),
      liveClock: _str(raw['live_clock']),
    );
  }

  final String status;
  final LiveTeam? homeTeam;
  final LiveTeam? awayTeam;
  final int? homeScore;
  final int? awayScore;
  final String? livePeriod;
  final String? liveClock;

  bool get hasTeams => homeTeam != null && awayTeam != null;

  /// "1H 5:17" while the event is live, otherwise null.
  String? get liveLabel {
    if (status != 'live') return null;
    final String label = <String?>[
      livePeriod,
      liveClock,
    ].whereType<String>().join(' ');
    return label.isEmpty ? 'LIVE' : label;
  }
}

/// A row of the `market_feed` view, optionally enriched with columns from
/// `markets` for the detail screen.
class LiveMarket {
  const LiveMarket({
    required this.id,
    required this.title,
    required this.marketType,
    required this.status,
    required this.categoryId,
    required this.categoryName,
    required this.outcomes,
    this.slug,
    this.isFeatured = false,
    this.imageUrl,
    this.period,
    this.categoryColor,
    this.subcategoryName,
    this.eventId,
    this.volumeKobo = 0,
    this.tradersCount = 0,
    this.opensAt,
    this.closesAt,
    this.createdAt,
    this.description,
    this.resolutionCriteria,
    this.settlementTerms,
    this.wagerTerms,
    this.buysCount,
    this.sellsCount,
    this.event,
  });

  factory LiveMarket.fromJson(Map<String, dynamic> j) {
    final Object? rawOutcomes = j['outcomes'] ?? j['market_outcomes'];
    final List<LiveOutcome> outcomes = rawOutcomes is List
        ? rawOutcomes
              .whereType<Map<String, dynamic>>()
              .map(LiveOutcome.fromJson)
              .toList()
        : <LiveOutcome>[];
    final Object? category = j['category'];
    final Object? subcategory = j['subcategory'];
    return LiveMarket(
      id: '${j['id']}',
      slug: _str(j['slug']),
      title: '${j['title'] ?? ''}',
      marketType: '${j['market_type'] ?? 'multiple_choice'}',
      status: '${j['status'] ?? 'active'}',
      isFeatured: j['is_featured'] == true,
      imageUrl: _str(j['image_url']),
      period: _str(j['period']),
      categoryId: '${j['category_id'] ?? ''}',
      categoryName:
          _str(j['category_name']) ??
          (category is Map ? '${category['name']}' : ''),
      categoryColor:
          _str(j['category_color']) ??
          (category is Map ? _str(category['color']) : null),
      subcategoryName:
          _str(j['subcategory_name']) ??
          (subcategory is Map ? _str(subcategory['name']) : null),
      eventId: _str(j['event_id']),
      volumeKobo: _int(j['volume_kobo']),
      tradersCount: _int(j['traders_count']),
      opensAt: _date(j['opens_at']),
      closesAt: _date(j['closes_at']),
      createdAt: _date(j['created_at']),
      description: _str(j['description']),
      resolutionCriteria: _str(j['resolution_criteria']),
      settlementTerms: _str(j['settlement_terms']),
      wagerTerms: _str(j['wager_terms']),
      buysCount: j['buys_count'] == null ? null : _int(j['buys_count']),
      sellsCount: j['sells_count'] == null ? null : _int(j['sells_count']),
      event: LiveEvent.fromJson(j['event']),
      outcomes: outcomes,
    );
  }

  final String id;
  final String? slug;
  final String title;
  final String marketType;
  final String status;
  final bool isFeatured;
  final String? imageUrl;
  final String? period;
  final String categoryId;
  final String categoryName;
  final String? categoryColor;
  final String? subcategoryName;
  final String? eventId;
  final int volumeKobo;
  final int tradersCount;
  final DateTime? opensAt;
  final DateTime? closesAt;
  final DateTime? createdAt;
  final List<LiveOutcome> outcomes;

  // Detail-only fields (null when loaded from market_feed).
  final String? description;
  final String? resolutionCriteria;
  final String? settlementTerms;
  final String? wagerTerms;
  final int? buysCount;
  final int? sellsCount;
  final LiveEvent? event;

  bool get isTradable => kTradableStatuses.contains(status);
  bool get isComingSoon => status == 'coming_soon';
  bool get isBinary => marketType == 'binary';

  /// "Politics – Election" style subtitle.
  String subtitle({String separator = ' – '}) => <String?>[
    categoryName,
    subcategoryName,
  ].whereType<String>().where((String s) => s.isNotEmpty).join(separator);
}

/// Arena reaction types (`reaction_type` enum) in display order.
const List<String> kReactionTypes = <String>[
  'eyes',
  'ok_hand',
  'clown',
  'broken_heart',
  'smile',
  'cap',
];

/// A row of the `feed_posts` view.
class LivePost {
  const LivePost({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.body,
    required this.createdAt,
    this.authorAvatarUrl,
    this.authorAvatarColor,
    this.authorIsOfficial = false,
    this.authorIsVerified = false,
    this.parentId,
    this.marketId,
    this.categoryId,
    this.replyCount = 0,
    this.reactionCount = 0,
    this.reactionCounts = const <String, int>{},
    this.myReactions = const <String>[],
  });

  factory LivePost.fromJson(Map<String, dynamic> j) {
    final Object? counts = j['reaction_counts'];
    final Object? mine = j['my_reactions'];
    return LivePost(
      id: '${j['id']}',
      authorId: '${j['author_id']}',
      authorUsername: '${j['author_username'] ?? ''}',
      authorAvatarUrl: _str(j['author_avatar_url']),
      authorAvatarColor: _str(j['author_avatar_color']),
      authorIsOfficial: j['author_is_official'] == true,
      authorIsVerified: j['author_is_verified'] == true,
      body: '${j['body'] ?? ''}',
      parentId: _str(j['parent_id']),
      marketId: _str(j['market_id']),
      categoryId: _str(j['category_id']),
      replyCount: _int(j['reply_count']),
      reactionCount: _int(j['reaction_count']),
      reactionCounts: counts is Map
          ? counts.map((Object? k, Object? v) => MapEntry('$k', _int(v)))
          : const <String, int>{},
      myReactions: mine is List
          ? mine.map((Object? e) => '$e').toList()
          : const <String>[],
      createdAt: _date(j['created_at']) ?? DateTime.now(),
    );
  }

  final String id;
  final String authorId;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String? authorAvatarColor;
  final bool authorIsOfficial;
  final bool authorIsVerified;
  final String body;
  final String? parentId;
  final String? marketId;
  final String? categoryId;
  final int replyCount;
  final int reactionCount;
  final Map<String, int> reactionCounts;
  final List<String> myReactions;
  final DateTime createdAt;

  String get handle => '@$authorUsername';

  /// Non-zero reactions in [kReactionTypes] order.
  List<MapEntry<String, int>> get visibleReactions => <MapEntry<String, int>>[
    for (final String type in kReactionTypes)
      if ((reactionCounts[type] ?? 0) > 0)
        MapEntry(type, reactionCounts[type]!),
  ];
}

class LiveNotification {
  const LiveNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt,
    this.body,
    this.marketId,
    this.tradeId,
    this.data = const <String, dynamic>{},
    this.readAt,
  });

  factory LiveNotification.fromJson(Map<String, dynamic> j) => LiveNotification(
    id: '${j['id']}',
    type: '${j['type']}',
    title: '${j['title'] ?? ''}',
    body: _str(j['body']),
    marketId: _str(j['market_id']),
    tradeId: _str(j['trade_id']),
    data: j['data'] is Map<String, dynamic>
        ? j['data'] as Map<String, dynamic>
        : const <String, dynamic>{},
    readAt: _date(j['read_at']),
    createdAt: _date(j['created_at']) ?? DateTime.now(),
  );

  final String id;
  final String type;
  final String title;
  final String? body;
  final String? marketId;
  final String? tradeId;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get unread => readAt == null;
}

/// A row of the `my_positions` view.
class LivePosition {
  const LivePosition({
    required this.marketId,
    required this.outcomeId,
    required this.marketTitle,
    required this.marketStatus,
    required this.outcomeLabel,
    required this.shares,
    required this.costBasisKobo,
    required this.valueKobo,
    required this.changeKobo,
    required this.payoutIfRightKobo,
    this.realizedPnlKobo = 0,
    this.marketImageUrl,
    this.outcomeImageUrl,
    this.outcomeEmoji,
    this.outcomeColor,
    this.chance,
    this.payoutKobo,
    this.settledAt,
  });

  factory LivePosition.fromJson(Map<String, dynamic> j) => LivePosition(
    marketId: '${j['market_id']}',
    outcomeId: '${j['outcome_id']}',
    marketTitle: '${j['market_title'] ?? ''}',
    marketStatus: '${j['market_status'] ?? ''}',
    marketImageUrl: _str(j['market_image_url']),
    outcomeLabel: '${j['outcome_label'] ?? ''}',
    outcomeImageUrl: _str(j['outcome_image_url']),
    outcomeEmoji: _str(j['outcome_emoji']),
    outcomeColor: _str(j['outcome_color']),
    shares: _double(j['shares']),
    chance: _doubleOrNull(j['chance']),
    costBasisKobo: _int(j['cost_basis_kobo']),
    valueKobo: _int(j['value_kobo']),
    changeKobo: _int(j['change_kobo']),
    payoutIfRightKobo: _int(j['payout_if_right_kobo']),
    realizedPnlKobo: _int(j['realized_pnl_kobo']),
    payoutKobo: j['payout_kobo'] == null ? null : _int(j['payout_kobo']),
    settledAt: _date(j['settled_at']),
  );

  final String marketId;
  final String outcomeId;
  final String marketTitle;
  final String marketStatus;
  final String? marketImageUrl;
  final String outcomeLabel;
  final String? outcomeImageUrl;
  final String? outcomeEmoji;
  final String? outcomeColor;
  final double shares;
  final double? chance;
  final int costBasisKobo;
  final int valueKobo;
  final int changeKobo;
  final int payoutIfRightKobo;
  final int realizedPnlKobo;
  final int? payoutKobo;
  final DateTime? settledAt;

  bool get isOpen => settledAt == null && shares > 0;
}

class LiveWallet {
  const LiveWallet({required this.cashBalanceKobo, required this.holdingsKobo});

  factory LiveWallet.fromJson(Map<String, dynamic>? j) => LiveWallet(
    cashBalanceKobo: _int(j?['cash_balance_kobo']),
    holdingsKobo: _int(j?['holdings_kobo']),
  );

  static const LiveWallet empty = LiveWallet(
    cashBalanceKobo: 0,
    holdingsKobo: 0,
  );

  final int cashBalanceKobo;
  final int holdingsKobo;
}

class LiveProfile {
  const LiveProfile({
    required this.id,
    required this.username,
    required this.createdAt,
    this.bio,
    this.avatarUrl,
    this.avatarColor,
    this.isOfficial = false,
    this.isVerified = false,
    this.postsCount = 0,
    this.tradesCount = 0,
    this.tradeVolumeKobo = 0,
  });

  factory LiveProfile.fromJson(Map<String, dynamic> j) => LiveProfile(
    id: '${j['id']}',
    username: '${j['username'] ?? ''}',
    bio: _str(j['bio']),
    avatarUrl: _str(j['avatar_url']),
    avatarColor: _str(j['avatar_color']),
    isOfficial: j['is_official'] == true,
    isVerified: j['is_verified'] == true,
    postsCount: _int(j['posts_count']),
    tradesCount: _int(j['trades_count']),
    tradeVolumeKobo: _int(j['trade_volume_kobo']),
    createdAt: _date(j['created_at']) ?? DateTime.now(),
  );

  final String id;
  final String username;
  final String? bio;
  final String? avatarUrl;
  final String? avatarColor;
  final bool isOfficial;
  final bool isVerified;
  final int postsCount;
  final int tradesCount;
  final int tradeVolumeKobo;
  final DateTime createdAt;

  String get handle => '@$username';
}

/// A row from the `search` RPC.
class LiveSearchResult {
  const LiveSearchResult({
    required this.kind,
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
  });

  factory LiveSearchResult.fromJson(Map<String, dynamic> j) => LiveSearchResult(
    kind: '${j['kind']}',
    id: '${j['id']}',
    title: '${j['title'] ?? ''}',
    subtitle: _str(j['subtitle']),
    imageUrl: _str(j['image_url']),
  );

  /// 'market' | 'user' | 'topic' | 'event'.
  final String kind;
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
}

/// A curated shelf (`shelves` + `shelf_items`) — "Fanbase", "Trending", …
class LiveShelf {
  const LiveShelf({
    required this.id,
    required this.heading,
    required this.layout,
    required this.items,
  });

  final String id;
  final String heading;
  final String layout;
  final List<LiveShelfItem> items;
}

class LiveShelfItem {
  const LiveShelfItem({
    required this.title,
    this.marketId,
    this.topicId,
    this.imageUrl,
    this.emoji,
  });

  final String title;
  final String? marketId;
  final String? topicId;
  final String? imageUrl;
  final String? emoji;
}

class LiveTopic {
  const LiveTopic({
    required this.id,
    required this.name,
    required this.slug,
    this.emoji,
  });

  factory LiveTopic.fromJson(Map<String, dynamic> j) => LiveTopic(
    id: '${j['id']}',
    name: '${j['name'] ?? ''}',
    slug: '${j['slug'] ?? ''}',
    emoji: _str(j['emoji']),
  );

  final String id;
  final String name;
  final String slug;
  final String? emoji;
}

class LiveBuyQuote {
  const LiveBuyQuote({
    required this.shares,
    required this.feeKobo,
    required this.totalKobo,
    required this.payoutIfRightKobo,
    this.priceAfter,
  });

  factory LiveBuyQuote.fromJson(Map<String, dynamic> j) => LiveBuyQuote(
    shares: _double(j['shares']),
    feeKobo: _int(j['fee_kobo']),
    totalKobo: _int(j['total_kobo']),
    payoutIfRightKobo: _int(j['payout_if_right_kobo']),
    priceAfter: _doubleOrNull(j['price_after']),
  );

  final double shares;
  final int feeKobo;
  final int totalKobo;
  final int payoutIfRightKobo;
  final double? priceAfter;
}

class LiveSellQuote {
  const LiveSellQuote({
    required this.proceedsKobo,
    required this.feeKobo,
    required this.netKobo,
  });

  factory LiveSellQuote.fromJson(Map<String, dynamic> j) => LiveSellQuote(
    proceedsKobo: _int(j['proceeds_kobo']),
    feeKobo: _int(j['fee_kobo']),
    netKobo: _int(j['net_kobo']),
  );

  final int proceedsKobo;
  final int feeKobo;
  final int netKobo;
}

/// Route argument that opens a market from the database (as opposed to a
/// stock [MarketDetail]).
class LiveMarketRef {
  const LiveMarketRef(this.id);

  final String id;
}
