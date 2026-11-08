import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_models.dart';
import 'supabase_service.dart';

/// Reads and writes for the Admin Panel. Always talks to the database,
/// whatever the user-dashboard data source is set to. Every call relies on
/// the admin RLS policies and RPCs in supabase/schema.sql and
/// supabase/migrations/*_admin_access.sql, which reject non-admins — so a
/// failure here surfaces as a [PostgrestException] with a readable message.
/// Money is passed and returned in kobo.
///
/// Screens go through [instance], which tests replace with a fake.
class AdminService {
  AdminService();

  static AdminService instance = AdminService();

  SupabaseClient get _client => SupabaseService.client;

  // ─────────────────────────────────────────────────────────────────────────
  // Dashboards
  // ─────────────────────────────────────────────────────────────────────────

  Future<AdminOverview> fetchOverview() async {
    final dynamic result = await _client.rpc('admin_overview');
    return AdminOverview.fromJson(result as Map<String, dynamic>);
  }

  /// [days] = 7 (7D), 30 (1M) or null (All).
  Future<AdminUserStats> fetchUserStats({int? days}) async {
    final dynamic result = await _client.rpc(
      'admin_user_stats',
      params: <String, dynamic>{'p_days': days},
    );
    return AdminUserStats.fromJson(result as Map<String, dynamic>);
  }

  /// Running total of users per day.
  Future<List<AdminSeriesPoint>> fetchUserGrowth({int? days}) async {
    final List<dynamic> rows = await _client.rpc(
      'admin_user_growth',
      params: <String, dynamic>{'p_days': days},
    );
    return _series(rows, 'total_users');
  }

  /// Traded amount per day, in kobo.
  Future<List<AdminSeriesPoint>> fetchVolumeSeries({int? days}) async {
    final List<dynamic> rows = await _client.rpc(
      'admin_volume_series',
      params: <String, dynamic>{'p_days': days},
    );
    return _series(rows, 'volume_kobo');
  }

  static List<AdminSeriesPoint> _series(List<dynamic> rows, String column) =>
      <AdminSeriesPoint>[
        for (final dynamic r in rows)
          AdminSeriesPoint(
            day: DateTime.parse('${r['day']}'),
            value: (r[column] as num?)?.toInt() ?? 0,
          ),
      ];

  // ─────────────────────────────────────────────────────────────────────────
  // Markets
  // ─────────────────────────────────────────────────────────────────────────

