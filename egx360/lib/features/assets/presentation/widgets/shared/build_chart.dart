import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/assets/presentation/controllers/asset_details_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/core/helper/market_status_helper.dart';
import 'package:intl/intl.dart';

// Throttle debug prints
DateTime? _lastPrintTime;
bool? _lastColorState;

Widget buildChart(
  BuildContext context,
  List<CandleEntity> candles, {
  double? prevClose,
  String? symbol,
  String timeRange = '1D',
  bool isCrypto = false,
  bool showRightTitles = false,
  Function(CandleEntity?, double?)? onTrackballChange,
}) {
  // 1️⃣ فحص وجود داتا
  if (candles.isEmpty) {
    return const SizedBox(
      height: 250,
      child: Center(child: Text("No Data Available")),
    );
  }

  final AssetDetailsController controller = Get.find();

  // 2️⃣ تحضير نقاط الشارت
  final spots = candles.asMap().entries.map((entry) {
    if (timeRange == '1W' || timeRange == '5D') {
      return FlSpot(entry.key.toDouble(), entry.value.close);
    } else {
      return FlSpot(
        entry.value.candleTime.millisecondsSinceEpoch.toDouble(),
        entry.value.close,
      );
    }
  }).toList();

  // 3️⃣ حساب حدود السعر (Y-Axis)
  double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
  double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

  // Ensure Prev Close line is visible
  if (timeRange == '1D' && prevClose != null && prevClose != 0) {
    if (prevClose < minY) minY = prevClose;
    if (prevClose > maxY) maxY = prevClose;
  }

  final double yRange = maxY - minY;
  final double yPadding = yRange * 0.1;
  final double adjustedMinY = minY - yPadding;
  final double adjustedMaxY = maxY + yPadding;

  // Calculate dynamic interval
  double yInterval = yRange / 8;
  if (yInterval == 0) yInterval = 1.0;

  double minX;
  double maxX;

  // Check if it's a 24/7 asset
  final isGlobalAsset =
      isCrypto ||
      symbol == 'GOLD' ||
      symbol == 'SILVER' ||
      (symbol?.endsWith('USDT') ?? false) ||
      (symbol?.endsWith('BTC') ?? false) ||
      (symbol?.endsWith('ETH') ?? false);

  if (timeRange == '1D') {
    final baseDate = candles.last.candleTime;

    if (isGlobalAsset) {
      final dayStart = DateTime.utc(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        0,
        0,
      );
      final dayEnd = dayStart.add(const Duration(days: 1));
      minX = dayStart.millisecondsSinceEpoch.toDouble();
      maxX = dayEnd.millisecondsSinceEpoch.toDouble();
    } else {
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
    }
  } else if (timeRange == '1W' || timeRange == '5D') {
    minX = 0;
    maxX = (candles.length - 1).toDouble();
  } else {
    minX = spots.first.x;
    maxX = spots.last.x;
  }

  // 5️⃣ إعداد الألوان من البيانات المرئية فقط
  final visibleCandles = candles.where((candle) {
    if (timeRange == '1W' || timeRange == '5D') return true;
    final candleX = candle.candleTime.millisecondsSinceEpoch.toDouble();
    return candleX >= minX && candleX <= maxX;
  }).toList();

  bool isPositive = true;
  if (visibleCandles.isNotEmpty) {
    final firstVisiblePrice = visibleCandles.first.open;
    final lastVisiblePrice = visibleCandles.last.close;
    isPositive = lastVisiblePrice >= firstVisiblePrice;

    // Throttle debug output
    final now = DateTime.now();
    final shouldPrint =
        _lastPrintTime == null ||
        now.difference(_lastPrintTime!).inSeconds >= 3 ||
        _lastColorState != isPositive;

    if (shouldPrint) {
      print('🎨 Chart Color (VISIBLE CANDLES ONLY):');
      print('   Symbol: $symbol, Range: $timeRange');
      print('   First Visible OPEN: $firstVisiblePrice');
      print('   Last Visible CLOSE: $lastVisiblePrice');
      print('   Trend: ${isPositive ? "🟢 GREEN (UP)" : "🔴 RED (DOWN)"}');
      _lastPrintTime = now;
      _lastColorState = isPositive;
    }
  }

  final Color primaryColor = isPositive ? AppColors.candleGreen : Colors.red;
  final List<Color> gradientColors = [
    primaryColor.withOpacity(0.3),
    primaryColor.withOpacity(0.0),
  ];

  // 6️⃣ دالة تنسيق التواريخ
  String formatDate(DateTime date) {
    if (timeRange == '1D') return DateFormat('HH:mm').format(date);
    if (timeRange == '1W' || timeRange == '5D') {
      return DateFormat('d MMM').format(date);
    }
    if (timeRange == '1M' || timeRange == '3M') {
      return DateFormat('d MMM').format(date);
    }
    return DateFormat('MMM yy').format(date);
  }

  // 7️⃣ توليد 5 تواريخ (Labels)
  final double step = (maxX - minX) / 4;
  final List<Widget> dateWidgets = List.generate(5, (index) {
    final currentVal = minX + (step * index);
    DateTime date;

    if (timeRange == '1W' || timeRange == '5D') {
      int dataIndex = currentVal.round();
      if (dataIndex < 0) dataIndex = 0;
      if (dataIndex >= candles.length) dataIndex = candles.length - 1;
      date = candles[dataIndex].candleTime;
    } else {
      date = DateTime.fromMillisecondsSinceEpoch(
        currentVal.toInt(),
        isUtc: !isGlobalAsset,
      );
    }

    return Text(
      formatDate(date),
      style: TextStyle(
        color: context.onSurface.withOpacity(0.5),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  });

  // 9️⃣ التحقق من حالة السوق للـ Animation
  final isMarketOpen = MarketStatusHelper.isMarketOpen(
    symbol: symbol ?? '',
    isCrypto: isCrypto,
  );

  // Debug print to verify isMarketOpen is strictly boolean
  print(
    '📊 Market Status for $symbol: ${isMarketOpen ? "OPEN" : "CLOSED"} (${isMarketOpen.runtimeType})',
  );

  // 1️⃣0️⃣ بناء الواجهة باستخدام Stateful Widget للـ Animation
  return Column(
    children: [
      Expanded(
        child: _LiveChart(
          key: ValueKey("${symbol}_${timeRange}_$isMarketOpen"),
          spots: spots,
          minX: minX,
          maxX: maxX,
          minY: adjustedMinY,
          maxY: adjustedMaxY,
          primaryColor: primaryColor,
          gradientColors: gradientColors,
          prevClose: prevClose,
          timeRange: timeRange,
          showRightTitles: showRightTitles,
          yInterval: yInterval,
          adjustedMinY: adjustedMinY,
          adjustedMaxY: adjustedMaxY,
          controller: controller,
          onTrackballChange: onTrackballChange,
          candles: candles,
          isMarketOpen: isMarketOpen,
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
}

class _LiveChart extends StatefulWidget {
  final List<FlSpot> spots;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final Color primaryColor;
  final List<Color> gradientColors;
  final double? prevClose;
  final String timeRange;
  final bool showRightTitles;
  final double yInterval;
  final double adjustedMinY;
  final double adjustedMaxY;
  final AssetDetailsController controller;
  final Function(CandleEntity?, double?)? onTrackballChange;
  final List<CandleEntity> candles;
  final bool isMarketOpen;

  const _LiveChart({
    Key? key,
    required this.spots,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.primaryColor,
    required this.gradientColors,
    this.prevClose,
    required this.timeRange,
    required this.showRightTitles,
    required this.yInterval,
    required this.adjustedMinY,
    required this.adjustedMaxY,
    required this.controller,
    this.onTrackballChange,
    required this.candles,
    required this.isMarketOpen,
  }) : super(key: key);

  @override
  State<_LiveChart> createState() => _LiveChartState();
}

class _LiveChartState extends State<_LiveChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 3-second cycle: 1.5s in, 1.5s out
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.isMarketOpen) {
      _animationController.repeat(reverse: true);
    }

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_LiveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMarketOpen != oldWidget.isMarketOpen) {
      if (widget.isMarketOpen) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Listener(
          onPointerUp: (_) {
            widget.controller.selectedSpotX.value = null;
            widget.onTrackballChange?.call(null, null);
          },
          onPointerCancel: (_) {
            widget.controller.selectedSpotX.value = null;
            widget.onTrackballChange?.call(null, null);
          },
          child: Obx(() {
            return LineChart(
              duration: Duration.zero,
              LineChartData(
                minX: widget.minX,
                maxX: widget.maxX,
                minY: widget.minY,
                maxY: widget.maxY,
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: widget.showRightTitles,
                      reservedSize: 48,
                      interval: widget.yInterval,
                      getTitlesWidget: (value, meta) {
                        if ((value - widget.adjustedMinY).abs() < 0.1 ||
                            (value - widget.adjustedMaxY).abs() < 0.1) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            value >= 1000
                                ? value.toStringAsFixed(0)
                                : value.toStringAsFixed(2),
                            style: TextStyle(
                              color: context.onSurface.withOpacity(0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
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
                  touchCallback: (event, response) {
                    final isTouchEnded =
                        event is FlPanEndEvent ||
                        event is FlTapUpEvent ||
                        event is FlLongPressEnd ||
                        event is FlPointerExitEvent ||
                        event is FlTapCancelEvent;

                    if (isTouchEnded) {
                      widget.controller.selectedSpotX.value = null;
                      widget.onTrackballChange?.call(null, null);
                      return;
                    }

                    if (response != null &&
                        response.lineBarSpots != null &&
                        response.lineBarSpots!.isNotEmpty) {
                      final spot = response.lineBarSpots!.first;
                      widget.controller.selectedSpotX.value = spot.x;

                      if (spot.spotIndex >= 0 &&
                          spot.spotIndex < widget.candles.length) {
                        double yPosFromTouch;
                        try {
                          yPosFromTouch = (event as dynamic).localPosition.dx;
                        } catch (e) {
                          yPosFromTouch = spot.x;
                        }
                        widget.onTrackballChange?.call(
                          widget.candles[spot.spotIndex],
                          yPosFromTouch,
                        );
                      }
                    }
                  },
                  getTouchedSpotIndicator: (barData, spotIndexes) {
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
                                strokeColor: widget.primaryColor,
                              ),
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedBarSpots) =>
                        touchedBarSpots.map((barSpot) => null).toList(),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    if (widget.timeRange == '1D' && widget.prevClose != null)
                      HorizontalLine(
                        y: widget.prevClose!,
                        color: Colors.white.withOpacity(0.6),
                        strokeWidth: 1.5,
                        dashArray: [4, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 5, bottom: 5),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          labelResolver: (line) => widget.prevClose! >= 1000
                              ? widget.prevClose!.toStringAsFixed(0)
                              : widget.prevClose!.toStringAsFixed(2),
                        ),
                      ),
                  ],
                  verticalLines: [
                    if (widget.controller.selectedSpotX.value != null)
                      VerticalLine(
                        x: widget.controller.selectedSpotX.value!,
                        color: context.onSurface.withOpacity(0.5),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                  ],
                ),
                clipData: const FlClipData(
                  left: true,
                  right: true,
                  top: false,
                  bottom: false,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: widget.spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: widget.primaryColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    // Pulse animation on the LAST spot, ONLY IF MARKET OPEN
                    dotData: FlDotData(
                      show: widget.isMarketOpen,
                      checkToShowDot: (spot, barData) {
                        return spot.x == widget.spots.last.x;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        // Determine opacity based on animation (0.3 to 0.8)
                        final opacity = 0.3 + (_animation.value * 0.5);
                        // Determine radius based on animation (4.0 to 8.0)
                        final radius = 4.0 + (_animation.value * 4.0);

                        return FlDotCirclePainter(
                          radius: radius,
                          color: widget.primaryColor.withOpacity(opacity),
                          strokeWidth: 0,
                          strokeColor: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
