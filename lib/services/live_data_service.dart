import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/live_models.dart';
import 'amm.dart';
import 'supabase_service.dart';

/// Reads and writes for the user dashboard when the admin has switched it to
/// live data. Every query here relies on the RLS policies and views in
/// supabase/schema.sql — e.g. drafts never come back, and `my_*` views only
/// return the signed-in user's rows. Money is passed and returned in kobo.
class LiveDataService {
  LiveDataService._();

  static SupabaseClient get _client => SupabaseService.client;

  static String? get currentUserId => SupabaseService.currentUser?.id;

  static String _requireUserId() {
    final String? id = currentUserId;
    if (id == null) {
      throw const AuthException('Log in to continue.');
    }
    return id;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Categories & topics
  // ─────────────────────────────────────────────────────────────────────────

  static Map<String, String>? _categoryIdsBySlug;

  /// slug → id for every category (cached for the session).
  static Future<Map<String, String>> categoryIds() async {
    final Map<String, String>? cached = _categoryIdsBySlug;
    if (cached != null) return cached;
    final List<Map<String, dynamic>> rows = await _client
        .from('categories')
        .select('id, slug');
    return _categoryIdsBySlug = <String, String>{
      for (final Map<String, dynamic> r in rows) '${r['slug']}': '${r['id']}',
    };
  }

  static Future<String?> categoryIdForSlug(String? slug) async =>
      slug == null ? null : (await categoryIds())[slug];

  /// Subcategories (Football, Basketball…) and topics (World Cup, Elections…)
  /// under a top-level category, for the chip row on a category tab.
  static Future<({List<LiveTopic> subcategories, List<LiveTopic> topics})>
  fetchCategoryFilters(String categorySlug) async {
    final String? categoryId = await categoryIdForSlug(categorySlug);
    if (categoryId == null) {
      return (subcategories: <LiveTopic>[], topics: <LiveTopic>[]);
    }
    final List<List<Map<String, dynamic>>> results =
        await Future.wait(<Future<List<Map<String, dynamic>>>>[
          _client
              .from('categories')
              .select('id, name, slug, emoji')
              .eq('parent_id', categoryId)
              .eq('is_active', true)
              .order('sort_order'),
          _client
              .from('topics')
              .select('id, name, slug, emoji')
              .eq('category_id', categoryId)
              .eq('is_active', true)
              .order('sort_order'),
        ]);
    return (
      subcategories: results[0].map(LiveTopic.fromJson).toList(),
      topics: results[1].map(LiveTopic.fromJson).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Markets
  // ─────────────────────────────────────────────────────────────────────────

  /// Market cards from the `market_feed` view, featured first, then by volume.
  static Future<List<LiveMarket>> fetchMarkets({
    String? categorySlug,
    String? subcategoryId,
    String? topicId,
    List<String> statuses = kListedStatuses,
    int limit = 50,
  }) async {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query = _client
        .from('market_feed')
        .select()
        .inFilter('status', statuses);

    final String? categoryId = await categoryIdForSlug(categorySlug);
    if (categorySlug != null && categoryId == null) return <LiveMarket>[];
    if (categoryId != null) query = query.eq('category_id', categoryId);
    if (subcategoryId != null) {
      query = query.eq('subcategory_id', subcategoryId);
    }
    if (topicId != null) {
      final List<Map<String, dynamic>> links = await _client
          .from('topic_markets')
          .select('market_id')
          .eq('topic_id', topicId);
      if (links.isEmpty) return <LiveMarket>[];
      query = query.inFilter(
        'id',
        links.map((Map<String, dynamic> l) => '${l['market_id']}').toList(),
      );
    }

    final List<Map<String, dynamic>> rows = await query
        .order('is_featured', ascending: false)
        .order('volume_kobo', ascending: false)
        .limit(limit);
    return rows.map(LiveMarket.fromJson).toList();
  }

  static Future<List<LiveMarket>> fetchMarketsByIds(List<String> ids) async {
    if (ids.isEmpty) return <LiveMarket>[];
    final List<Map<String, dynamic>> rows = await _client
        .from('market_feed')
        .select()
        .inFilter('id', ids);
    final Map<String, LiveMarket> byId = <String, LiveMarket>{
      for (final Map<String, dynamic> r in rows)
        '${r['id']}': LiveMarket.fromJson(r),
    };
    return <LiveMarket>[for (final String id in ids) ?byId[id]];
  }

  /// Most-traded markets over the last [hours]; falls back to all-time volume
  /// when nothing has traded recently.
  static Future<List<LiveMarket>> fetchTrendingMarkets({
    int hours = 168,
    int limit = 6,
  }) async {
    final List<dynamic> rows =
        await _client.rpc(
              'trending_markets',
              params: <String, dynamic>{'p_hours': hours, 'p_limit': limit},
            )
            as List<dynamic>;
    final List<String> ids = rows
        .map((dynamic r) => '${(r as Map<String, dynamic>)['market_id']}')
        .toList();
    if (ids.isNotEmpty) return fetchMarketsByIds(ids);
    return fetchMarkets(statuses: kTradableStatuses.toList(), limit: limit);
  }

  /// One market with everything the detail screen shows.
  static Future<LiveMarket> fetchMarket(String marketId) async {
    final Map<String, dynamic> row = await _client
        .from('markets')
        .select('''
          id, slug, title, description, market_type, status, is_featured,
          image_url, period, category_id, event_id, volume_kobo, traders_count,
          buys_count, sells_count, opens_at, closes_at, created_at,
          resolution_criteria, settlement_terms, wager_terms,
          category:categories!markets_category_id_fkey(name, color),
          subcategory:categories!markets_subcategory_id_fkey(name),
          event:events(
            status, home_score, away_score, live_period, live_clock,
            home_team:teams!events_home_team_id_fkey(name, short_name, badge_url, color),
            away_team:teams!events_away_team_id_fkey(name, short_name, badge_url, color)
          ),
          market_outcomes!market_outcomes_market_id_fkey(
            id, label, short_label, image_url, emoji, color, price, is_winner, sort_order
          )
        ''')
        .eq('id', marketId)
        .order('sort_order', referencedTable: 'market_outcomes')
        .single();
    return LiveMarket.fromJson(row);
  }

  static Future<List<LiveMarket>> fetchRelatedMarkets(
    LiveMarket market, {
    int limit = 3,
  }) async {
    final List<Map<String, dynamic>> rows = await _client
        .from('market_feed')
        .select()
        .eq('category_id', market.categoryId)
        .neq('id', market.id)
        .inFilter('status', kListedStatuses)
        .order('volume_kobo', ascending: false)
        .limit(limit);
    return rows.map(LiveMarket.fromJson).toList();
  }

  /// Calls [onChange] whenever a market's option prices change (every trade
  /// updates them). Returns the channel so the caller can remove it.
  static RealtimeChannel watchMarketPrices(
    String marketId,
    void Function() onChange,
  ) {
    return _client
        .channel('market-prices:$marketId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'market_outcomes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'market_id',
            value: marketId,
          ),
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  static Future<void> unwatch(RealtimeChannel channel) =>
      _client.removeChannel(channel);

  // ─────────────────────────────────────────────────────────────────────────
  // Trading
  // ─────────────────────────────────────────────────────────────────────────

  static int? _platformFeeBps;

  /// The market-maker state behind [outcomeId]'s market, so trade screens can
  /// preview exact figures on-device while the user types. Null when the
  /// market hasn't been published yet.
  static Future<({AmmMarket market, int index})?> fetchAmmState(
    String outcomeId,
  ) async {
    final Map<String, dynamic> row = await _client
        .from('market_outcomes')
        .select('''
          market:markets!market_outcomes_market_id_fkey(
            liquidity_b, fee_bps,
            market_outcomes!market_outcomes_market_id_fkey(id, shares_outstanding)
          )
        ''')
        .eq('id', outcomeId)
        .single();
    final Map<String, dynamic> market = row['market'] as Map<String, dynamic>;
    if (market['liquidity_b'] == null) return null;

    final List<Map<String, dynamic>> outcomes =
        (market['market_outcomes'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    final int feeBps =
        (market['fee_bps'] as num?)?.toInt() ?? await _tradeFeeBps();
    return (
      market: AmmMarket(
        shares: <double>[
          for (final Map<String, dynamic> o in outcomes)
            double.parse('${o['shares_outstanding']}'),
        ],
        liquidity: double.parse('${market['liquidity_b']}'),
        feeBps: feeBps,
      ),
      index: outcomes.indexWhere(
        (Map<String, dynamic> o) => '${o['id']}' == outcomeId,
      ),
    );
  }

  static Future<int> _tradeFeeBps() async {
    final int? cached = _platformFeeBps;
    if (cached != null) return cached;
    final Map<String, dynamic>? row = await _client
        .from('platform_settings')
        .select('trade_fee_bps')
        .maybeSingle();
    return _platformFeeBps =
        (row?['trade_fee_bps'] as num?)?.toInt() ?? AmmMarket.defaultFeeBps;
  }

  static Future<LiveBuyQuote> quoteBuy(String outcomeId, int amountKobo) async {
    final List<dynamic> rows =
        await _client.rpc(
              'quote_buy',
              params: <String, dynamic>{
                'p_outcome_id': outcomeId,
                'p_amount_kobo': amountKobo,
              },
            )
            as List<dynamic>;
    return LiveBuyQuote.fromJson(rows.first as Map<String, dynamic>);
  }

  static Future<void> buyShares(
    String outcomeId,
    int amountKobo, {
    double minShares = 0,
  }) async {
    _requireUserId();
    await _client.rpc(
      'buy_shares',
      params: <String, dynamic>{
        'p_outcome_id': outcomeId,
        'p_amount_kobo': amountKobo,
        'p_min_shares': minShares,
      },
    );
  }

  static Future<LiveSellQuote> quoteSell(
    String outcomeId,
    double shares,
  ) async {
    final List<dynamic> rows =
        await _client.rpc(
              'quote_sell',
              params: <String, dynamic>{
                'p_outcome_id': outcomeId,
                'p_shares': shares,
              },
            )
            as List<dynamic>;
    return LiveSellQuote.fromJson(rows.first as Map<String, dynamic>);
  }

  static Future<void> sellShares(
    String outcomeId,
    double shares, {
    int minProceedsKobo = 0,
  }) async {
    _requireUserId();
    await _client.rpc(
      'sell_shares',
      params: <String, dynamic>{
        'p_outcome_id': outcomeId,
        'p_shares': shares,
        'p_min_proceeds_kobo': minProceedsKobo,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Wallet
  // ─────────────────────────────────────────────────────────────────────────

  static Future<LiveWallet> fetchWallet() async {
    if (currentUserId == null) return LiveWallet.empty;
    final Map<String, dynamic>? row = await _client
        .from('my_wallet')
        .select()
        .maybeSingle();
    return LiveWallet.fromJson(row);
  }

  static Future<List<LivePosition>> fetchPositions() async {
    if (currentUserId == null) return <LivePosition>[];
    final List<Map<String, dynamic>> rows = await _client
        .from('my_positions')
        .select()
        .order('updated_at', ascending: false);
    return rows.map(LivePosition.fromJson).toList();
  }

  static Future<LivePosition?> fetchPosition(String outcomeId) async {
    if (currentUserId == null) return null;
    final Map<String, dynamic>? row = await _client
        .from('my_positions')
        .select()
        .eq('outcome_id', outcomeId)
        .maybeSingle();
    return row == null ? null : LivePosition.fromJson(row);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Arena (posts)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<List<LivePost>> fetchFeed({
    String? categorySlug,
    String? authorId,
    int limit = 40,
  }) async {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query = _client
        .from('feed_posts')
        .select()
        .isFilter('parent_id', null);
    if (categorySlug != null) {
      final String? categoryId = await categoryIdForSlug(categorySlug);
      if (categoryId == null) return <LivePost>[];
      query = query.eq('category_id', categoryId);
    }
    if (authorId != null) query = query.eq('author_id', authorId);
    final List<Map<String, dynamic>> rows = await query
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(LivePost.fromJson).toList();
  }

  static Future<LivePost?> fetchPost(String postId) async {
    final Map<String, dynamic>? row = await _client
        .from('feed_posts')
        .select()
        .eq('id', postId)
        .maybeSingle();
    return row == null ? null : LivePost.fromJson(row);
  }

  static Future<List<LivePost>> fetchReplies(String postId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from('feed_posts')
        .select()
        .eq('parent_id', postId)
        .order('created_at');
    return rows.map(LivePost.fromJson).toList();
  }

  static Future<void> createPost(
    String body, {
    String? parentId,
    String? marketId,
  }) async {
    await _client.from('posts').insert(<String, dynamic>{
      'author_id': _requireUserId(),
      'body': body.trim(),
      'parent_id': ?parentId,
      'market_id': ?marketId,
    });
  }

  static Future<void> setReaction(
    String postId,
    String reaction, {
    required bool on,
  }) async {
    final String userId = _requireUserId();
    if (on) {
      await _client.from('post_reactions').upsert(<String, dynamic>{
        'post_id': postId,
        'user_id': userId,
        'reaction': reaction,
      }, ignoreDuplicates: true);
    } else {
      await _client
          .from('post_reactions')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .eq('reaction', reaction);
    }
  }

  /// Curated Arena shelves for the home feed ("Fanbase", "Trending", …).
  static Future<List<LiveShelf>> fetchArenaShelves() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('shelves')
        .select('''
          id, heading, layout, sort_order,
          shelf_items(
            sort_order,
            market:markets(id, title, image_url),
            topic:topics(id, name, image_url, emoji)
          )
        ''')
        .eq('surface', 'arena')
        .eq('is_active', true)
        .isFilter('category_id', null)
        .order('sort_order')
        .order('sort_order', referencedTable: 'shelf_items');
    return <LiveShelf>[
      for (final Map<String, dynamic> r in rows)
        LiveShelf(
          id: '${r['id']}',
          heading: '${r['heading']}',
          layout: '${r['layout']}',
          items: <LiveShelfItem>[
            for (final dynamic item
                in (r['shelf_items'] as List<dynamic>? ?? <dynamic>[]))
              if (item['market'] is Map<String, dynamic>)
                LiveShelfItem(
                  title: '${item['market']['title']}',
                  marketId: '${item['market']['id']}',
                  imageUrl: item['market']['image_url'] as String?,
                )
              else if (item['topic'] is Map<String, dynamic>)
                LiveShelfItem(
                  title: '${item['topic']['name']}',
                  topicId: '${item['topic']['id']}',
                  imageUrl: item['topic']['image_url'] as String?,
                  emoji: item['topic']['emoji'] as String?,
                ),
          ],
        ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Notifications
  // ─────────────────────────────────────────────────────────────────────────

  static Future<List<LiveNotification>> fetchNotifications({
    int limit = 100,
  }) async {
    if (currentUserId == null) return <LiveNotification>[];
    final List<Map<String, dynamic>> rows = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(LiveNotification.fromJson).toList();
  }

  /// Marks [ids] (or everything, when null) as read.
  static Future<void> markNotificationsRead([List<String>? ids]) async {
    if (currentUserId == null) return;
    await _client.rpc(
      'mark_notifications_read',
      params: <String, dynamic>{'p_ids': ids},
    );
  }

  static RealtimeChannel? watchNotifications(void Function() onChange) {
    final String? userId = currentUserId;
    if (userId == null) return null;
    return _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Profile
  // ─────────────────────────────────────────────────────────────────────────

  static Future<LiveProfile?> fetchProfile([String? userId]) async {
    final String? id = userId ?? currentUserId;
    if (id == null) return null;
    final Map<String, dynamic>? row = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : LiveProfile.fromJson(row);
  }

  static Future<void> updateProfile({
    required String username,
    String? bio,
  }) async {
    final String trimmedBio = bio?.trim() ?? '';
    await _client
        .from('profiles')
        .update(<String, dynamic>{
          'username': username.trim().toLowerCase(),
          'bio': trimmedBio.isEmpty ? null : trimmedBio,
        })
        .eq('id', _requireUserId());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Search
  // ─────────────────────────────────────────────────────────────────────────

  static Future<List<LiveSearchResult>> search(String query) async {
    if (query.trim().isEmpty) return <LiveSearchResult>[];
    final List<dynamic> rows =
        await _client.rpc(
              'search',
              params: <String, dynamic>{'p_query': query.trim(), 'p_limit': 10},
            )
            as List<dynamic>;
    return rows
        .map(
          (dynamic r) => LiveSearchResult.fromJson(r as Map<String, dynamic>),
        )
        .toList();
  }

  static Future<List<String>> fetchRecentSearches() async {
    if (currentUserId == null) return <String>[];
    final List<Map<String, dynamic>> rows = await _client
        .from('recent_searches')
        .select('query')
        .order('created_at', ascending: false)
        .limit(10);
    return rows.map((Map<String, dynamic> r) => '${r['query']}').toList();
  }

  static Future<void> saveRecentSearch(String query) async {
    final String? userId = currentUserId;
    final String q = query.trim();
    if (userId == null || q.isEmpty) return;
    await _client.from('recent_searches').upsert(<String, dynamic>{
      'user_id': userId,
      'query': q,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,query');
  }
}
