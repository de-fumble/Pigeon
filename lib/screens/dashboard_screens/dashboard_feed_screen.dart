import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/skeleton.dart';
import 'package:pigeon/components/shared/motion/loading_reveal.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/dashboard/dashboard_shell.dart';
import 'package:pigeon/components/dashboard/arena_category_row.dart';
import 'package:pigeon/components/dashboard/arena_fanbase_card.dart';
import 'package:pigeon/components/dashboard/arena_politics_poll_card.dart';
import 'package:pigeon/components/dashboard/arena_post_card.dart';
import 'package:pigeon/components/dashboard/arena_top_bar.dart';
import 'package:pigeon/components/dashboard/arena_trending_card.dart';
import 'package:pigeon/components/market_cards/card_market_card.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/live_widgets.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_spacing.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/models/market_detail.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/screens/market_screens/market_details_screen.dart'
    show kMarketDetailDefaults;
import 'package:pigeon/screens/dashboard_screens/post_composer_screen.dart'
    show showPostComposerSheet;
import 'package:pigeon/services/data_source_service.dart';
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

class DashboardFeedScreen extends StatefulWidget {
  const DashboardFeedScreen({super.key});

  @override
  State<DashboardFeedScreen> createState() => _DashboardFeedScreenState();
}

class _DashboardFeedScreenState extends State<DashboardFeedScreen> {
  /// Bumped after a live post is published so the feed reloads.
  int _liveFeedVersion = 0;

