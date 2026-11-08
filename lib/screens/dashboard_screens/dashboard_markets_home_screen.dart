import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/loading_reveal.dart';
import 'package:pigeon/components/shared/motion/skeleton.dart';
import 'package:pigeon/components/dashboard/dashboard_shell.dart';
import 'package:pigeon/components/dashboard_markets/markets_category_row.dart';
import 'package:pigeon/components/dashboard_markets/markets_hero_header.dart';
import 'package:pigeon/components/dashboard_markets/markets_list.dart';
import 'package:pigeon/components/shared/account_buttons.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/live_widgets.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/router/app_router.dart';

class DashboardMarketsHomeScreen extends StatefulWidget {
  const DashboardMarketsHomeScreen({super.key});

  @override
  State<DashboardMarketsHomeScreen> createState() =>
      _DashboardMarketsHomeScreenState();
}

class _DashboardMarketsHomeScreenState
    extends State<DashboardMarketsHomeScreen> {
  // Pinned-appbar transition values: how far the user must scroll
  // before the appbar fully transitions from "on the gradient" to "on dark".
  static const double _transitionRange = 220;
  static const Color _lightFg = Color(0xFF1A1A1A);
  static const Color _darkFg = AppColors.textPrimary;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() => _scrollOffset = _scrollController.offset);
  }

  double get _t => (_scrollOffset / _transitionRange).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: DashboardShell(
          activeIndex: 1,
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  const SliverToBoxAdapter(
                    child: MarketsHeroHeader(onTap: null),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(<Widget>[
                        DataSourceBuilder(
                          live: (BuildContext context) => const _LiveMarkets(),
                          stock: (BuildContext context) => LoadingReveal(
                            cacheKey: 'markets-home',
                            placeholder: const SkeletonPage(
                              header: false,
                              cards: 3,
                              rows: 0,
                              padding: EdgeInsets.symmetric(horizontal: 18),
                            ),
                            builder: (BuildContext context) => Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: staggeredEntrance(<Widget>[
                                const MarketsCategoryRow(),
                                const SizedBox(height: 18),
                                MarketsList(
                                  items: const <MarketListItem>[
                                    MarketListItem(
                                      thumbnail: AppIcons.presidentThumb,
                                      title:
                                          'Who will be the next Nigerian President?',
                                      subtitle: 'Politics – Election',
                                      options: <MarketListOption>[
                                        MarketListOption(
                                          label: 'Bola Ahmed Tinubu',
                                          percentage: '59%',
                                        ),
                                        MarketListOption(
                                          label: 'Peter Obi',
                                          percentage: '41%',
                                        ),
                                        MarketListOption(
                                          label: 'Atiku Abubakar',
                                          percentage: '28%',
                                        ),
                                        MarketListOption(
                                          label: 'El Rufai',
                                          percentage: '13%',
                                        ),
                                      ],
                                      volume: '₦46,357,211',
                                    ),
                                    MarketListItem(
                                      thumbnail: AppIcons.davidoThumb,
                                      title:
                                          'Will Davido drop an Album in 2026?',
                                      subtitle: 'Culture – Music',
                                      options: <MarketListOption>[
                                        MarketListOption(
                                          label: 'Yes',
                                          percentage: '59%',
                                        ),
                                        MarketListOption(
                                          label: 'No',
                                          percentage: '41%',
                                        ),
                                      ],
                                      volume: '₦46,357,211',
                                    ),
                                  ],
                                  onItemTap: (MarketListItem item) {
                                    if (item.subtitle.contains('Politics')) {
                                      Navigator.of(context).pushNamed(
                                        AppRouter.marketPoliticsDetails,
                                      );
                                    } else {
                                      Navigator.of(
                                        context,
                                      ).pushNamed(AppRouter.marketDetails);
                                    }
                                  },
                                ),
                                const SizedBox(height: 18),
                                const _WaitlistNotice(),
                                const SizedBox(height: 18),
                                MarketsList(
                                  items: const <MarketListItem>[
                                    MarketListItem(
                                      thumbnail: AppIcons.elonThumb,
                                      title:
                                          'How many tweets will Elon post in June?',
                                      subtitle: 'Culture',
                                      options: <MarketListOption>[
                                        MarketListOption(
                                          label: 'Under 50',
                                          percentage: '-',
                                        ),
                                        MarketListOption(
                                          label: 'Above 50',
                                          percentage: '-',
                                        ),
                                      ],
                                      volume: 'Coming soon',
                                      status: MarketListStatus.comingSoon,
                                      showAction: true,
                                    ),
                                  ],
                                  onItemTap: (_) => Navigator.of(
                                    context,
                                  ).pushNamed(AppRouter.marketDetails),
                                ),
                                const SizedBox(height: 140),
                              ]),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
              // The pinned appbar — a real SliverPersistentHeaderDelegate that
              // sits at the top of the CustomScrollView and never scrolls away.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _MarketsPinnedAppBar(scrollT: _t),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketsPinnedAppBar extends StatelessWidget {
  const _MarketsPinnedAppBar({required this.scrollT});

  final double scrollT;

  @override
  Widget build(BuildContext context) {
    final Color fg = Color.lerp(
      _DashboardMarketsHomeScreenState._lightFg,
      _DashboardMarketsHomeScreenState._darkFg,
      scrollT,
    )!;
    final Color ringColor = Color.lerp(
      Colors.transparent,
      Colors.white10,
      scrollT,
    )!;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Color.lerp(
                Colors.transparent,
                AppColors.background,
                scrollT,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 18,
            left: 20,
            right: 20,
          ),
          child: SizedBox(
            height: 38,
            child: Row(
              children: <Widget>[
                SideMenuButton(color: fg),
                const SizedBox(width: 10),
                SizedBox(
                  width: 119,
                  child: Text(
                    'Markets',
                    style: TextStyle(
                      color: fg,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ringColor,
                  ),
                  child: const AccountButton(size: 38),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WaitlistNotice extends StatelessWidget {
  const _WaitlistNotice();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.receipt_long_rounded,
            color: AppColors.textMuted,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            '306 people have joined the waitlist.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live markets: everything listed, with "coming soon" markets in their own
/// list below (matching the stock layout).
class _LiveMarkets extends StatelessWidget {
  const _LiveMarkets();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const MarketsCategoryRow(),
        const SizedBox(height: 18),
        LiveLoader<List<LiveMarket>>(
          load: () => LiveDataService.fetchMarkets(),
          placeholder: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: LiveSkeleton(),
          ),
          builder: (BuildContext context, List<LiveMarket> markets, _) {
            final List<LiveMarket> open = markets
                .where((LiveMarket m) => !m.isComingSoon)
                .toList();
            final List<LiveMarket> upcoming = markets
                .where((LiveMarket m) => m.isComingSoon)
                .toList();
            void onTap(MarketListItem item) =>
                openLiveMarket(context, item.marketId!);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: staggeredEntrance(<Widget>[
                if (markets.isEmpty)
                  const LiveEmptyState(
                    icon: Icons.query_stats_rounded,
                    message: 'No markets are open yet. Check back soon.',
                  ),
                if (open.isNotEmpty)
                  MarketsList(
                    items: open.map(liveMarketListItem).toList(),
                    onItemTap: onTap,
                  ),
                if (open.isNotEmpty && upcoming.isNotEmpty)
                  const SizedBox(height: 18),
                if (upcoming.isNotEmpty)
                  MarketsList(
                    items: upcoming.map(liveMarketListItem).toList(),
                    onItemTap: onTap,
                  ),
                const SizedBox(height: 140),
              ]),
            );
          },
        ),
      ],
    );
  }
}
