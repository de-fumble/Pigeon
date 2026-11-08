import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_columns.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/skeleton.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/admin/admin_category_badge.dart';
import 'package:pigeon/components/admin/admin_create_button.dart';
import 'package:pigeon/components/shared/app_dialogs.dart';
import 'package:pigeon/components/admin/admin_page_header.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/admin_service.dart';

export 'package:pigeon/components/admin/admin_category_badge.dart'
    show AdminCategoryData;

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final GlobalKey<LiveLoaderState<List<AdminCategory>>> _loaderKey =
      GlobalKey<LiveLoaderState<List<AdminCategory>>>();

  /// How many categories were last loaded; new ones go after them.
  int _count = 0;

  /// Top-level categories only; subcategories live on the detail screen.
  Future<List<AdminCategory>> _load() async {
    final List<AdminCategory> all = await AdminService.instance
        .fetchCategories();
    final List<AdminCategory> top = all
        .where((AdminCategory c) => c.parentId == null)
        .toList();
    _count = top.length;
    return top;
  }

  Future<void> _reload() async => _loaderKey.currentState?.reload();

  Future<void> _create() async {
    final String? name = await showTextInputDialog(
      context,
      title: 'New category',
      hint: 'Name',
      confirmLabel: 'Create',
    );
    if (name == null || !mounted) return;
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.createCategory(
        name: name,
        sortOrder: _count + 1,
      ),
      success: '$name created.',
    );
    if (ok) await _reload();
  }

  Future<void> _open(AdminCategory category) async {
    await Navigator.of(context).pushNamed(
      AppRouter.adminCategoryDetail,
      arguments: AdminCategoryData.fromCategory(category),
    );
    if (mounted) await _reload();
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
              title: 'Categories',
              trailing: AdminCreateButton(onPressed: _create),
            ),
            Expanded(
              child: LiveLoader<List<AdminCategory>>(
                key: _loaderKey,
                load: _load,
                placeholder: const SkeletonPage(
                  header: false,
                  rows: 7,
                  padding: EdgeInsets.fromLTRB(20, 23, 20, 24),
                ),
                builder:
                    (
                      BuildContext context,
                      List<AdminCategory> categories,
                      Future<void> Function() reload,
                    ) => RefreshIndicator(
                      color: AppColors.accent,
                      onRefresh: reload,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 23, 20, 24),
                        children: staggeredEntrance([
                          if (categories.isEmpty)
                            const LiveEmptyState(
                              message: 'No categories yet.',
                              icon: Icons.category_outlined,
                            ),
                          if (AdminColumns.isWide(context))
                            AdminColumns(
                              itemCount: categories.length,
                              itemBuilder:
                                  (BuildContext context, int i, bool _) =>
                                      _CategoryRow(
                                        category:
                                            AdminCategoryData.fromCategory(
                                              categories[i],
                                            ),
                                        hidden: !categories[i].isActive,
                                        onTap: () => _open(categories[i]),
                                      ),
                            )
                          else
                            for (final AdminCategory category in categories)
                              _CategoryRow(
                                category: AdminCategoryData.fromCategory(
                                  category,
                                ),
                                hidden: !category.isActive,
                                onTap: () => _open(category),
                              ),
                        ]),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.onTap,
    this.hidden = false,
  });

  final AdminCategoryData category;
  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            AdminCategoryBadge(category: category),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hidden ? '${category.title} (hidden)' : category.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
