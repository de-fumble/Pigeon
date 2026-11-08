import 'package:flutter/material.dart';

class AdminGrowthChart extends StatelessWidget {
  const AdminGrowthChart({super.key, required this.points});

  /// Points normalised to 0..1 on both axes (y = 1 is the top grid line).
  final List<Offset> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: _AdminGrowthChartPainter(points),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AdminGrowthChartPainter extends CustomPainter {
  _AdminGrowthChartPainter(this.points);

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFB0B0B0).withValues(alpha: 0.7)
      ..strokeWidth = 0.5;

    final Paint linePaint = Paint()
      ..color = const Color(0xFF00C34E)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double width = size.width;
    final double height = size.height;

    for (final double dy in <double>[0, height / 2, height]) {
      canvas.drawLine(Offset(0, dy), Offset(width, dy), gridPaint);
    }

    if (points.isEmpty) {
      return;
    }

    final Path path = Path();
    for (int index = 0; index < points.length; index++) {
      final Offset point = points[index];
      final double dx = width * point.dx.clamp(0.0, 1.0);
      final double dy = height - height * point.dy.clamp(0.0, 1.0);

      if (index == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _AdminGrowthChartPainter oldDelegate) {
    if (oldDelegate.points.length != points.length) {
      return true;
    }

    for (int index = 0; index < points.length; index++) {
      if (oldDelegate.points[index] != points[index]) {
        return true;
      }
    }

    return false;
  }
}
