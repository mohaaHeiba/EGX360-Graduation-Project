import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdvancedChartShimmer extends StatelessWidget {
  const AdvancedChartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use AppColors or Theme colors for shimmer
    final baseColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF4A4A4A) : Colors.grey[100]!;

    return SizedBox(
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        period: const Duration(milliseconds: 1500),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Column(
            children: [
              // Chart Area
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _ChartSkeletonPainter(),
                ),
              ),
              const SizedBox(height: 10),
              // X-Axis Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: 30,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final random = Random(42); // Fixed seed for consistent look

    // Generate random points for the chart
    final points = <Offset>[];
    const int numPoints = 20;
    final double stepX = size.width / (numPoints - 1);

    for (int i = 0; i < numPoints; i++) {
      final x = i * stepX;
      // Random y between 20% and 80% of height to avoid edges
      final y = size.height * (0.2 + 0.6 * random.nextDouble());
      points.add(Offset(x, y));
    }

    // Draw smooth curve
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      // Control points for quadratic bezier (simplified smoothing)
      // final cp = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);

      // Using quadratic bezier to midpoint then line to next point is a simple smoothing strategy,
      // but for a continuous smooth curve, we usually use cubicTo or quadraticTo through control points.
      // Let's use a simple Catmull-Rom spline-like approach or just simple quadratic to midpoints.
      // Actually, for a shimmer skeleton, simple lines or simple curves are fine.
      // Let's do simple quadratic bezier to the midpoint of the segment.

      if (i == 0) {
        path.lineTo(p0.dx, p0.dy);
      }

      // Draw to the midpoint between current and next
      final midX = (p0.dx + p1.dx) / 2;
      final midY = (p0.dy + p1.dy) / 2;

      // This is a bit manual. Let's just use a simple spline library logic or just connect points.
      // Connecting points with lines is "jagged".
      // Let's try to make it curvy.

      // Simple approach: Quadratic bezier from prev point to current point using control point.
      // But we are iterating points.

      // Let's use the standard "smooth line" approach:
      // Start at p0.
      // For each subsequent point, draw quadratic bezier.
      // Control point is the previous point? No.

      // Let's stick to a simpler approach:
      // Just draw lines for now, but maybe slightly curved?
      // Actually, let's just use `path.quadraticBezierTo` for a smoother look.
      // We'll use the midpoint technique.

      // final controlPoint = p0;
      // final endPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);

      // This creates a curve that doesn't pass through the points exactly but looks smooth.
      // For a skeleton, it's fine.
      if (i < points.length - 1) {
        path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
      }
    }
    // Connect to last point
    path.lineTo(points.last.dx, points.last.dy);

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw the fill
    // We need to close the path to the bottom
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
