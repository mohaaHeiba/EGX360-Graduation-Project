import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Simple shimmer for Markets page loading
class MarketsChartShimmer extends StatelessWidget {
  const MarketsChartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF3A3A3A) : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Price area placeholder
            Container(
              height: 40,
              width: 120,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Chart area
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: _SimpleChartPainter(),
              ),
            ),
            const SizedBox(height: 10),
            // X-Axis Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                (index) => Container(
                  width: 40,
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
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final random = Random(42);
    final path = Path();
    const int numPoints = 15;
    final stepX = size.width / (numPoints - 1);

    path.moveTo(0, size.height * 0.5);
    for (int i = 0; i < numPoints; i++) {
      final x = i * stepX;
      final y = size.height * (0.3 + 0.4 * random.nextDouble());
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
