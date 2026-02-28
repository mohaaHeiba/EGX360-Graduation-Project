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
      ..style = PaintingStyle.stroke;

    final path = Path();
    final random = Random();
    double x = 0;
    double y = size.height / 2;

    path.moveTo(x, y);

    while (x < size.width) {
      x += size.width / 20;
      y += (random.nextDouble() - 0.5) * size.height / 3;
      y = y.clamp(0.0, size.height);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Fill area
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
