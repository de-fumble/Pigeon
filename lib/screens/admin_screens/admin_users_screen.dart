import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/skeleton.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/admin/admin_axis_label.dart';
import 'package:pigeon/components/admin/admin_engagement_card.dart';
import 'package:pigeon/components/admin/admin_filter_chip.dart';
import 'package:pigeon/components/admin/admin_growth_chart.dart';
import 'package:pigeon/components/admin/admin_page_header.dart';
import 'package:pigeon/components/admin/admin_users_data.dart';
import 'package:pigeon/components/admin/admin_users_total_card.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/services/admin_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  AdminUsersFilter _selectedFilter = AdminUsersFilter.all;

  void _selectFilter(AdminUsersFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }

    setState(() {
      _selectedFilter = filter;
    });
  }

  Future<_UsersData> _load() async {
    final int? days = _selectedFilter.days;
    final (AdminUserStats stats, List<AdminSeriesPoint> growth) = await (
      AdminService.instance.fetchUserStats(days: days),
      AdminService.instance.fetchUserGrowth(days: days),
    ).wait;
    return (stats: stats, growth: growth);
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
            const AdminPageHeader(title: 'Users'),
            Expanded(
              child: LiveLoader<_UsersData>(
                load: _load,
                refreshKey: _selectedFilter,
                placeholder: const SkeletonPage(
                  cards: 2,
                  rows: 3,
                  padding: EdgeInsets.fromLTRB(20, 25, 20, 24),
                ),
                builder:
                    (
                      BuildContext context,
                      _UsersData data,
                      Future<void> Function() reload,
                    ) => _buildBody(data, reload),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(_UsersData data, Future<void> Function() reload) {
    final AdminUserStats stats = data.stats;
    final List<String> xAxisLabels = adminChartLabels(
      data.growth,
      _selectedFilter,
    );

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 24),
        children: staggeredEntrance([
          AdminUsersTotalCard(
            label: _selectedFilter == AdminUsersFilter.all
                ? 'Total Users'
                : 'New Users (${_selectedFilter.label})',
            totalUsers: LiveFormatters.groupDigits(stats.newUsers),
          ),
          const SizedBox(height: 50),
          const Text('User growth', style: _sectionStyle),
          const SizedBox(height: 20),
          Row(
            children: [
              for (final AdminUsersFilter filter in AdminUsersFilter.values)
                SizedBox(
                  width: 54,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AdminFilterChip(
                      label: filter.label,
                      selected: _selectedFilter == filter,
                      onTap: () => _selectFilter(filter),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 30),
          AdminGrowthChart(points: adminChartPoints(data.growth)),
          const SizedBox(height: 15),
          Row(
            children: [
              for (int i = 0; i < xAxisLabels.length; i++)
                Expanded(
                  child: Align(
                    alignment: i == 0
                        ? Alignment.centerLeft
                        : i == xAxisLabels.length - 1
                        ? Alignment.centerRight
                        : Alignment.center,
                    child: AdminAxisLabel(label: xAxisLabels[i]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 50),
          const Text('Engagement', style: _sectionStyle),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AdminEngagementCard(
                  backgroundColor: const Color(0xFF92C3C0),
                  iconAsset: AppIcons.adminActiveUsers,
                  title: 'Active Users',
                  value: LiveFormatters.groupDigits(stats.activeUsers),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AdminEngagementCard(
                  backgroundColor: const Color(0xFF8871AE),
                  iconAsset: AppIcons.adminJoinedToday,
                  title: 'Joined Today',
                  value: LiveFormatters.groupDigits(stats.joinedToday),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  static const TextStyle _sectionStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}

typedef _UsersData = ({AdminUserStats stats, List<AdminSeriesPoint> growth});
