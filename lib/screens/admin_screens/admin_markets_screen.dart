import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_columns.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/skeleton.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/admin/admin_create_button.dart';
import 'package:pigeon/components/admin/admin_market_actions_sheet.dart';
import 'package:pigeon/components/admin/admin_market_filter_menu.dart';
import 'package:pigeon/components/admin/admin_market_list_tile.dart';
import 'package:pigeon/components/admin/admin_page_header.dart';
import 'package:pigeon/components/admin/admin_users_total_card.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/admin_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

typedef _MarketsData = ({
  List<AdminMarket> markets,
  List<AdminCategory> categories,
});

class AdminMarketsScreen extends StatefulWidget {
  const AdminMarketsScreen({super.key});

  @override
  State<AdminMarketsScreen> createState() => _AdminMarketsScreenState();
}

class _AdminMarketsScreenState extends State<AdminMarketsScreen> {
  /// Filters after the category names; each maps to a test on a market.
  static final Map<String, bool Function(AdminMarket)> _statusFilters =
      <String, bool Function(AdminMarket)>{
        'Drafts': (AdminMarket m) => m.status == 'draft',
        'Active': (AdminMarket m) => m.status == 'active',
        'Live': (AdminMarket m) => m.status == 'live',
        'Paused': (AdminMarket m) => m.status == 'paused',
        'Coming soon': (AdminMarket m) => m.status == 'coming_soon',
        'Inactive': (AdminMarket m) => m.status == 'inactive',
        'Closed': (AdminMarket m) => m.status == 'closed',
        'Resolved': (AdminMarket m) =>
            m.status == 'resolved' || m.status == 'settled',
        'Voided': (AdminMarket m) => m.status == 'voided',
        'Hidden': (AdminMarket m) => m.isHidden,
      };

  final GlobalKey<LiveLoaderState<_MarketsData>> _loaderKey =
      GlobalKey<LiveLoaderState<_MarketsData>>();

  String _selectedFilter = 'All';

  Future<_MarketsData> _load() async {
    final (List<AdminMarket> markets, List<AdminCategory> categories) = await (
      AdminService.instance.fetchMarkets(),
      AdminService.instance.fetchCategories(),
    ).wait;
    return (
      markets: markets,
      categories: categories
          .where((AdminCategory c) => c.parentId == null)
          .toList(),
    );
  }

  Future<void> _reload() async => _loaderKey.currentState?.reload();

  void _openFilterMenu(BuildContext anchorContext, _MarketsData data) {
    AdminMarketFilterMenu.show(
      anchorContext,
      items: <String>[
        'All',
        for (final AdminCategory c in data.categories) c.name,
        ..._statusFilters.keys,
      ],
      selectedItem: _selectedFilter,
      onSelected: (String filter) {
        setState(() => _selectedFilter = filter);
      },
    );
  }

  Future<void> _openCreateFlow() async {
    await Navigator.of(context).pushNamed(AppRouter.adminMarketCategorySelect);
    if (mounted) await _reload();
  }

  Future<void> _openActions(AdminMarket market) async {
    final bool changed = await showAdminMarketActions(context, market);
    if (changed && mounted) await _reload();
  }

  List<AdminMarket> _filtered(List<AdminMarket> markets) {
    final bool Function(AdminMarket)? statusTest =
        _statusFilters[_selectedFilter];
    if (statusTest != null) return markets.where(statusTest).toList();
    if (_selectedFilter == 'All') return markets;
    return markets
        .where((AdminMarket m) => m.categoryName == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AdminPageHeader(
              title: 'Markets',
              trailing: AdminCreateButton(onPressed: _openCreateFlow),
            ),
            Expanded(
              child: LiveLoader<_MarketsData>(
                key: _loaderKey,
                load: _load,
                placeholder: const SkeletonPage(
                  header: false,
                  cards: 1,
                  rows: 6,
                  padding: EdgeInsets.fromLTRB(20, 25, 22, 28),
                ),
                builder:
                    (
                      BuildContext context,
                      _MarketsData data,
                      Future<void> Function() reload,
                    ) => RefreshIndicator(
                      color: AppColors.accent,
                      onRefresh: reload,
                      child: _buildList(data),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(_MarketsData data) {
    final List<AdminMarket> listed = data.markets
        .where((AdminMarket m) => m.status != 'draft')
        .toList();
    final List<AdminMarket> top =
        listed.where((AdminMarket m) => m.volumeKobo > 0).toList()..sort(
          (AdminMarket a, AdminMarket b) =>
              b.volumeKobo.compareTo(a.volumeKobo),
        );
    final List<AdminMarket> filtered = _filtered(data.markets);

    // Group by category, keeping the categories' display order.
    final Map<String, List<AdminMarket>> sections = <String, List<AdminMarket>>{
      for (final AdminCategory c in data.categories) c.name: <AdminMarket>[],
    };
    for (final AdminMarket m in filtered) {
      (sections[m.categoryName] ??= <AdminMarket>[]).add(m);
    }
    sections.removeWhere((_, List<AdminMarket> list) => list.isEmpty);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 25, 22, 28),
      children: staggeredEntrance(<Widget>[
        AdminUsersTotalCard(
          label: 'Total Markets',
          totalUsers: LiveFormatters.groupDigits(listed.length),
        ),
        const SizedBox(height: 50),
        const Text('Top Markets', style: _sectionStyle),
        const SizedBox(height: 20),
        if (top.isEmpty)
          const Text(
            'No trades yet.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          )
        else
          for (int i = 0; i < top.length && i < 3; i++)
            AdminMarketRow(
              market: top[i],
              showDivider: i < top.length - 1 && i < 2,
              onTap: () => _openActions(top[i]),
            ),
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: Text(_selectedFilter, style: _sectionStyle)),
            Builder(
              builder: (BuildContext buttonContext) {
                return Pressable(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openFilterMenu(buttonContext, data),
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        if (sections.isEmpty)
          LiveEmptyState(
            message: data.markets.isEmpty
                ? 'No markets yet. Tap Create to add one.'
                : 'No markets match this filter.',
            icon: Icons.storefront_outlined,
          ),
        for (final MapEntry<String, List<AdminMarket>> section
            in sections.entries) ...<Widget>[
          SizedBox(height: section.key == sections.keys.first ? 4 : 10),
          _SectionLabel(label: section.key.toUpperCase()),
          const SizedBox(height: 10),
          if (AdminColumns.isWide(context))
            AdminColumns(
              itemCount: section.value.length,
              itemBuilder: (BuildContext context, int i, bool last) =>
                  AdminMarketRow(
                    market: section.value[i],
                    showDivider: !last,
                    onTap: () => _openActions(section.value[i]),
                  ),
            )
          else
            for (int i = 0; i < section.value.length; i++)
              AdminMarketRow(
                market: section.value[i],
                showDivider: i < section.value.length - 1,
                onTap: () => _openActions(section.value[i]),
              ),
        ],
      ]),
    );
  }

  static const TextStyle _sectionStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
    );
  }
}
