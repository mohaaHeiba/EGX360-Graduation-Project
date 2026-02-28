import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:egx/core/custom/background/candle_stick/domain/entity/candlestick_data.dart';

class CandlestickPainter extends CustomPainter {
  final List<CandlestickData> candlesticks;
  final double animationValue;

  CandlestickPainter({
    required this.candlesticks,
    required this.animationValue,
  });
  @override
  void paint(Canvas canvas, Size size) {
    if (candlesticks.isEmpty) return;

    // 1. حساب الـ step (المسافة بين الشموع) بناءً على عرض الشاشة الكلي
    // نستخدم (length - 1) لضمان أن أول شمعة عند 0 وآخر شمعة عند نهاية العرض
    final double step =
        size.width / (candlesticks.length > 1 ? candlesticks.length - 1 : 1);

    // 2. جعل عرض الشمعة نسبة من المسافة (مثلاً 60% من الـ step) لضمان التناسق
    final double candleWidth = (step * 0.6).clamp(
      2.0,
      20.0,
    ); // clamp لمنعها من أن تصبح ضخمة جداً أو صغيرة جداً

    // إيجاد أعلى وأقل سعر
    double minPrice = candlesticks.map((e) => e.low).reduce(math.min);
    double maxPrice = candlesticks.map((e) => e.high).reduce(math.max);

    final priceRange = maxPrice - minPrice;
    final chartHeight = size.height * 0.7;
    final chartTop = size.height * 0.15;

    final visibleCandlesCount = (animationValue * candlesticks.length).floor();

    for (int i = 0; i < visibleCandlesCount; i++) {
      final candle = candlesticks[i];

      // 3. حساب موقع X الديناميكي بحيث أول شمعة تبدأ من الصفر تماماً
      // ونطرح نصف عرض الشمعة لتكون متمركزة حول النقطة x
      final double xCenter = i * step;
      final double xStart = xCenter - (candleWidth / 2);

      final openY =
          chartTop + ((maxPrice - candle.open) / priceRange) * chartHeight;
      final closeY =
          chartTop + ((maxPrice - candle.close) / priceRange) * chartHeight;
      final highY =
          chartTop + ((maxPrice - candle.high) / priceRange) * chartHeight;
      final lowY =
          chartTop + ((maxPrice - candle.low) / priceRange) * chartHeight;

      final bodyTop = math.min(openY, closeY);
      final bodyBottom = math.max(openY, closeY);
      final bool isGreen = candle.close >= candle.open;

      // رسم الفتيل (Wick) في منتصف الشمعة بالظبط
      final wickPaint = Paint()
        ..color = (isGreen ? const Color(0xFF26a69a) : const Color(0xFFef5350))
            .withOpacity(0.5)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(xCenter, highY), Offset(xCenter, lowY), wickPaint);

      // رسم جسم الشمعة (Body)
      final bodyPaint = Paint()
        ..color = isGreen ? const Color(0xFF26a69a) : const Color(0xFFef5350)
        ..style = PaintingStyle.fill;

      final bodyRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          xStart,
          bodyTop,
          candleWidth,
          math.max((bodyBottom - bodyTop).abs(), 1.0),
        ),
        const Radius.circular(1),
      );

      canvas.drawRRect(bodyRect, bodyPaint);

      // توهج (Glow)
      canvas.drawRRect(
        bodyRect,
        Paint()
          ..color = bodyPaint.color.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // رسم خطوط الشبكة (Grid) لتغطي العرض بالكامل
    _drawGrid(canvas, size, chartTop, chartHeight);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double chartTop,
    double chartHeight,
  ) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = chartTop + (i * chartHeight / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(CandlestickPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.candlesticks.length != candlesticks.length;
  }
}
