import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_shell.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/admin/admin_data_source_card.dart';
import 'package:pigeon/components/shared/app_side_menu.dart';
import 'package:pigeon/components/admin/admin_summary_card.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/admin_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final GlobalKey<LiveLoaderState<AdminOverview>> _loaderKey =
      GlobalKey<LiveLoaderState<AdminOverview>>();

  /// Opens a section, then refreshes the counts it may have changed.
  Future<void> _open(String route, {Object? arguments}) async {
    await Navigator.of(context).pushNamed(route, arguments: arguments);
    if (mounted) await _loaderKey.currentState?.reload();
  }

  List<Widget> _cards(AdminOverview overview) => <Widget>[
    AdminSummaryCard(
      label: 'Users',
      value: LiveFormatters.groupDigits(overview.totalUsers),
      iconAsset: AppIcons.adminUsers,
      backgroundColor: const Color(0xFFEEF8F7),
      onTap: () => _open(AppRouter.adminUsers),
    ),
    AdminSummaryCard(
      label: 'Wage Volume',
      value: LiveFormatters.naira(overview.wagerVolumeKobo),
      iconAsset: AppIcons.adminWageVolume,
      backgroundColor: const Color(0xFFF8EDE7),
      showChevron: false,
      onTap: () => _open(
        AppRouter.adminSection,
        arguments: const <String, String>{'title': 'Wage Volume'},
      ),
    ),
    AdminSummaryCard(
      label: 'Markets',
      value: LiveFormatters.groupDigits(overview.totalMarkets),
      iconAsset: AppIcons.adminMarkets,
      backgroundColor: const Color(0xFFECE9F2),
      onTap: () => _open(AppRouter.adminMarkets),
    ),
    AdminSummaryCard(
      label: 'Categories',
      value: LiveFormatters.groupDigits(overview.categoriesCount),
      iconAsset: AppIcons.adminCategories,
      backgroundColor: const Color(0xFFF9F5F4),
      onTap: () => _open(AppRouter.adminCategories),
    ),
    AdminSummaryCard(
      label: 'Topics & Shelves',
      value: LiveFormatters.groupDigits(
        overview.topicsCount + overview.shelvesCount,
      ),
      iconAsset: AppIcons.adminTopicsShelves,
      backgroundColor: const Color(0xFFFFF7D1),
      onTap: () => _open(AppRouter.adminTopicsShelves),
    ),
    AdminSummaryCard(
      label: 'Banners',
      value: LiveFormatters.groupDigits(overview.bannersCount),
      iconAsset: AppIcons.adminBanners,
      backgroundColor: const Color(0xFFE1FFE5),
      onTap: () => _open(AppRouter.adminBanners),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Beside the admin sidebar, closing and the side menu live there.
    final bool sidebar = AdminShellScope.hasSidebar(context);
    // Three cards a row once the content area is laptop-wide.
    final int columns = MediaQuery.sizeOf(context).width >= 760 ? 3 : 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 17.5, 0),
              child: SizedBox(
                height: 45,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!sidebar)
                      Pressable(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: AppSvgIcon(
                            asset: AppIcons.adminCancel,
                            size: 24,
                          ),
                        ),
                      ),
                    if (!sidebar) const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Admin Panel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (!sidebar)
                      Pressable(
                        onTap: () => showSidebar(context, showAdminLink: true),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: const AppSvgIcon(
                            asset: AppIcons.avatarProfile,
                            size: 45,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accent,
                onRefresh: () async => _loaderKey.currentState?.reload(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
                      const AdminDataSourceCard(),
                      const SizedBox(height: 16),
                      LiveLoader<AdminOverview>(
                        key: _loaderKey,
                        load: AdminService.instance.fetchOverview,
                        placeholder: const LiveSkeleton(cards: 3),
                        builder:
                            (
                              BuildContext context,
                              AdminOverview overview,
                              Future<void> Function() reload,
                            ) {
                              final List<Widget> cards = _cards(overview);
                              return Column(
                                children: staggeredEntrance([
                                  for (
                                    int i = 0;
                                    i < cards.length;
                                    i += columns
                                  ) ...[
                                    if (i > 0) const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        for (
                                          int j = i;
                                          j < i + columns;
                                          j++
                                        ) ...[
                                          if (j > i) const SizedBox(width: 16),
                                          Expanded(
                                            child: j < cards.length
                                                ? cards[j]
                                                : const SizedBox.shrink(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ]),
                              );
                            },
                      ),
                    ],
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