  /// Every market, drafts and hidden ones included, newest first.
  Future<List<AdminMarket>> fetchMarkets() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('admin_markets')
        .select()
        .order('created_at', ascending: false);
    return rows.map(AdminMarket.fromJson).toList();
  }

  /// Saves a market with its options, links and topics, then moves it to
  /// [status] ('draft' keeps it unpublished). Publishing needs a seed and at
  /// least two options; the database explains what's missing otherwise.
  Future<void> createMarket({
    required String title,
    required String categoryId,
    String? subcategoryId,
    required List<({String label, String? emoji})> options,
    List<String> topicIds = const <String>[],
    List<String> linkUrls = const <String>[],
    String? period,
    String? resolutionCriteria,
    String? settlementTerms,
    String? wagerTerms,
    required int seedKobo,
    required String status,
  }) async {
    await _client.rpc(
      'admin_create_market',
      params: <String, dynamic>{
        'p_market': <String, dynamic>{
          'title': title,
          'category_id': categoryId,
          'subcategory_id': ?subcategoryId,
          'period': ?period,
          'resolution_criteria': ?resolutionCriteria,
          'settlement_terms': ?settlementTerms,
          'wager_terms': ?wagerTerms,
          'seed_kobo': seedKobo,
        },
        'p_outcomes': <Map<String, dynamic>>[
          for (final ({String label, String? emoji}) o in options)
            <String, dynamic>{'label': o.label, 'emoji': ?o.emoji},
        ],
        'p_links': <Map<String, dynamic>>[
          for (final String url in linkUrls) <String, dynamic>{'url': url},
        ],
        'p_topic_ids': topicIds,
        'p_status': status,
      },
    );
  }

  /// Statuses an admin can set directly; resolved / settled / voided go
  /// through [resolveMarket], [settleMarket] and [voidMarket].
  Future<void> setMarketStatus(String marketId, String status) async {
    await _client
        .from('markets')
        .update(<String, dynamic>{'status': status})
        .eq('id', marketId);
  }

  Future<void> setMarketHidden(String marketId, bool hidden) async {
    await _client
        .from('markets')
        .update(<String, dynamic>{'is_hidden': hidden})
        .eq('id', marketId);
  }

  /// Picks the winner and halts trading. Payouts follow automatically after
  /// the settlement window, or straight away with [settleMarket].
  Future<void> resolveMarket(String marketId, String winningOutcomeId) async {
    await _client.rpc(
      'resolve_market',
      params: <String, dynamic>{
        'p_market_id': marketId,
        'p_winning_outcome_id': winningOutcomeId,
      },
    );
  }

  Future<void> settleMarket(String marketId) async {
    await _client.rpc(
      'settle_market',
      params: <String, dynamic>{'p_market_id': marketId, 'p_force': true},
    );
  }

  /// Cancels the market and refunds every holder.
  Future<void> voidMarket(String marketId, String reason) async {
    await _client.rpc(
      'void_market',
      params: <String, dynamic>{'p_market_id': marketId, 'p_reason': reason},
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Categories
  // ─────────────────────────────────────────────────────────────────────────

  /// Top-level categories and subcategories, in display order.
  Future<List<AdminCategory>> fetchCategories() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('categories')
        .select('id, parent_id, name, slug, emoji, color, is_active')
        .order('sort_order')
        .order('name');
    return rows.map(AdminCategory.fromJson).toList();
  }

  /// The slug is filled in from [name] by the database.
  Future<void> createCategory({
    required String name,
    String? parentId,
    String? emoji,
    String? color,
    int sortOrder = 0,
  }) async {
    await _client.from('categories').insert(<String, dynamic>{
      'name': name,
      'parent_id': ?parentId,
      'emoji': ?emoji,
      'color': ?color,
      'sort_order': sortOrder,
    });
  }

  Future<void> renameCategory(String categoryId, String name) async {
    await _client
        .from('categories')
        .update(<String, dynamic>{'name': name})
        .eq('id', categoryId);
  }

  /// Hidden categories (and their markets' tabs) disappear from the app but
  /// keep their markets.
  Future<void> setCategoryActive(String categoryId, bool active) async {
    await _client
        .from('categories')
        .update(<String, dynamic>{'is_active': active})
        .eq('id', categoryId);
  }

  /// Fails with a readable message while markets still use the category.
  Future<void> deleteCategory(String categoryId) async {
    await _client.from('categories').delete().eq('id', categoryId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Topics & shelves
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<AdminTopic>> fetchTopics() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('topics')
        .select('id, category_id, name, emoji')
        .order('sort_order')
        .order('name');
    return rows.map(AdminTopic.fromJson).toList();
  }

  /// Creates a topic holding [marketIds] in that order.
  Future<void> createTopic({
    required String name,
    String? categoryId,
    List<String> marketIds = const <String>[],
  }) async {
    final Map<String, dynamic> row = await _client
        .from('topics')
        .insert(<String, dynamic>{'name': name, 'category_id': ?categoryId})
        .select('id')
        .single();
    if (marketIds.isNotEmpty) {
      await setTopicMarkets('${row['id']}', marketIds);
    }
  }

  Future<void> setTopicMarkets(String topicId, List<String> marketIds) async {
    await _client.rpc(
      'admin_set_topic_markets',
      params: <String, dynamic>{
        'p_topic_id': topicId,
        'p_market_ids': marketIds,
      },
    );
  }

  /// The topic's market ids in display order.
  Future<List<String>> fetchTopicMarketIds(String topicId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from('topic_markets')
        .select('market_id')
        .eq('topic_id', topicId)
        .order('sort_order');
    return <String>[
      for (final Map<String, dynamic> r in rows) '${r['market_id']}',
    ];
  }

  Future<void> deleteTopic(String topicId) async {
    await _client.from('topics').delete().eq('id', topicId);
  }

  Future<List<AdminShelf>> fetchShelves() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('shelves')
        .select(
          'id, title, heading, shelf_items(sort_order, market_id, '
          'markets(title, image_url), topics(name, image_url))',
        )
        .order('sort_order')
        .order('created_at');
    return rows.map(AdminShelf.fromJson).toList();
  }

  /// Creates a Home shelf on the Arena holding [marketIds] in that order.
  Future<void> createShelf({
    required String title,
    required String heading,
    List<String> marketIds = const <String>[],
  }) async {
    final Map<String, dynamic> row = await _client
        .from('shelves')
        .insert(<String, dynamic>{'title': title, 'heading': heading})
        .select('id')
        .single();
    await _client.rpc(
      'admin_set_shelf_items',
      params: <String, dynamic>{
        'p_shelf_id': row['id'],
        'p_items': <Map<String, dynamic>>[
          for (final String id in marketIds) <String, dynamic>{'market_id': id},
        ],
      },
    );
  }

  Future<void> deleteShelf(String shelfId) async {
    await _client.from('shelves').delete().eq('id', shelfId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Banners
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<AdminBanner>> fetchBanners() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('banners')
        .select('id, surface, title, image_url, is_active')
        .order('sort_order')
        .order('created_at');
    return rows.map(AdminBanner.fromJson).toList();
  }

  Future<void> createBanner({
    required String surface,
    required String imageUrl,
    String? title,
  }) async {
    await _client.from('banners').insert(<String, dynamic>{
      'surface': surface,
      'image_url': imageUrl,
      'title': ?title,
    });
  }

  Future<void> setBannerActive(String bannerId, bool active) async {
    await _client
        .from('banners')
        .update(<String, dynamic>{'is_active': active})
        .eq('id', bannerId);
  }

  Future<void> deleteBanner(String bannerId) async {
    await _client.from('banners').delete().eq('id', bannerId);
  }
}
