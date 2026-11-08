import 'package:flutter/material.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/utils/date_formatters.dart';

enum AdminUsersFilter {
  all('All', null),
  sevenDays('7D', 7),
  oneMonth('1M', 30);

  const AdminUsersFilter(this.label, this.days);

  final String label;

  /// Window passed to the admin RPCs; null means since the first day.
  final int? days;
}

/// Series → chart points normalised to 0..1 on both axes (y = 1 is the top
/// line). A flat series sits on the middle line.
List<Offset> adminChartPoints(List<AdminSeriesPoint> series) {
  if (series.isEmpty) return <Offset>[];
  if (series.length == 1) {
    return <Offset>[const Offset(0, 0.5), const Offset(1, 0.5)];
  }
  final List<int> values = series.map((AdminSeriesPoint p) => p.value).toList();
  final int min = values.reduce((int a, int b) => a < b ? a : b);
  final int max = values.reduce((int a, int b) => a > b ? a : b);
  return <Offset>[
    for (int i = 0; i < series.length; i++)
      Offset(
        i / (series.length - 1),
        max == min ? 0.5 : (values[i] - min) / (max - min),
      ),
  ];
}

/// Three x-axis labels (first, middle, last day): weekdays for a 7-day
/// window, dates otherwise.
List<String> adminChartLabels(
  List<AdminSeriesPoint> series,
  AdminUsersFilter filter,
) {
  if (series.isEmpty) return <String>[];
  String label(DateTime d) => filter == AdminUsersFilter.sevenDays
      ? const <String>[
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun',
        ][d.weekday - 1]
      : '${DateFormatters.monthShort(d.month)} ${d.day}';
  return <String>[
    label(series.first.day),
    label(series[series.length ~/ 2].day),
    label(series.last.day),
  ];
}