  Future<void> _compose() async {
    final bool? posted = await showPostComposerSheet(context);
    if (posted == true && mounted && DataSourceService.isLive) {
      setState(() => _liveFeedVersion++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: DashboardShell(
          activeIndex: 0,
          onCompose: _compose,
          child: Stack(
            children: [
              DataSourceBuilder(
                live: (BuildContext context) =>
                    _LiveFeed(version: _liveFeedVersion),
                stock: (BuildContext context) => LoadingReveal(
                  cacheKey: 'feed',
                  placeholder: const SkeletonPage(
                    header: false,
                    cards: 4,
                    rows: 0,
                    padding: EdgeInsets.fromLTRB(20, 140, 20, 126),
                  ),
                  builder: (BuildContext context) => ListView(
                    padding: const EdgeInsets.fromLTRB(20, 86, 20, 126),
                    children: staggeredEntrance([
                      const ArenaCategoryRow(),
                      const SizedBox(height: 22),
                      _FeedPostTile(
                        onTap: AppRouter.postDetail,
                        post: const ArenaPostCard(
                          avatar: '👀',
                          avatarColor: Color(0xFFEFF5FF),
                          avatarImage: AppIcons.pigeonUniverse,
                          iconBgColor: Color(0xFFFF1C2D),
                          handle: '@PigeonUniverse',
                          timeLabel: '6h',
                          body:
                              'Optimism resides where the people believe it resides.',
                          reactions: <ArenaReaction>[
                            ArenaReaction(icon: '👀', count: '54'),
                            ArenaReaction(icon: '👌', count: '93'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      _FeedPostTile(
                        marketDetail: kMarketDetailDefaults['culture'],
                        post: const ArenaPostCard(
                          avatar: '🦩',
                          avatarColor: Color(0xFFFB1740),
                          avatarImage: AppIcons.culture,
                          iconBgColor: Color(0xFFFF3C63),
                          handle: '@Culture',
                          timeLabel: '11h',
                          body: 'The Future is shared',
                          reactions: <ArenaReaction>[
                            ArenaReaction(
                              icon: '👀',
                              iconAsset: AppIcons.cultureEyes,
                              count: '61',
                            ),
                            ArenaReaction(
                              icon: '👌',
                              iconAsset: AppIcons.cultureOkHand,
                              count: '54',
                            ),
                            ArenaReaction(
                              icon: '🤡',
                              iconAsset: AppIcons.cultureClown,
                              count: '33',
                            ),
                            ArenaReaction(
                              icon: '💔',
                              iconAsset: AppIcons.cultureBrokenHeart,
                              count: '18',
                            ),
                          ],
                          embedded: _DavidoMarketCard(),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _FeedPostTile(
                        marketDetail: kMarketDetailDefaults['sports'],
                        post: const ArenaPostCard(
                          avatar: '⚽',
                          avatarColor: Color(0xFF19D36D),
                          avatarImage: AppIcons.sports,
                          iconBgColor: Color(0xFF00C34E),
                          handle: '@Sports',
                          timeLabel: '6h',
                          body: 'Arsenal vs. Man City',
                          reactions: <ArenaReaction>[
                            ArenaReaction(
                              icon: '👀',
                              iconAsset: AppIcons.cultureEyes,
                              count: '61',
                            ),
                            ArenaReaction(
                              icon: '🤡',
                              iconAsset: AppIcons.cultureClown,
                              count: '33',
                            ),
                          ],
                          embedded: _ArsenalMarketCard(),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _FeedPostTile(
                        marketDetail: kMarketDetailDefaults['politics'],
                        post: const ArenaPoliticsPollCard(),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Fanbase',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const ArenaFanbaseCard(
                        title: 'Gather Here',
                        items: <ArenaFanbaseItemData>[
                          ArenaFanbaseItemData(
                            avatar: '🧔',
                            avatarImage: AppIcons.fanbaseBurnaBoy,
                            avatarBgColor: Color(0xFF1F2A1F),
                            title: 'Will Burna Boy outsell\nhis last album?',
                          ),
                          ArenaFanbaseItemData(
                            avatar: '🎸',
                            avatarImage: AppIcons.fanbaseWhowillwin,
                            avatarBgColor: Color(0xFF1F2A1F),
                            title: 'Who will win the\nHeadies next rated?',
                          ),
                          ArenaFanbaseItemData(
                            avatar: '🎤',
                            avatarImage: AppIcons.fanbaseWizkid,
                            avatarBgColor: Color(0xFF1F2A1F),
                            title: 'Will Wizkid win a\nGrammy?',
                          ),
                          ArenaFanbaseItemData(
                            avatar: '🔥',
                            avatarImage: AppIcons.fanbaseTems,
                            avatarBgColor: Color(0xFF1F2A1F),
                            title: 'Tems Album first week\nsales',
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Trending',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const ArenaTrendingCard(),
                      const SizedBox(height: AppSpacing.lg),
                    ]),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                top: 0,
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.only(top: 12, bottom: 18),
                  child: const ArenaTopBar(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedPostTile extends StatelessWidget {
  const _FeedPostTile({required this.post, this.onTap, this.marketDetail})
    : assert(
        (onTap == null) != (marketDetail == null),
        'Provide either onTap or marketDetail, not both',
      );

  final Widget post;
  final String? onTap;
  final MarketDetail? marketDetail;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {
        if (marketDetail != null) {
          Navigator.of(
            context,
          ).pushNamed(AppRouter.marketDetails, arguments: marketDetail);
        } else if (onTap != null) {
          Navigator.of(context).pushNamed(onTap!);
        }
      },
      child: post,
    );
  }
}

class _DavidoMarketCard extends StatelessWidget {
  const _DavidoMarketCard();

  @override
  Widget build(BuildContext context) {
    return const CardMarketCard(
      thumbnail: '🧑🏾',
      thumbnailAsset: 'assets/icons/marketscreen/davido.png',
      thumbnailColor: Color(0xFF1F2A1F),
      question: 'Will Davido drop an Album in 2026?',
      subtitle: 'Culture · Music',
      options: <CardMarketOption>[
        CardMarketOption(
          label: 'Yes',
          imageGlyph: '',
          imageColor: Color(0xFF34343A),
          percentage: '59%',
        ),
        CardMarketOption(
          label: 'No',
          imageGlyph: '',
          imageColor: Color(0xFF34343A),
          percentage: '41%',
        ),
      ],
      volume: '₦46,357,211',
    );
  }
}

class _ArsenalMarketCard extends StatelessWidget {
  const _ArsenalMarketCard();

  @override
  Widget build(BuildContext context) {
    return const CardMarketCard(
      thumbnail: '🏆',
      thumbnailAsset: AppIcons.arsenalVsManCity,
      thumbnailColor: Color(0xFFF5F5F5),
      question: 'Arsenal vs. Man City',
      subtitle: 'Sports · Champions League',
      liveLabel: 'Q1 · 5:19',
      showStatus: false,
      options: <CardMarketOption>[
        CardMarketOption(
          label: 'Arsenal',
          imageGlyph: '',
          imageColor: Color(0xFFFFFFFF),
          imageAsset: AppIcons.arsenal,
          count: '3',
          percentage: '59%',
        ),
        CardMarketOption(
          label: 'No',
          imageGlyph: '',
          imageColor: Color(0xFFFFFFFF),
          imageAsset: AppIcons.manCity,
          count: '1',
          percentage: '41%',
        ),
      ],
      volume: '₦46,357,211',
    );
  }
}

/// Live Arena feed: top-level posts (with any market they embed), then the
/// curated Arena shelves — or trending markets when no shelves exist yet.
class _LiveFeed extends StatefulWidget {
  const _LiveFeed({required this.version});

  final int version;

  @override
  State<_LiveFeed> createState() => _LiveFeedState();
}

class _LiveFeedData {
  const _LiveFeedData({
    required this.posts,
    required this.markets,
    required this.shelves,
    required this.trending,
  });

  final List<LivePost> posts;
  final Map<String, LiveMarket> markets;
  final List<LiveShelf> shelves;
  final List<LiveMarket> trending;
}

class _LiveFeedState extends State<_LiveFeed> {
  String? _categorySlug;

  Future<_LiveFeedData> _load() async {
    final bool home = _categorySlug == null;
    final List<Object> results = await Future.wait(<Future<Object>>[
      LiveDataService.fetchFeed(categorySlug: _categorySlug),
      if (home) LiveDataService.fetchArenaShelves(),
    ]);
    final List<LivePost> posts = results[0] as List<LivePost>;
    final List<LiveShelf> shelves = home
        ? (results[1] as List<LiveShelf>)
              .where((LiveShelf s) => s.items.isNotEmpty)
              .toList()
        : <LiveShelf>[];

    final List<String> marketIds = posts
        .map((LivePost p) => p.marketId)
        .whereType<String>()
        .toSet()
        .toList();
    final List<Object> extra = await Future.wait(<Future<Object>>[
      LiveDataService.fetchMarketsByIds(marketIds),
      if (home && shelves.isEmpty) LiveDataService.fetchTrendingMarkets(),
    ]);
    return _LiveFeedData(
      posts: posts,
      markets: <String, LiveMarket>{
        for (final LiveMarket m in extra[0] as List<LiveMarket>) m.id: m,
      },
      shelves: shelves,
      trending: extra.length > 1
          ? extra[1] as List<LiveMarket>
          : const <LiveMarket>[],
    );
  }

  void _openShelfItem(LiveShelfItem item) {
    if (item.marketId != null) {
      openLiveMarket(context, item.marketId!);
    } else {
      Navigator.of(context).pushNamed(AppRouter.dashboardMarketsHome);
    }
  }

  static const TextStyle _sectionStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 26,
    fontWeight: FontWeight.w700,
  );

  final GlobalKey<LiveLoaderState<_LiveFeedData>> _loader =
      GlobalKey<LiveLoaderState<_LiveFeedData>>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loader.currentState?.reload(),
      edgeOffset: 86,
      color: AppColors.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 86, 20, 126),
        children: <Widget>[
          ArenaCategoryRow(
            initialSlug: _categorySlug,
            onSelected: (String? slug) => setState(() => _categorySlug = slug),
          ),
          const SizedBox(height: 22),
          LiveLoader<_LiveFeedData>(
            key: _loader,
            refreshKey: (widget.version, _categorySlug),
            load: _load,
            placeholder: const LiveSkeleton(cards: 4),
            builder: (BuildContext context, _LiveFeedData data, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: staggeredEntrance(<Widget>[
                if (data.posts.isEmpty)
                  const LiveEmptyState(
                    icon: Icons.forum_outlined,
                    message:
                        'No posts here yet. Be the first to say something.',
                  ),
                for (final LivePost post in data.posts) ...<Widget>[
                  Pressable(
                    onTap: () {
                      if (data.markets.containsKey(post.marketId)) {
                        openLiveMarket(context, post.marketId!);
                      } else {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRouter.postDetail, arguments: post.id);
                      }
                    },
                    child: livePostCard(
                      post,
                      embedded: data.markets[post.marketId] == null
                          ? null
                          : liveMarketCard(data.markets[post.marketId]!),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
                for (final LiveShelf shelf in data.shelves) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(shelf.heading, style: _sectionStyle),
                  const SizedBox(height: 14),
                  ArenaFanbaseCard(
                    title: shelf.heading,
                    items: <ArenaFanbaseItemData>[
                      for (final LiveShelfItem item in shelf.items)
                        ArenaFanbaseItemData(
                          avatar: item.emoji ?? '🔥',
                          avatarUrl: item.imageUrl,
                          avatarBgColor: const Color(0xFF1F2A1F),
                          title: item.title,
                          onTap: () => _openShelfItem(item),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
                if (data.trending.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  const Text('Trending', style: _sectionStyle),
                  const SizedBox(height: 14),
                  ArenaFanbaseCard(
                    title: 'Most traded',
                    items: <ArenaFanbaseItemData>[
                      for (final LiveMarket m in data.trending)
                        ArenaFanbaseItemData(
                          avatar: LiveFormatters.initials(m.title),
                          avatarUrl: m.imageUrl,
                          avatarBgColor: const Color(0xFF1F2A1F),
                          title: m.title,
                          onTap: () => openLiveMarket(context, m.id),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
