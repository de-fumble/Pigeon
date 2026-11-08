import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_create_button.dart';
import 'package:pigeon/components/shared/app_dialogs.dart';
import 'package:pigeon/components/admin/admin_market_picker.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/admin/admin_dropdown_label.dart';
import 'package:pigeon/components/admin/admin_market_filter_menu.dart';
import 'package:pigeon/components/admin/admin_market_list_tile.dart';
import 'package:pigeon/components/admin/admin_page_header.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/services/admin_service.dart';

typedef _CreateTopicData = ({
  List<AdminCategory> categories,
  List<AdminMarket> markets,
});

class AdminCreateTopicScreen extends StatefulWidget {
  const AdminCreateTopicScreen({super.key});

  @override
  State<AdminCreateTopicScreen> createState() => _AdminCreateTopicScreenState();
}

class _AdminCreateTopicScreenState extends State<AdminCreateTopicScreen> {
  final TextEditingController _titleController = TextEditingController();
  late final Future<_CreateTopicData> _future = _load();

  AdminCategory? _category;
  String _marketFilter = 'All';

  /// Selected market ids, in the order they were picked.
  final List<String> _selectedMarkets = <String>[];
  bool _saving = false;

  static const TextStyle _labelStyle = TextStyle(
    color: Color(0xFFB0B0B0),
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<_CreateTopicData> _load() async {
    final (List<AdminCategory> categories, List<AdminMarket> markets) = await (
      AdminService.instance.fetchCategories(),
      AdminService.instance.fetchMarkets(),
    ).wait;
    final List<AdminCategory> top = categories
        .where((AdminCategory c) => c.parentId == null)
        .toList();
    _category = top.firstOrNull;
    return (categories: top, markets: markets);
  }

  void _toggleMarket(String id) {
    setState(() {
      if (!_selectedMarkets.remove(id)) {
        _selectedMarkets.add(id);
      }
    });
  }

  Future<void> _create() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty || _saving) return;
    setState(() => _saving = true);
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.createTopic(
        name: title,
        categoryId: _category?.id,
        marketIds: _selectedMarkets,
      ),
      success: '$title created.',
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _saving = false);
    }
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
              title: 'Create Topic',
              trailing: AdminCreateButton(
                label: _saving ? 'Saving…' : 'Create',
                onPressed: _titleController.text.trim().isEmpty || _saving
                    ? null
                    : _create,
              ),
            ),
            Expanded(
              child: FutureBuilder<_CreateTopicData>(
                future: _future,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<_CreateTopicData> snapshot,
                    ) {
                      if (snapshot.hasError) {
                        return LiveErrorState(error: snapshot.error!);
                      }
                      if (!snapshot.hasData) return const LiveSkeleton();
                      return _buildForm(snapshot.data!);
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(_CreateTopicData data) {
    final List<AdminMarket> markets = _marketFilter == 'All'
        ? data.markets
        : data.markets
              .where((AdminMarket m) => m.categoryName == _marketFilter)
              .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
      children: staggeredEntrance([
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Title:', style: _labelStyle),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _titleController,
                cursorColor: AppColors.textPrimary,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.2,
                ),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Text',
                  hintStyle: TextStyle(
                    color: Color(0xFF787878),
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text('Category', style: _labelStyle),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (BuildContext anchorContext) {
                return AdminDropdownLabel(
                  label: _category?.name ?? 'None',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB0B0B0),
                  onTap: () => AdminMarketFilterMenu.show(
                    anchorContext,
                    items: <String>[
                      for (final AdminCategory c in data.categories) c.name,
                    ],
                    selectedItem: _category?.name ?? '',
                    alignStart: true,
                    onSelected: (String value) => setState(
                      () => _category = data.categories.firstWhere(
                        (AdminCategory c) => c.name == value,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text('Select Markets', style: _labelStyle),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (BuildContext anchorContext) {
                return AdminDropdownLabel(
                  label: _marketFilter,
                  onTap: () => AdminMarketFilterMenu.show(
                    anchorContext,
                    items: <String>[
                      'All',
                      for (final AdminCategory c in data.categories) c.name,
                    ],
                    selectedItem: _marketFilter,
                    alignStart: true,
                    onSelected: (String value) =>
                        setState(() => _marketFilter = value),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (markets.isEmpty)
          const LiveEmptyState(
            message: 'No markets here yet.',
            icon: Icons.storefront_outlined,
          ),
        for (int i = 0; i < markets.length; i++)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: AdminMarketRow(
              market: markets[i],
              showDivider: i < markets.length - 1,
              onTap: () => _toggleMarket(markets[i].id),
              trailing: AdminSelectCircle(
                selected: _selectedMarkets.contains(markets[i].id),
              ),
            ),
          ),
      ]),
    );
  }
}
