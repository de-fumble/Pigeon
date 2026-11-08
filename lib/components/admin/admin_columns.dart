import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lays admin list rows out in two side-by-side columns (first half on the
/// left) once the admin content area is laptop-wide. Callers keep their
/// single-column code for narrower screens and check [isWide] to choose.
class AdminColumns extends StatelessWidget {
  const AdminColumns({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.gap = 32,
  });

  /// Content width from which lists split into two columns.
  static const double wideWidth = 760;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideWidth;

  final int itemCount;

  /// Builds row [index]; [lastInColumn] lets rows drop their bottom divider.
  final Widget Function(BuildContext context, int index, bool lastInColumn)
  itemBuilder;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final int perColumn = (itemCount / 2).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int c = 0; c < 2; c++) ...<Widget>[
          if (c > 0) SizedBox(width: gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (
                  int i = c * perColumn;
                  i < math.min(itemCount, (c + 1) * perColumn);
                  i++
                )
                  itemBuilder(
                    context,
                    i,
                    i == math.min(itemCount, (c + 1) * perColumn) - 1,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
