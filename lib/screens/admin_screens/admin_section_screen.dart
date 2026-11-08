import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_axis_label.dart';
import 'package:pigeon/components/admin/admin_filter_chip.dart';
import 'package:pigeon/components/admin/admin_growth_chart.dart';
import 'package:pigeon/components/admin/admin_users_data.dart';
import 'package:pigeon/components/admin/admin_users_total_card.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/skeleton.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/services/admin_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

/// Admin detail screen opened from a summary card. "Wage Volume" charts the
/// traded amount per day; other titles show a placeholder.
class AdminSectionScreen extends StatelessWidget {
  const AdminSectionScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Pressable(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Expanded(
                child: title == 'Wage Volume'
                    ? const _WageVolume()
                    : const _Placeholder(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WageVolume extends StatefulWidget {
  const _WageVolume();

  @override
  State<_WageVolume> createState() => _WageVolumeState();
}

class _WageVolumeState extends State<_WageVolume> {
  AdminUsersFilter _filter = AdminUsersFilter.all;

  @override
  Widget build(BuildContext context) {
    return LiveLoader<List<AdminSeriesPoint>>(
      load: () => AdminService.instance.fetchVolumeSeries(days: _filter.days),
      refreshKey: _filter,
      placeholder: const SkeletonPage(
        header: false,
        cards: 2,
        rows: 0,
        padding: EdgeInsets.zero,
      ),
      builder:
          (
            BuildContext context,
            List<AdminSeriesPoint> series,
            Future<void> Function() reload,
          ) {
            final int total = series.fold(
              0,
              (int sum, AdminSeriesPoint p) => sum + p.value,
            );
            final List<String> labels = adminChartLabels(series, _filter);
            return RefreshIndicator(
              color: AppColors.accent,
              onRefresh: reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: staggeredEntrance([
                  AdminUsersTotalCard(
                    label: _filter == AdminUsersFilter.all
                        ? 'Total Volume'
                        : 'Volume (${_filter.label})',
                    totalUsers: LiveFormatters.naira(total),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      for (final AdminUsersFilter f in AdminUsersFilter.values)
                        SizedBox(
                          width: 54,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AdminFilterChip(
                              label: f.label,
                              selected: _filter == f,
                              onTap: () => setState(() => _filter = f),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (total == 0)
                    const LiveEmptyState(
                      message: 'No trades in this period yet.',
                      icon: Icons.show_chart_rounded,
                    )
                  else ...[
                    AdminGrowthChart(points: adminChartPoints(series)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        for (int i = 0; i < labels.length; i++)
                          Expanded(
                            child: Align(
                              alignment: i == 0
                                  ? Alignment.centerLeft
                                  : i == labels.length - 1
                                  ? Alignment.centerRight
                                  : Alignment.center,
                              child: AdminAxisLabel(label: labels[i]),
                            ),
                          ),
                      ],
                    ),
                  ],
                ]),
              ),
            );
          },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const SizedBox(
          height: 120,
          child: Center(
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.textMuted,
              size: 42,
            ),
          ),
        ),
      ),
    );
  }
}
