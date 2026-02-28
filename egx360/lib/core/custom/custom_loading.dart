import 'package:flutter/material.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CandlestickLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? color;
  final Duration duration;

  const CandlestickLoader({
    super.key,
    this.width = 100,
    this.height = 100,
    this.color = AppColors.background,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<CandlestickLoader> createState() => _CandlestickLoaderState();
}

class _CandlestickLoaderState extends State<CandlestickLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(); // تكرار الدورة
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double finalWidth = widget.width ?? 100.w.clamp(90, 110);
    final double finalHeight = widget.height ?? 100.h.clamp(90, 110);
    return SizedBox(
      width: finalWidth,
      height: finalHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LadderCandlePainter(
              progress: _controller.value,
              color: widget.color!,
            ),
          );
        },
      ),
    );
  }
}

class _LadderCandlePainter extends CustomPainter {
  final double progress;
  static const int candleCount = 3;
  final Color color;

  _LadderCandlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // إعدادات الفرشاة
    final fillPaint = Paint()..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 1;

    final wickPaint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final double gap = 4.0;
    final double candleWidth =
        (size.width - (gap * (candleCount - 1))) / candleCount;

    for (int i = 0; i < candleCount; i++) {
      // --- استرجاع منطق الأنيميشن (النمو التدريجي) ---

      // 1. تحديد النطاق الزمني لكل شمعة
      double start = i / candleCount;
      double end = (i + 1) / candleCount;
      double localProgress = 0.0;

      if (progress >= end) {
        localProgress = 1.0; // اكتملت وتنتظر الباقي
      } else if (progress >= start && progress < end) {
        // معادلة النمو: تحويل الوقت الكلي لوقت محلي (0.0 -> 1.0)
        localProgress = (progress - start) / (end - start);
      } else {
        localProgress = 0.0; // لم يبدأ دورها بعد
      }

      // إذا لم يبدأ دور الشمعة، لا ترسم شيئاً
      if (localProgress == 0.0) continue;

      // --- تحديد اللون ---
      if (i == 1) {
        fillPaint.color = AppColors.error; // أحمر
      } else {
        fillPaint.color = AppColors.candleGreen; // أخضر
      }

      // --- الحسابات (مع تأثير الحركة) ---

      double stepHeight = size.height / (candleCount + 1);
      double maxCandleHeight = stepHeight * 1.8; // أقصى ارتفاع ستصل له

      // حساب الارتفاع الحالي بناءً على الأنيميشن
      // استخدمنا Curves.easeOut لجعل حركة الخروج ناعمة وسريعة في البداية
      double currentHeight =
          maxCandleHeight * Curves.easeOut.transform(localProgress);

      // مكان الأرضية (السلم)
      double groundLevel = size.height - (i * stepHeight) - 5;
      double x = i * (candleWidth + gap);

      // --- الرسم ---

      // مستطيل الجسم (ينمو للأعلى)
      final Rect bodyRect = Rect.fromLTWH(
        x,
        groundLevel - currentHeight,
        candleWidth,
        currentHeight,
      );

      // 1. رسم الفتيل
      // الفتيل ينمو مع الجسم
      double wickTop = groundLevel - currentHeight - 6;
      double wickBottom = groundLevel + 6;

      // نتأكد أن الفتيل لا يظهر بشكل غريب إذا كان الارتفاع صفر تقريباً
      if (currentHeight > 5) {
        canvas.drawLine(
          Offset(x + candleWidth / 2, wickTop),
          Offset(x + candleWidth / 2, wickBottom),
          wickPaint,
        );
      }

      // 2. رسم الجسم الملون
      canvas.drawRect(bodyRect, fillPaint);

      // 3. رسم الحواف السوداء (تنمو مع الجسم)
      canvas.drawRect(bodyRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LadderCandlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
