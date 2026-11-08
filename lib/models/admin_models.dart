// Typed views of the rows and RPC results the Admin Panel reads. Field names
// follow supabase/schema.sql and supabase/migrations/*_admin_access.sql;
// money stays in kobo until it's formatted.

int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
double? _doubleOrNull(Object? v) =>
    v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
DateTime? _date(Object? v) => v == null ? null : DateTime.tryParse('$v');
String? _str(Object? v) => v == null || '$v'.isEmpty ? null : '$v';

/// Display names for `market_status` values, in the order the admin menus
/// list them.
const Map<String, String> kAdminMarketStatusLabels = <String, String>{
  'draft': 'Draft',
  'active': 'Active',
  'live': 'Live',
  'paused': 'Paused',
  'coming_soon': 'Coming soon',
  'inactive': 'Inactive',
  'closed': 'Closed',
  'resolved': 'Resolved',
  'settled': 'Settled',
  'voided': 'Voided',
};

/// Statuses an admin can set by hand; the rest come from resolving,
/// settling or voiding a market.
const List<String> kAdminSettableStatuses = <String>[
  'active',
  'live',
  'paused',
  'coming_soon',
  'inactive',
  'closed',
];

/// Statuses after which a market's outcome is final.
const Set<String> kAdminFinalStatuses = <String>{'settled', 'voided'};

/// `admin_overview()` — the Admin Panel cards.
class AdminOverview {
  const AdminOverview({
    required this.totalUsers,
    required this.totalMarkets,
    required this.wagerVolumeKobo,
    required this.categoriesCount,
    required this.topicsCount,
    required this.shelvesCount,
    required this.bannersCount,
  });

  factory AdminOverview.fromJson(Map<String, dynamic> j) => AdminOverview(
    totalUsers: _int(j['total_users']),
    totalMarkets: _int(j['total_markets']),
    wagerVolumeKobo: _int(j['wager_volume_kobo']),
    categoriesCount: _int(j['categories_count']),
    topicsCount: _int(j['topics_count']),
    shelvesCount: _int(j['shelves_count']),
    bannersCount: _int(j['banners_count']),
  );

  final int totalUsers;

  /// Every market except drafts.
  final int totalMarkets;
  final int wagerVolumeKobo;

  /// Top-level categories only.
  final int categoriesCount;
  final int topicsCount;
  final int shelvesCount;

  /// Active banners.
  final int bannersCount;
}

/// `admin_user_stats(p_days)` — the Users screen for one filter.
class AdminUserStats {
  const AdminUserStats({
    required this.totalUsers,
    required this.newUsers,
    required this.activeUsers,
    required this.joinedToday,
  });

  factory AdminUserStats.fromJson(Map<String, dynamic> j) => AdminUserStats(
    totalUsers: _int(j['total_users']),
    newUsers: _int(j['new_users']),
    activeUsers: _int(j['active_users']),
    joinedToday: _int(j['joined_today']),
  );

  final int totalUsers;

  /// Sign-ups inside the filter window (all users for "All").
  final int newUsers;
  final int activeUsers;
  final int joinedToday;
}

/// One day of `admin_user_growth()` or `admin_volume_series()`.
class AdminSeriesPoint {
  const AdminSeriesPoint({required this.day, required this.value});

  final DateTime day;
  final int value;
}

/// A row of the `admin_markets` view.
class AdminMarket {
  const AdminMarket({
    required this.id,
    required this.title,
    required this.status,
    required this.isHidden,
    required this.isPublished,
    required this.categoryId,
    required this.categoryName,
    required this.volumeKobo,
    required this.tradersCount,
    required this.outcomes,
    required this.topicIds,
    this.categorySlug,
    this.subcategoryName,
    this.imageUrl,
    this.resolvedOutcomeId,
    this.createdAt,
  });

  factory AdminMarket.fromJson(Map<String, dynamic> j) => AdminMarket(
    id: '${j['id']}',
    title: '${j['title'] ?? ''}',
    status: '${j['status'] ?? 'draft'}',
    isHidden: j['is_hidden'] == true,
    isPublished: j['is_published'] == true,
    categoryId: '${j['category_id']}',
    categoryName: '${j['category_name'] ?? ''}',
    categorySlug: _str(j['category_slug']),
    subcategoryName: _str(j['subcategory_name']),
    imageUrl: _str(j['image_url']),
    volumeKobo: _int(j['volume_kobo']),
    tradersCount: _int(j['traders_count']),
    resolvedOutcomeId: _str(j['resolved_outcome_id']),
    createdAt: _date(j['created_at']),
    outcomes: <AdminOutcome>[
      for (final dynamic o in (j['outcomes'] as List<dynamic>? ?? <dynamic>[]))
        AdminOutcome.fromJson(o as Map<String, dynamic>),
    ],
    topicIds: <String>[
      for (final dynamic t in (j['topic_ids'] as List<dynamic>? ?? <dynamic>[]))
        '$t',
    ],
  );

