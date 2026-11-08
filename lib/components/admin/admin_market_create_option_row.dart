import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class AdminMarketCreateOptionRow extends StatelessWidget {
  const AdminMarketCreateOptionRow({
    super.key,
    this.avatar,
    this.label = 'Option 1',
    this.amount = '₦25',
    this.percentage = '25%',
    this.isAddOther = false,
  });

  final String? avatar;
  final String label;
  final String amount;
  final String percentage;
  final bool isAddOther;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(16);
    final Widget content = Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: radius,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 36,
            height: 36,
            child: avatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: const Color(0xFF34343A),
                      alignment: Alignment.center,
                      child: Text(
                        avatar!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF34343A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isAddOther ? AppColors.textMuted : AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (!isAddOther) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF34343A),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                amount,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              percentage,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );

    if (!isAddOther) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: content,
      );
    }

    return CustomPaint(
      painter: _DashedRoundedBorderPainter(
        radius: radius,
        color: AppColors.textMuted.withValues(alpha: 0.45),
        strokeWidth: 1.2,
        dashLength: 6,
        gapLength: 4,
      ),
      child: content,
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  _DashedRoundedBorderPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final BorderRadius radius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      radius.topLeft,
    );

    final Path path = Path()..addRRect(rrect);

    final Path dashed = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashLength).clamp(0.0, metric.length);
        dashed.addPath(metric.extractPath(distance, end), Offset.zero);
        distance = end + gapLength;
      }
    }

    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.dashLength != dashLength ||
        old.gapLength != gapLength ||
        old.radius != radius;
  }
}
