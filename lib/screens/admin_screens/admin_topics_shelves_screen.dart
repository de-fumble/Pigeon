import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_columns.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/skeleton.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/admin/admin_create_button.dart';
import 'package:pigeon/components/shared/app_dialogs.dart';
import 'package:pigeon/components/admin/admin_dropdown_label.dart';
import 'package:pigeon/components/admin/admin_market_filter_menu.dart';
import 'package:pigeon/components/admin/admin_page_header.dart';
import 'package:pigeon/components/admin/admin_section_heading.dart';
import 'package:pigeon/components/admin/admin_shelf_block.dart';
import 'package:pigeon/components/admin/admin_tab_switcher.dart';
import 'package:pigeon/components/admin/admin_topic_list_row.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/admin_service.dart';

enum _TopicShelfTab { topics, shelves }

typedef _TopicsShelvesData = ({
  List<AdminTopic> topics,
  List<AdminCategory> categories,
  List<AdminShelf> shelves,
});

class AdminTopicsShelvesScreen extends StatefulWidget {
  const AdminTopicsShelvesScreen({super.key});

  @override
  State<AdminTopicsShelvesScreen> createState() =>
      _AdminTopicsShelvesScreenState();
}

class _AdminTopicsShelvesScreenState extends State<AdminTopicsShelvesScreen> {
  final GlobalKey<LiveLoaderState<_TopicsShelvesData>> _loaderKey =
      GlobalKey<LiveLoaderState<_TopicsShelvesData>>();

  _TopicShelfTab _tab = _TopicShelfTab.topics;
  String _topicFilter = 'All';

  Future<_TopicsShelvesData> _load() async {
    final (
      List<AdminTopic> topics,
      List<AdminCategory> categories,
      List<AdminShelf> shelves,
    ) = await (
      AdminService.instance.fetchTopics(),
      AdminService.instance.fetchCategories(),
      AdminService.instance.fetchShelves(),
    ).wait;
    return (
      topics: topics,
      categories: categories
          .where((AdminCategory c) => c.parentId == null)
          .toList(),
      shelves: shelves,
    );
  }

  Future<void> _reload() async => _loaderKey.currentState?.reload();

  void _openTopicMenu(BuildContext anchorContext, _TopicsShelvesData data) {
    AdminMarketFilterMenu.show(
      anchorContext,
      items: <String>[
        'All',
        for (final AdminCategory c in data.categories) c.name,
      ],
      selectedItem: _topicFilter,
      alignStart: true,
      width: 190,
      onSelected: (String value) => setState(() => _topicFilter = value),
    );
  }

  Future<void> _push(String route, {Object? arguments}) async {
    await Navigator.of(context).pushNamed(route, arguments: arguments);
    if (mounted) await _reload();
  }

  void _openCreate() {
    _push(
      _tab == _TopicShelfTab.topics
          ? AppRouter.adminCreateTopic
          : AppRouter.adminCreateShelf,
    );
  }

  Future<void> _deleteShelf(AdminShelf shelf) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${shelf.title}?',
      message: 'The shelf disappears from the app. Its markets are kept.',
    );
    if (!confirmed || !mounted) return;
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.deleteShelf(shelf.id),
      success: '${shelf.title} deleted.',
    );
    if (ok) await _reload();
  }

  List<AdminTopic> _filteredTopics(_TopicsShelvesData data) {
    if (_topicFilter == 'All') return data.topics;
    final String? categoryId = data.categories
        .where((AdminCategory c) => c.name == _topicFilter)
        .firstOrNull
        ?.id;
    return data.topics
        .where((AdminTopic t) => t.categoryId == categoryId)
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
          children: [
            AdminPageHeader(
              title: 'Topics & Shelves',
              trailing: AdminCreateButton(onPressed: _openCreate),
            ),
            Expanded(
              child: LiveLoader<_TopicsShelvesData>(
                key: _loaderKey,
                load: _load,
                placeholder: const SkeletonPage(
                  rows: 7,
                  padding: EdgeInsets.fromLTRB(20, 25, 20, 28),
                ),
                builder:
                    (
                      BuildContext context,
                      _TopicsShelvesData data,
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

  Widget _buildList(_TopicsShelvesData data) {
    final List<AdminTopic> topics = _filteredTopics(data);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 28),
      children: staggeredEntrance([
        AdminTabSwitcher(
          leftLabel: 'Topics',
          rightLabel: 'Shelves',
          leftSelected: _tab == _TopicShelfTab.topics,
          onLeftTap: () => setState(() => _tab = _TopicShelfTab.topics),
          onRightTap: () => setState(() => _tab = _TopicShelfTab.shelves),
        ),
        if (_tab == _TopicShelfTab.topics) ...[
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (BuildContext anchorContext) {
                return AdminDropdownLabel(
                  label: _topicFilter,
                  onTap: () => _openTopicMenu(anchorContext, data),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          if (topics.isEmpty)
            const LiveEmptyState(
              message: 'No topics here yet.',
              icon: Icons.tag_rounded,
            ),
          if (AdminColumns.isWide(context))
            AdminColumns(
              itemCount: topics.length,
              itemBuilder: (BuildContext context, int i, bool _) =>
                  AdminTopicListRow(
                    item: topics[i],
                    onTap: () =>
                        _push(AppRouter.adminTopicDetail, arguments: topics[i]),
                  ),
            )
          else
            for (final AdminTopic item in topics)
              AdminTopicListRow(
                item: item,
                onTap: () => _push(AppRouter.adminTopicDetail, arguments: item),
              ),
        ] else ...[
          if (data.shelves.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: LiveEmptyState(
                message: 'No shelves yet. Tap Create to add one.',
                icon: Icons.view_agenda_outlined,
              ),
            ),
          if (AdminColumns.isWide(context) && data.shelves.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: AdminColumns(
                itemCount: data.shelves.length,
                itemBuilder: (BuildContext context, int i, bool last) =>
                    Padding(
                      padding: EdgeInsets.only(bottom: last ? 0 : 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AdminSectionHeading(
                            title: data.shelves[i].title,
                            onDelete: () => _deleteShelf(data.shelves[i]),
                          ),
                          const SizedBox(height: 10),
                          AdminShelfBlock(card: data.shelves[i]),
                        ],
                      ),
                    ),
              ),
            )
          else
            for (final AdminShelf shelf in data.shelves) ...[
              SizedBox(height: shelf == data.shelves.first ? 30 : 50),
              AdminSectionHeading(
                title: shelf.title,
                onDelete: () => _deleteShelf(shelf),
              ),
              const SizedBox(height: 10),
              AdminShelfBlock(card: shelf),
            ],
        ],
      ]),
    );
  }
}
