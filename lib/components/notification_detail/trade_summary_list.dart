import 'package:flutter/material.dart';
import 'package:pigeon/models/trade_result_notification.dart';

class TradeSummaryList extends StatelessWidget {
  const TradeSummaryList({super.key, required this.rows});

  final List<TradeSummaryRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < rows.length; i++) ...<Widget>[
          _Row(row: rows[i]),
          if (i != rows.length - 1) const _Divider(),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});

  final TradeSummaryRow row;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(
      color: row.highlight ? Colors.white : Colors.white70,
      fontSize: row.highlight ? 18 : 16,
      fontWeight: row.highlight ? FontWeight.w500 : FontWeight.w400,
      height: 1.4,
    );
    final TextStyle valueStyle = TextStyle(
      color: Colors.white,
      fontSize: row.highlight ? 22 : 16,
      fontWeight: row.highlight ? FontWeight.w800 : FontWeight.w500,
      height: 1.4,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(row.label, style: labelStyle)),
          Text(row.value, style: valueStyle),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Colors.white.withValues(alpha: 0.18));
  }
}
