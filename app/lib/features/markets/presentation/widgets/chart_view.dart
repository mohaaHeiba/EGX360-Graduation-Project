import 'dart:math';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/markets/presentation/controllers/markets_controller.dart';
import 'package:egx/features/markets/presentation/widgets/countdown_timer.dart';
import 'package:egx/features/markets/presentation/widgets/trade_button_widget.dart';
import 'package:egx/features/markets/presentation/widgets/position_details_sheet.dart';
import 'package:egx/features/markets/presentation/utils/chart_calculations.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:egx/features/markets/presentation/widgets/chart_types.dart';
import 'package:egx/features/markets/presentation/widgets/indicators_menu_widget.dart';

class ChartData {
  final int index;
  final DateTime
  x; // Keeping 'x' as DateTime for date reference, but using 'index' for plotting
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  ChartData({
    required this.index,
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}

class TrendLine {
  CartesianChartPoint start;
  CartesianChartPoint end;
  final DrawingTool type;
  Color color;
  double strokeWidth;

  TrendLine(
    this.start,
    this.end,
    this.type, {
    this.color = const Color(0xFF2196F3), // Default blue
    this.strokeWidth = 2.0,
  });

  TrendLine copyWith({
    CartesianChartPoint? start,
    CartesianChartPoint? end,
    DrawingTool? type,
    Color? color,
    double? strokeWidth,
  }) {
    return TrendLine(
      start ?? this.start,
      end ?? this.end,
      type ?? this.type,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}

class ChartView extends StatelessWidget {
  final MarketsController controller;
  final String selectedTimeframe;
  final DateFormat? dynamicDateFormat;
  final ChartType chartType;
  final IndicatorConfig smaConfig;
  final IndicatorConfig emaConfig;
  final IndicatorConfig bollingerConfig;
  final IndicatorConfig rsiConfig;
  final bool showVolume;
  final bool isDrawing;
  final List<TrendLine> trendLines;
  final Offset? startPoint;
  final Offset? endPoint;
  final int? selectedLineIndex;
  final DrawingTool selectedTool;
  final Color drawingColor;
  final double drawingStrokeWidth;
  final TrackballBehavior trackballBehavior;
  final ZoomPanBehavior zoomPanBehavior;
  final Function(ActualRangeChangedArgs) onActualRangeChanged;
  final Function(ChartTouchInteractionArgs) onChartTouchInteractionDown;
  final Function(ChartTouchInteractionArgs) onChartTouchInteractionMove;
  final Function(ChartTouchInteractionArgs) onChartTouchInteractionUp;
  final Function(ZoomPanArgs) onZooming;
  final Function(ChartSeriesController) onRendererCreated;
  final ChartSeriesController? seriesController;
  final Color gridColor;
  final DateFormat Function(String) getDateFormat;
  final DateTimeIntervalType Function(String) getIntervalType;
  final List<PlotBand> dayPlotBands;
  final Duration Function(String) getIntervalDuration;
  final Function(BuildContext, {required bool isBuy}) showOrderSheet;

  const ChartView({
    super.key,
    required this.controller,
    required this.selectedTimeframe,
    required this.dynamicDateFormat,
    required this.chartType,
    required this.smaConfig,
    required this.emaConfig,
    required this.bollingerConfig,
    required this.rsiConfig,
    required this.showVolume,
    required this.isDrawing,
    required this.trendLines,
    required this.startPoint,
    required this.endPoint,
    required this.selectedLineIndex,
    required this.selectedTool,
    required this.drawingColor,
    required this.drawingStrokeWidth,
    required this.trackballBehavior,
    required this.zoomPanBehavior,
    required this.onActualRangeChanged,
    required this.onChartTouchInteractionDown,
    required this.onChartTouchInteractionMove,
    required this.onChartTouchInteractionUp,
    required this.onZooming,
    required this.onRendererCreated,
    required this.seriesController,
    required this.gridColor,
    required this.getDateFormat,
    required this.getIntervalType,
    required this.dayPlotBands,
    required this.getIntervalDuration,
    required this.showOrderSheet,
  });

  @override
  Widget build(BuildContext context) {
    // Map controller candles to chart data
    List<ChartData> currentData = [];
    if (controller.candles.isNotEmpty) {
      // PERFORMANCE: Only render most recent 300 candles for smooth scrolling
      final maxCandles = 300;
      final candlesToRender = controller.candles.length > maxCandles
          ? controller.candles.sublist(controller.candles.length - maxCandles)
          : controller.candles;
      var index = 0;
      currentData = candlesToRender
          .map(
            (e) => ChartData(
              index: index++,
              x: e.candleTime,
              open: e.open,
              high: e.high,
              low: e.low,
              close: e.close,
              volume: e.volume.toDouble(),
            ),
          )
          .toList();
    }

    // --- Transform Data based on ChartType ---
    List<ChartData> chartData = [];

    if (currentData.isNotEmpty) {
      if (chartType == ChartType.heikinAshi) {
        chartData = ChartCalculations.calculateHeikinAshi(currentData);
      } else if (chartType == ChartType.renko) {
        chartData = ChartCalculations.calculateRenko(currentData);
      } else {
        chartData = currentData;
      }
    }

    if (chartData.isEmpty) {
      return Center(
        child: Text("No Data", style: TextStyle(color: context.onSurface)),
      );
    }

    final lastCandle = chartData.last;
    final priceChange = lastCandle.close - chartData.first.open;
    final isPositive = priceChange >= 0;
    final color = isPositive ? AppColors.candleGreen : AppColors.candleRed;
    final rawMaxVolume = chartData.map((e) => e.volume).reduce(max);
    // Ensure maxVolume is at least 1.0 to prevent 0-range axis crashes
    final maxVolume = rawMaxVolume <= 0 ? 1.0 : rawMaxVolume;

    // Generate Day Separator PlotBands
    // Removed as per user request (was causing unwanted vertical lines)

    return Stack(
      children: [
        // Chart
        SfCartesianChart(
          key: ValueKey(
            '${controller.selectedStock.value?.symbol}_$selectedTimeframe',
          ),
          enableSideBySideSeriesPlacement: false,
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          margin: const EdgeInsets.fromLTRB(0, 10, 8, 0),
          zoomPanBehavior: isDrawing ? null : zoomPanBehavior,
          trackballBehavior: isDrawing
              ? null
              : TrackballBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                  lineType: TrackballLineType.vertical,
                  tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                  builder: (BuildContext context, TrackballDetails details) {
                    final info = details.groupingModeInfo;
                    if (info == null || info.points.isEmpty) return Container();

                    // We need to find the data point index.
                    // Since it's a NumericAxis (index-based), x is the index.
                    final pointInfo = info.points.first;
                    final index = (pointInfo.x as num).toInt();

                    if (index < 0 || index >= chartData.length) {
                      return Container();
                    }

                    final data = chartData[index];
                    final dateStr = DateFormat('MMM dd, HH:mm').format(data.x);

                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: context.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: context.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildTooltipRow(context, 'O', data.open),
                          _buildTooltipRow(context, 'H', data.high),
                          _buildTooltipRow(context, 'L', data.low),
                          _buildTooltipRow(context, 'C', data.close),
                        ],
                      ),
                    );
                  },
                ),
          onActualRangeChanged: onActualRangeChanged,
          onChartTouchInteractionDown: onChartTouchInteractionDown,
          onChartTouchInteractionMove: onChartTouchInteractionMove,
          onChartTouchInteractionUp: onChartTouchInteractionUp,
          onZooming: onZooming,

          // X-Axis
          // X-Axis (Discrete Index-based)
          primaryXAxis: NumericAxis(
            name: 'primaryXAxis', // <--- ضيف السطر ده ضروري جداً
            majorGridLines: MajorGridLines(width: 0.5, color: gridColor),
            axisLine: const AxisLine(width: 0),

            majorTickLines: const MajorTickLines(size: 0),
            rangePadding: ChartRangePadding.none,
            edgeLabelPlacement: EdgeLabelPlacement.shift,

            // Initial View: Show last 50 candles
            initialVisibleMinimum: chartData.length > 50
                ? (chartData.length - 50).toDouble()
                : 0,
            initialVisibleMaximum: chartData.length > 1
                ? (chartData.length - 1 + 10)
                      .toDouble() // +10 empty space
                : (chartData.length - 1).toDouble(),

            // Max allowed scroll forward
            maximum: chartData.length > 1
                ? (chartData.length - 1 + 50).toDouble()
                : null,

            // Custom Label Formatter: Index -> Date
            axisLabelFormatter: (AxisLabelRenderDetails details) {
              final index = details.value.toInt();
              if (index >= 0 && index < chartData.length) {
                final date = chartData[index].x;
                String label = '';

                // Show Date if it's the first point or if day changed from previous point
                bool showDate = false;
                if (index == 0) {
                  showDate = true;
                } else {
                  final prevDate = chartData[index - 1].x;
                  if (date.day != prevDate.day ||
                      date.month != prevDate.month) {
                    showDate = true;
                  }
                }

                if (showDate &&
                    selectedTimeframe != '1D' &&
                    selectedTimeframe != '1W' &&
                    selectedTimeframe != '1M') {
                  label = DateFormat('MM/dd HH:mm').format(date);
                } else {
                  final dateFormat =
                      dynamicDateFormat ?? getDateFormat(selectedTimeframe);
                  label = dateFormat.format(date);
                }

                return ChartAxisLabel(label, details.textStyle);
              }
              return ChartAxisLabel('', details.textStyle);
            },
          ),
          // Y-Axis
          primaryYAxis: NumericAxis(
            name: 'yAxis',
            opposedPosition: true,
            anchorRangeToVisiblePoints: false,
            rangePadding: ChartRangePadding.additional,
            plotOffset: 20,
            majorGridLines: MajorGridLines(width: 0.5, color: gridColor),
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            labelStyle: TextStyle(
              color: context.onSurface.withValues(alpha: 0.5),
              fontSize: 10,
            ),
            numberFormat: NumberFormat('0.000'),
          ),
          axes: <ChartAxis>[
            NumericAxis(
              name: 'VolumeAxis',
              isVisible: false,
              maximum: maxVolume * 6,
            ),
          ],
          indicators: <TechnicalIndicator>[
            if (smaConfig.enabled)
              SmaIndicator<ChartData, dynamic>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.index,
                valueField: 'close',
                closeValueMapper: (ChartData data, _) => data.close,
                period: smaConfig.period,
                signalLineColor: Colors.orange,
              ),
            if (emaConfig.enabled)
              EmaIndicator<ChartData, dynamic>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.index,
                valueField: 'close',
                closeValueMapper: (ChartData data, _) => data.close,
                period: emaConfig.period,
                signalLineColor: Colors.blue,
              ),
            if (bollingerConfig.enabled)
              BollingerBandIndicator<ChartData, dynamic>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.index,
                closeValueMapper: (ChartData data, _) => data.close,
                period: bollingerConfig.period,
                standardDeviation: bollingerConfig.standardDeviation ?? 2,
              ),
            if (rsiConfig.enabled)
              RsiIndicator<ChartData, dynamic>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.index,
                closeValueMapper: (ChartData data, _) => data.close,
                highValueMapper: (ChartData data, _) => data.high,
                lowValueMapper: (ChartData data, _) => data.low,
                period: rsiConfig.period,
                signalLineColor: Colors.purple,
              ),
          ],
          series: <CartesianSeries>[
            if (chartType == ChartType.candle ||
                chartType == ChartType.heikinAshi ||
                chartType == ChartType.renko)
              CandleSeries<ChartData, num>(
                onRendererCreated: onRendererCreated,
                name: 'Primary',
                spacing: chartType == ChartType.renko ? 0 : 0.1,
                width: chartType == ChartType.renko ? 0.9 : 0.8,
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.index,
                lowValueMapper: (ChartData data, _) => data.low,
                highValueMapper: (ChartData data, _) => data.high,
                openValueMapper: (ChartData data, _) => data.open,
                closeValueMapper: (ChartData data, _) => data.close,
                bearColor: AppColors.candleRed,
                bullColor: AppColors.candleGreen,
                enableSolidCandles: true,
                animationDuration: 0,
              )
            else if (chartType == ChartType.bar)
              HiloOpenCloseSeries<ChartData, num>(
                onRendererCreated: onRendererCreated,
                name: 'Primary',
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.index,
                lowValueMapper: (ChartData data, _) => data.low,
                highValueMapper: (ChartData data, _) => data.high,
                openValueMapper: (ChartData data, _) => data.open,
                closeValueMapper: (ChartData data, _) => data.close,
                bearColor: AppColors.candleRed,
                bullColor: AppColors.candleGreen,
                animationDuration: 0,
              )
            else
              AreaSeries<ChartData, num>(
                onRendererCreated: onRendererCreated,
                name: 'Primary',
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.index,
                yValueMapper: (ChartData data, _) => data.close,
                borderColor: color,
                borderWidth: 2,
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                animationDuration: 0,
                // Remove gaps - only show data where it exists
                emptyPointSettings: EmptyPointSettings(
                  mode: EmptyPointMode.drop,
                ),
              ),
            if (showVolume)
              ColumnSeries<ChartData, num>(
                dataSource: chartData,
                spacing: 0.1,
                width: 0.8,
                xValueMapper: (ChartData data, _) => data.index,
                yValueMapper: (ChartData data, _) => data.volume,
                yAxisName: 'VolumeAxis',
                pointColorMapper: (ChartData data, _) => data.close >= data.open
                    ? AppColors.candleGreen.withValues(alpha: 0.5)
                    : AppColors.candleRed.withValues(alpha: 0.5),
                animationDuration: 0,
                // Remove gaps - only show volume bars where data exists
                emptyPointSettings: EmptyPointSettings(
                  mode: EmptyPointMode.drop,
                ),
              ),
          ],
        ),

        // Drawing Overlay
        if (seriesController != null)
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: TrendLinePainter(
                trendLines: trendLines,
                startPoint: startPoint,
                endPoint: endPoint,
                controller: seriesController!,
                currentColor: drawingColor,
                currentStrokeWidth: drawingStrokeWidth,
                selectedLineIndex: selectedLineIndex,
                currentTool: selectedTool,
              ),
            ),
          ),

        // Overlay Buttons (Buy/Sell)
        Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: [
              TradeButtonWidget(
                label: "SELL",
                price: lastCandle.close,
                color: AppColors.candleRed,
                onPressed: () => showOrderSheet(context, isBuy: false),
              ),
              const SizedBox(width: 10),
              TradeButtonWidget(
                label: "BUY",
                price: lastCandle.close + 0.440,
                color: context.primary,
                onPressed: () => showOrderSheet(context, isBuy: true),
              ),
            ],
          ),
        ),

        // TradingView Logo or P&L (Bottom Left)
        Positioned(
          bottom: 10,
          left: 20,
          child: Obx(() {
            // Check if held in simulation
            SimulationController? simController;
            try {
              simController = Get.find<SimulationController>();
            } catch (_) {}

            final holding = simController?.holdings.firstWhereOrNull(
              (h) => h.symbol == controller.selectedStock.value?.symbol,
            );

            // If held, show P&L %
            if (holding != null) {
              // Calculate P&L %
              final currentPrice = controller.candles.isNotEmpty
                  ? controller.candles.last.close
                  : (simController?.currentPrices[holding.symbol] ??
                        holding.averagePrice);
              final costBasis = holding.quantity * holding.averagePrice;
              final currentValue = holding.quantity * currentPrice;
              final profitLoss = currentValue - costBasis;
              final plPercent = costBasis == 0
                  ? 0.0
                  : (profitLoss / costBasis) * 100;
              final isPositive = profitLoss >= 0;

              return GestureDetector(
                onTap: () => PositionDetailsSheet.show(
                  context,
                  holding: holding,
                  currentPrice: currentPrice,
                  isPositive: isPositive,
                  profitLoss: profitLoss,
                  plPercent: plPercent,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(
                      0.2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (isPositive ? Colors.green : Colors.red)
                          .withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_drop_up_rounded
                            : Icons.arrow_drop_down_rounded,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      Text(
                        '${plPercent.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Otherwise show Logo (Placeholder)
            return Opacity(
              opacity: 0.5,
              child: Row(
                children: [
                  Icon(Icons.show_chart, color: context.onSurface, size: 24),
                ],
              ),
            );
          }),
        ),
        // Countdown Timer (Bottom Right)
        Positioned(
          bottom: 10,
          right: 60,
          child: Obx(() {
            // Hide timer if no close time OR if EGX market is closed
            if (controller.nextCloseTime.value == null) {
              return const SizedBox.shrink();
            }
            if (controller.isEgxStock && !controller.isMarketOpen) {
              return const SizedBox.shrink();
            }
            return CountdownTimer(targetTime: controller.nextCloseTime.value!);
          }),
        ),
      ],
    );
  }

  Widget _buildTooltipRow(BuildContext context, String label, double value) {
    return Text(
      '$label: ${value.toStringAsFixed(2)}',
      style: TextStyle(
        color: context.onSurface,
        fontSize: 10,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class TrendLinePainter extends CustomPainter {
  final List<TrendLine> trendLines;
  final Offset? startPoint;
  final Offset? endPoint;
  final ChartSeriesController controller;
  final Color currentColor; // For new drawings
  final double currentStrokeWidth; // For new drawings
  final int? selectedLineIndex;
  final DrawingTool? currentTool;

  TrendLinePainter({
    required this.trendLines,
    required this.startPoint,
    required this.endPoint,
    required this.controller,
    required this.currentColor,
    required this.currentStrokeWidth,
    this.selectedLineIndex,
    this.currentTool,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw committed trend lines
    for (int i = 0; i < trendLines.length; i++) {
      final line = trendLines[i];
      final startOffset = controller.pointToPixel(line.start);
      final endOffset = controller.pointToPixel(line.end);

      final isSelected = i == selectedLineIndex;

      // Use line's own color and strokeWidth
      final linePaint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..style = PaintingStyle.stroke;

      // Selection highlight paint (draw thicker semi-transparent line behind)
      if (isSelected) {
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..strokeWidth = line.strokeWidth + 6
          ..style = PaintingStyle.stroke;

        _drawLineByType(
          canvas,
          size,
          line.type,
          startOffset,
          endOffset,
          highlightPaint,
        );
      }

      _drawLineByType(
        canvas,
        size,
        line.type,
        startOffset,
        endOffset,
        linePaint,
      );

      // Draw selection handles if selected
      if (isSelected) {
        _drawSelectionHandles(canvas, startOffset, endOffset, line.type);
      }
    }

    // Draw current line being drawn
    if (startPoint != null && endPoint != null && currentTool != null) {
      final paint = Paint()
        ..color = currentColor
        ..strokeWidth = currentStrokeWidth
        ..style = PaintingStyle.stroke;

      if (currentTool == DrawingTool.horizontalLine) {
        canvas.drawLine(
          Offset(0, startPoint!.dy),
          Offset(size.width, startPoint!.dy),
          paint,
        );
      } else if (currentTool == DrawingTool.verticalLine) {
        canvas.drawLine(
          Offset(startPoint!.dx, 0),
          Offset(startPoint!.dx, size.height),
          paint,
        );
      } else if (currentTool == DrawingTool.rectangle) {
        final rect = Rect.fromPoints(startPoint!, endPoint!);
        canvas.drawRect(
          rect,
          Paint()
            ..color = paint.color.withOpacity(0.1)
            ..style = PaintingStyle.fill,
        );
        canvas.drawRect(rect, paint);
      } else {
        canvas.drawLine(startPoint!, endPoint!, paint);
      }
    }
  }

  void _drawLineByType(
    Canvas canvas,
    Size size,
    DrawingTool type,
    Offset startOffset,
    Offset endOffset,
    Paint paint,
  ) {
    if (type == DrawingTool.horizontalLine) {
      canvas.drawLine(
        Offset(0, startOffset.dy),
        Offset(size.width, startOffset.dy),
        paint,
      );
    } else if (type == DrawingTool.verticalLine) {
      canvas.drawLine(
        Offset(startOffset.dx, 0),
        Offset(startOffset.dx, size.height),
        paint,
      );
    } else if (type == DrawingTool.rectangle) {
      final rect = Rect.fromPoints(startOffset, endOffset);
      // Draw fill for rectangle
      if (paint.style == PaintingStyle.stroke) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = paint.color.withOpacity(0.1)
            ..style = PaintingStyle.fill,
        );
      }
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  void _drawSelectionHandles(
    Canvas canvas,
    Offset start,
    Offset end,
    DrawingTool type,
  ) {
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final handleBorderPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const handleRadius = 6.0;

    void drawHandle(Offset center) {
      canvas.drawCircle(center, handleRadius, handlePaint);
      canvas.drawCircle(center, handleRadius, handleBorderPaint);
    }

    if (type == DrawingTool.horizontalLine) {
      drawHandle(Offset(start.dx, start.dy));
      drawHandle(Offset(end.dx, start.dy));
    } else if (type == DrawingTool.verticalLine) {
      drawHandle(Offset(start.dx, start.dy));
      drawHandle(Offset(start.dx, end.dy));
    } else {
      drawHandle(start);
      drawHandle(end);
    }
  }

  @override
  bool shouldRepaint(covariant TrendLinePainter oldDelegate) {
    return oldDelegate.trendLines != trendLines ||
        oldDelegate.startPoint != startPoint ||
        oldDelegate.endPoint != endPoint ||
        oldDelegate.currentColor != currentColor ||
        oldDelegate.currentStrokeWidth != currentStrokeWidth ||
        oldDelegate.selectedLineIndex != selectedLineIndex ||
        oldDelegate.currentTool != currentTool;
  }
}
