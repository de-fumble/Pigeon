import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/admin/admin_create_button.dart';
import 'package:pigeon/components/admin/admin_page_header.dart';
import 'package:pigeon/components/admin/admin_radio_dot.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/services/admin_service.dart';
import 'package:pigeon/router/app_router.dart';

class AdminMarketCategoryScreen extends StatefulWidget {
  const AdminMarketCategoryScreen({super.key});

  @override
  State<AdminMarketCategoryScreen> createState() =>
      _AdminMarketCategoryScreenState();
}

class _AdminMarketCategoryScreenState extends State<AdminMarketCategoryScreen> {
  int? _selectedIndex;

  void _selectCategory(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<List<AdminCategory>> _load() async {
    final List<AdminCategory> all = await AdminService.instance
        .fetchCategories();
    return all
        .where((AdminCategory c) => c.parentId == null && c.isActive)
        .toList();
  }

  void _next(List<AdminCategory> categories) {
    Navigator.of(context).pushReplacementNamed(
      AppRouter.adminMarketCreate,
      arguments: categories[_selectedIndex ?? 0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminFlowBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AdminPageHeader(title: 'Select category', compact: true),
            const SizedBox(height: 15),
            Expanded(
              child: LiveLoader<List<AdminCategory>>(
                load: _load,
                builder:
                    (
                      BuildContext context,
                      List<AdminCategory> categories,
                      Future<void> Function() reload,
                    ) {
                      if (categories.isEmpty) {
                        return const LiveEmptyState(
                          message: 'Add a category first.',
                          icon: Icons.category_outlined,
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: staggeredEntrance([
                                for (
                                  int index = 0;
                                  index < categories.length;
                                  index++
                                )
                                  _CategoryOption(
                                    label: categories[index].name,
                                    selected: _selectedIndex == index,
                                    dimmed:
                                        _selectedIndex != null &&
                                        _selectedIndex != index,
                                    onTap: () => _selectCategory(index),
                                  ),
                              ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: AdminCreateButton(
                                label: 'Next',
                                height: 50,
                                minWidth: 103,
                                fontSize: 17,
                                onPressed: () => _next(categories),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.label,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: dimmed ? AppColors.textMuted : AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
              AdminRadioDot(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}
