import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:egx/core/custom/background/candle_stick/domain/entity/candlestick_data.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class InteractiveCandlestickPainter extends CustomPainter {
  final List<CandlestickData> candlesticks;
  final double animationValue;
  final Offset? mousePosition;

  InteractiveCandlestickPainter({
    required this.candlesticks,
    required this.animationValue,
    this.mousePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candlesticks.isEmpty) return;

    final double step = size.width / candlesticks.length;
    final double candleWidth = step * 0.7;

    double minPrice = candlesticks.map((e) => e.low).reduce(math.min);
    double maxPrice = candlesticks.map((e) => e.high).reduce(math.max);
    final priceRange = maxPrice - minPrice;
    final chartHeight = size.height * 0.8;
    final chartTop = size.height * 0.1;

    // 1. رسم الشبكة
    _drawGridAndLabels(
      canvas,
      size,
      maxPrice,
      priceRange,
      chartHeight,
      chartTop,
    );

    // 2. رسم المنطقة الملونة (بدون الخط) - تظهر تدريجياً مع الأنيميشن
    _drawFilledAreaUnderCurve(
      canvas,
      size,
      step,
      maxPrice,
      priceRange,
      chartHeight,
      chartTop,
    );

    // 3. رسم الشموع - تظهر شمعة تلو الأخرى
    int visibleCount = (animationValue * candlesticks.length).floor();
    for (int i = 0; i < visibleCount; i++) {
      _drawNeonCandle(
        canvas,
        candlesticks[i],
        i,
        step,
        candleWidth,
        maxPrice,
        priceRange,
        chartHeight,
        chartTop,
      );
    }

    // 4. رسم الـ Crosshair
    if (mousePosition != null) {
      _drawNeonCrosshair(canvas, size, mousePosition!);
    }
  }

  // تم تعديل هذه الدالة لإزالة الخط ورسم الألوان فقط بشكل تدريجي
  void _drawFilledAreaUnderCurve(
    Canvas canvas,
    Size size,
    double step,
    double maxPrice,
    double priceRange,
    double chartHeight,
    double chartTop,
  ) {
    if (candlesticks.isEmpty) return;

    // تحديد عدد الشموع المرئية بناءً على الأنيميشن لضمان ظهور الخلفية مع الشموع
    int visibleCount = (animationValue * candlesticks.length).floor();
    if (visibleCount == 0) return;

    final firstPrice = candlesticks.first.close;
    final lastPrice = candlesticks[visibleCount - 1].close;
    final isIncreasing = lastPrice > firstPrice;

    final path = Path();
    final firstCloseY =
        chartTop +
        ((maxPrice - candlesticks[0].close) / priceRange) * chartHeight;

    path.moveTo(0, size.height);
    path.lineTo(0, firstCloseY);

    for (int i = 0; i < visibleCount; i++) {
      final x = i * step + step / 2;
      final closeY =
          chartTop +
          ((maxPrice - candlesticks[i].close) / priceRange) * chartHeight;

      if (i == 0) {
        path.lineTo(x, closeY);
      } else {
        final prevX = (i - 1) * step + step / 2;
        final prevCloseY =
            chartTop +
            ((maxPrice - candlesticks[i - 1].close) / priceRange) * chartHeight;
        final controlX = (prevX + x) / 2;
        final controlY = (prevCloseY + closeY) / 2;
        path.quadraticBezierTo(controlX, controlY, x, closeY);
      }
    }

    // إغلاق المسار عند آخر شمعة مرئية حالياً
    final lastVisibleX = (visibleCount - 1) * step + step / 2;
    path.lineTo(lastVisibleX, size.height);
    path.close();

    final gradientColors = isIncreasing
        ? [
            const Color(0xFF00FFD1).withOpacity(0.15),
            const Color(0xFF00FFD1).withOpacity(0.05),
            const Color(0xFF00FFD1).withOpacity(0.0),
          ]
        : [
            const Color(0xFFFF3131).withOpacity(0.15),
            const Color(0xFFFF3131).withOpacity(0.05),
            const Color(0xFFFF3131).withOpacity(0.0),
          ];

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      ).createShader(Rect.fromLTWH(0, chartTop, size.width, chartHeight));

    canvas.drawPath(path, fillPaint);

    // ملاحظة: تم حذف جزء رسم "linePath" تماماً بناءً على طلبك
  }

  void _drawNeonCandle(
    Canvas canvas,
    CandlestickData candle,
    int i,
    double step,
    double candleWidth,
    double maxPrice,
    double priceRange,
    double chartHeight,
    double chartTop,
  ) {
    final x = i * step;
    final openY =
        chartTop + ((maxPrice - candle.open) / priceRange) * chartHeight;
    final closeY =
        chartTop + ((maxPrice - candle.close) / priceRange) * chartHeight;
    final highY =
        chartTop + ((maxPrice - candle.high) / priceRange) * chartHeight;
    final lowY =
        chartTop + ((maxPrice - candle.low) / priceRange) * chartHeight;

    final color = candle.isGreen
        ? const Color(0xFF00FFD1)
        : const Color(0xFFFF3131);
    final glowOpacity =
        0.2 + (math.sin(DateTime.now().millisecondsSinceEpoch / 300) * 0.1);

    final bodyRect = Rect.fromLTWH(
      x,
      math.min(openY, closeY),
      candleWidth,
      math.max(1, (openY - closeY).abs()),
    );

    final glowPaint = Paint()
      ..color = color.withOpacity(glowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawLine(
      Offset(x + candleWidth / 2, highY),
      Offset(x + candleWidth / 2, lowY),
      glowPaint,
    );
    canvas.drawRect(bodyRect, glowPaint);

    canvas.drawLine(
      Offset(x + candleWidth / 2, highY),
      Offset(x + candleWidth / 2, lowY),
      Paint()
        ..color = color.withOpacity(0.8)
        ..strokeWidth = 1.2,
    );
    canvas.drawRect(bodyRect, Paint()..color = color);
  }

  void _drawNeonCrosshair(Canvas canvas, Size size, Offset position) {
    final linePaint = Paint()
      ..color = Get.context!.theme.colorScheme.onBackground
      ..strokeWidth = 1;
    _drawDashedLine(
      canvas,
      Offset(position.dx, 0),
      Offset(position.dx, size.height),
      linePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(0, position.dy),
      Offset(size.width, position.dy),
      linePaint,
    );

    canvas.drawCircle(
      position,
      8,
      Paint()
        ..color = Colors.cyanAccent.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      position,
      3,
      Paint()..color = Get.context!.theme.colorScheme.onBackground,
    );
    _drawPriceLabel(canvas, size, position);
  }

  void _drawPriceLabel(Canvas canvas, Size size, Offset position) {
    final chartHeight = size.height * 0.8;
    final chartTop = size.height * 0.1;
    double minPrice = candlesticks.map((e) => e.low).reduce(math.min);
    double maxPrice = candlesticks.map((e) => e.high).reduce(math.max);
    final priceRange = maxPrice - minPrice;
    final relativeY = (position.dy - chartTop) / chartHeight;
    final calculatedPrice = maxPrice - (relativeY * priceRange);

    final rect = Rect.fromCenter(
      center: Offset(size.width - 35, position.dy),
      width: 70,
      height: 26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = Colors.cyanAccent.withOpacity(0.9),
    );

    final tp = TextPainter(
      text: TextSpan(
        text: calculatedPrice.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance, currentDistance = 0;
    while (currentDistance < distance) {
      double startFraction = currentDistance / distance;
      currentDistance += dashWidth;
      double endFraction = math.min(currentDistance / distance, 1.0);
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * startFraction,
          p1.dy + (p2.dy - p1.dy) * startFraction,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * endFraction,
          p1.dy + (p2.dy - p1.dy) * endFraction,
        ),
        paint,
      );
      currentDistance += dashSpace;
    }
  }

  void _drawGridAndLabels(
    Canvas canvas,
    Size size,
    double maxPrice,
    double priceRange,
    double chartHeight,
    double chartTop,
  ) {
    final gridPaint = Paint()
      ..color = Get.context!.theme.colorScheme.onBackground.withOpacity(0.1)
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 5; i++) {
      final y = chartTop + (i * chartHeight / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      double price = maxPrice - (i * priceRange / 5);
      textPainter.text = TextSpan(
        text: price.toStringAsFixed(0),
        style: TextStyle(
          color: Get.context!.theme.colorScheme.onBackground,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      final labelBgRect = Rect.fromLTWH(size.width - 60, y - 10, 55, 20);
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelBgRect, const Radius.circular(4)),
        Paint()
          ..color = Get.context!.theme.colorScheme.background.withOpacity(0.7),
      );
      textPainter.paint(canvas, Offset(size.width - 50, y - 8));
    }
  }

  @override
  bool shouldRepaint(covariant InteractiveCandlestickPainter oldDelegate) =>
      true;
}
