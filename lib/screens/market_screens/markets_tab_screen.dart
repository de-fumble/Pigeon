import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/dashboard_markets/markets_list.dart';
import 'package:pigeon/components/dashboard_markets/markets_tab_chip_row.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/live_widgets.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/models/market_tab_category.dart';
import 'package:pigeon/services/live_data_service.dart';

class MarketsTabScreen extends StatelessWidget {
  const MarketsTabScreen({super.key, required this.category});

  final MarketTabCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: staggeredEntrance(<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Pressable(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: category.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Center(
                      child: Image.asset(
                        category.topIconAsset,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: DataSourceBuilder(
                live: (BuildContext context) =>
                    _LiveCategoryMarkets(category: category),
                stock: (BuildContext context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: staggeredEntrance(<Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MarketsTabChipRow(
                        labels: category.primaryChips,
                        iconBuilder: null,
                        iconAssets: category.primaryIconAssets.isNotEmpty
                            ? category.primaryIconAssets
                            : null,
                        usePills: category.title == 'Sports',
                      ),
                    ),
                    if (category.title == 'Sports') ...<Widget>[
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MarketsTabChipRow(
                          labels: category.secondaryChips,
                          usePills: false,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: const <Widget>[
                            Text(
                              'Coming soon',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Live markets in one category, filtered by the subcategory/topic chips the
/// admin has set up for it.
class _LiveCategoryMarkets extends StatefulWidget {
  const _LiveCategoryMarkets({required this.category});

  final MarketTabCategory category;

  @override
  State<_LiveCategoryMarkets> createState() => _LiveCategoryMarketsState();
}

class _LiveCategoryMarketsState extends State<_LiveCategoryMarkets> {
  /// Index 0 is "All"; then subcategories, then topics.
  int _selected = 0;

  late final Future<({List<LiveTopic> subcategories, List<LiveTopic> topics})>
  _filters = LiveDataService.fetchCategoryFilters(widget.category.slug);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({List<LiveTopic> subcategories, List<LiveTopic> topics})
    >(
      future: _filters,
      builder: (BuildContext context, snapshot) {
        final List<LiveTopic> subcategories =
            snapshot.data?.subcategories ?? const <LiveTopic>[];
        final List<LiveTopic> topics =
            snapshot.data?.topics ?? const <LiveTopic>[];
        final List<String> labels = <String>[
          'All',
          ...subcategories.map((LiveTopic t) => t.name),
          ...topics.map((LiveTopic t) => t.name),
        ];
        final int sel = _selected.clamp(0, labels.length - 1);
        final bool isSub = sel > 0 && sel <= subcategories.length;
        final bool isTopic = sel > subcategories.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (labels.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MarketsTabChipRow(
                  key: ValueKey<int>(labels.length),
                  labels: labels,
                  initialIndex: sel,
                  onSelected: (int i) => setState(() => _selected = i),
                ),
              ),
            const SizedBox(height: 18),
            Expanded(
              child: LiveLoader<List<LiveMarket>>(
                refreshKey: sel,
                load: () => LiveDataService.fetchMarkets(
                  categorySlug: widget.category.slug,
                  subcategoryId: isSub ? subcategories[sel - 1].id : null,
                  topicId: isTopic
                      ? topics[sel - 1 - subcategories.length].id
                      : null,
                ),
                placeholder: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: LiveSkeleton(cards: 2),
                ),
                builder: (BuildContext context, List<LiveMarket> markets, _) {
                  if (markets.isEmpty) {
                    return const Align(
                      alignment: Alignment.topCenter,
                      child: LiveEmptyState(
                        icon: Icons.query_stats_rounded,
                        message: 'No markets here yet.',
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 40),
                    children: <Widget>[
                      MarketsList(
                        items: markets.map(liveMarketListItem).toList(),
                        onItemTap: (MarketListItem item) =>
                            openLiveMarket(context, item.marketId!),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