  final String id;
  final String title;

  /// A `market_status` value.
  final String status;
  final bool isHidden;

  /// True once the market has been opened for trading (prices are set).
  final bool isPublished;
  final String categoryId;
  final String categoryName;
  final String? categorySlug;
  final String? subcategoryName;
  final String? imageUrl;
  final int volumeKobo;
  final int tradersCount;
  final String? resolvedOutcomeId;
  final DateTime? createdAt;
  final List<AdminOutcome> outcomes;
  final List<String> topicIds;

  /// Emoji of the first option, for list thumbnails without an image.
  String get glyph => outcomes
      .map((AdminOutcome o) => o.emoji)
      .firstWhere((String? e) => e != null, orElse: () => '🗳️')!;
}

class AdminOutcome {
  const AdminOutcome({
    required this.id,
    required this.label,
    this.emoji,
    this.price,
    this.isWinner,
  });

  factory AdminOutcome.fromJson(Map<String, dynamic> j) => AdminOutcome(
    id: '${j['id']}',
    label: '${j['label'] ?? ''}',
    emoji: _str(j['emoji']),
    price: _doubleOrNull(j['price']),
    isWinner: j['is_winner'] as bool?,
  );

  final String id;
  final String label;
  final String? emoji;

  /// Probability in [0, 1]; null until the market is published.
  final double? price;
  final bool? isWinner;
}

/// A `categories` row. [parentId] is null for top-level categories.
class AdminCategory {
  const AdminCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    this.parentId,
    this.emoji,
    this.color,
  });

  factory AdminCategory.fromJson(Map<String, dynamic> j) => AdminCategory(
    id: '${j['id']}',
    name: '${j['name'] ?? ''}',
    slug: '${j['slug'] ?? ''}',
    parentId: _str(j['parent_id']),
    emoji: _str(j['emoji']),
    color: _str(j['color']),
    isActive: j['is_active'] != false,
  );

  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final String? emoji;

  /// '#RRGGBB'.
  final String? color;
  final bool isActive;
}

/// A `topics` row.
class AdminTopic {
  const AdminTopic({
    required this.id,
    required this.name,
    this.categoryId,
    this.emoji,
  });

  factory AdminTopic.fromJson(Map<String, dynamic> j) => AdminTopic(
    id: '${j['id']}',
    name: '${j['name'] ?? ''}',
    categoryId: _str(j['category_id']),
    emoji: _str(j['emoji']),
  );

  final String id;
  final String name;
  final String? categoryId;
  final String? emoji;
}

/// A `shelves` row with its items in order.
class AdminShelf {
  const AdminShelf({
    required this.id,
    required this.title,
    required this.heading,
    required this.items,
  });

  factory AdminShelf.fromJson(Map<String, dynamic> j) {
    final List<dynamic> raw = j['shelf_items'] as List<dynamic>? ?? <dynamic>[];
    final List<Map<String, dynamic>> rows = raw.cast<Map<String, dynamic>>()
      ..sort(
        (Map<String, dynamic> a, Map<String, dynamic> b) =>
            _int(a['sort_order']).compareTo(_int(b['sort_order'])),
      );
    return AdminShelf(
      id: '${j['id']}',
      title: '${j['title'] ?? ''}',
      heading: '${j['heading'] ?? ''}',
      items: rows.map(AdminShelfItem.fromJson).toList(),
    );
  }

  final String id;

  /// Admin-facing name.
  final String title;

  /// User-facing heading.
  final String heading;
  final List<AdminShelfItem> items;
}

/// Points at a market or a topic.
class AdminShelfItem {
  const AdminShelfItem({required this.label, this.marketId, this.imageUrl});

  factory AdminShelfItem.fromJson(Map<String, dynamic> j) {
    final Map<String, dynamic>? market = j['markets'] as Map<String, dynamic>?;
    final Map<String, dynamic>? topic = j['topics'] as Map<String, dynamic>?;
    return AdminShelfItem(
      label: '${market?['title'] ?? topic?['name'] ?? ''}',
      marketId: _str(j['market_id']),
      imageUrl: _str(market?['image_url'] ?? topic?['image_url']),
    );
  }

  final String label;
  final String? marketId;
  final String? imageUrl;
}

/// A `banners` row.
class AdminBanner {
  const AdminBanner({
    required this.id,
    required this.surface,
    required this.imageUrl,
    required this.isActive,
    this.title,
  });

  factory AdminBanner.fromJson(Map<String, dynamic> j) => AdminBanner(
    id: '${j['id']}',
    surface: '${j['surface'] ?? 'markets'}',
    imageUrl: '${j['image_url'] ?? ''}',
    title: _str(j['title']),
    isActive: j['is_active'] != false,
  );

  final String id;

  /// An `app_surface` value: arena, markets or search.
  final String surface;
  final String imageUrl;
  final String? title;
  final bool isActive;
}
