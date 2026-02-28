import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/utils/price_formatter.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/currency/presentation/controllers/currency_details_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Widget buildChart(
  bool isPositive,
  BuildContext context,
  List<CandleEntity> candles, {
  required double prevClose,
  required String symbol,
  required String timeRange,
  Function(CandleEntity?, double?)? onTrackballChange,
}) {
  if (candles.isEmpty) {
    return const SizedBox.shrink();
  }

  final CurrencyDetailsController controller = Get.find();

  // 2️⃣ تحضير نقاط الشارت
  final spots = candles.map((e) {
    return FlSpot(e.candleTime.millisecondsSinceEpoch.toDouble(), e.close);
  }).toList();

  // 3️⃣ حساب حدود السعر (Y-Axis)
  final double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
  final double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
  final double yRange = maxY - minY;
  final double yPadding = yRange * 0.1;
  final double adjustedMinY = minY - yPadding;
  final double adjustedMaxY = maxY + yPadding;

  // 4️⃣ حساب حدود الوقت (X-Axis)
  double minX;
  double maxX;

  if (timeRange == '1D') {
    final baseDate = candles.last.candleTime;
    final marketOpen = DateTime.utc(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      10,
      0,
    );
    final marketClose = DateTime.utc(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      14,
      30,
    );

    minX = marketOpen.millisecondsSinceEpoch.toDouble();
    maxX = marketClose.millisecondsSinceEpoch.toDouble();
  } else {
    minX = spots.first.x;
    maxX = spots.last.x;
  }

  // 5️⃣ إعداد الألوان
  final Color primaryColor = isPositive ? AppColors.primary : Colors.red;
  final List<Color> gradientColors = [
    primaryColor.withOpacity(0.3),
    primaryColor.withOpacity(0.0),
  ];

  // 6️⃣ دالة تنسيق التواريخ
  String formatDate(DateTime date) {
    if (timeRange == '1D') return DateFormat('HH:mm').format(date);
    if (timeRange == '1W') return DateFormat('E').format(date);
    if (timeRange == '1M' || timeRange == '3M') {
      return DateFormat('d MMM').format(date);
    }
    return DateFormat('MMM yy').format(date);
  }

  // 7️⃣ توليد 5 تواريخ (Labels)
  final double step = (maxX - minX) / 4;
  final List<Widget> dateWidgets = List.generate(5, (index) {
    final currentVal = minX + (step * index);
    final date = DateTime.fromMillisecondsSinceEpoch(
      currentVal.toInt(),
      isUtc: true,
    );

    return Text(
      formatDate(date),
      style: TextStyle(
        color: context.onSurface.withOpacity(0.5),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  });

  // 8️⃣ بناء الواجهة
  return Obx(() {
    return Column(
      children: [
        // الجزء العلوي: الشارت نفسه
        Expanded(
          // 🛑 إضافة Listener هنا لضمان التقاط رفع الإصبع بدقة
          child: Listener(
            onPointerUp: (_) {
              controller.selectedSpotX.value = null;
              onTrackballChange?.call(null, null);
            },
            onPointerCancel: (_) {
              controller.selectedSpotX.value = null;
              onTrackballChange?.call(null, null);
            },
            child: LineChart(
              duration: Duration.zero,
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: adjustedMinY,
                maxY: adjustedMaxY,

                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),

                lineTouchData: LineTouchData(
                  enabled: true,
                  distanceCalculator: (touchPoint, spotPixelCoordinates) =>
                      (touchPoint.dx - spotPixelCoordinates.dx).abs(),
                  touchSpotThreshold: double.maxFinite,

                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? touchResponse) {
                        // التحقق من انتهاء اللمس داخل الكنترولر أيضاً
                        final isTouchEnded =
                            event is FlPanEndEvent ||
                            event is FlTapUpEvent ||
                            event is FlLongPressEnd ||
                            event is FlPointerExitEvent ||
                            event is FlTapCancelEvent;

                        if (isTouchEnded) {
                          controller.selectedSpotX.value = null;
                          onTrackballChange?.call(null, null);
                          return;
                        }

                        if (touchResponse != null &&
                            touchResponse.lineBarSpots != null &&
                            touchResponse.lineBarSpots!.isNotEmpty) {
                          final spot = touchResponse.lineBarSpots!.first;
                          controller.selectedSpotX.value = spot.x;

                          if (spot.spotIndex >= 0 &&
                              spot.spotIndex < candles.length) {
                            double yPosFromTouch;
                            try {
                              yPosFromTouch =
                                  (event as dynamic).localPosition.dx;
                            } catch (e) {
                              yPosFromTouch = spot.x;
                            }
                            onTrackballChange?.call(
                              candles[spot.spotIndex],
                              yPosFromTouch,
                            );
                          }
                        }
                      },

                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: context.onSurface.withOpacity(0.5),
                              strokeWidth: 0,
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 4,
                                    color: context.onSurface,
                                    strokeWidth: 2,
                                    strokeColor: primaryColor,
                                  ),
                            ),
                          );
                        }).toList();
                      },

                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) =>
                        touchedBarSpots.map((barSpot) => null).toList(),
                  ),
                ),

                extraLinesData: ExtraLinesData(
                  verticalLines: [
                    if (controller.selectedSpotX.value != null)
                      VerticalLine(
                        x: controller.selectedSpotX.value!,
                        color: context.onSurface.withOpacity(0.5),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                  ],
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: primaryColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dateWidgets,
          ),
        ),
      ],
    );
  });
}
