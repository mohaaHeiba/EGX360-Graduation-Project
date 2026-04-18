import 'package:egx/features/markets/presentation/controllers/markets_controller.dart';
import 'package:egx/features/markets/presentation/widgets/chart_header.dart';
import 'package:egx/features/markets/presentation/widgets/chart_toolbar.dart';
import 'package:egx/features/markets/presentation/widgets/chart_types.dart';
import 'package:egx/features/markets/presentation/widgets/markets_chart_shimmer.dart';
import 'package:flutter/material.dart';

/// Widget to display loading state with shimmer effect
class LoadingStateWidget extends StatelessWidget {
  final MarketsController controller;
  final String selectedTimeframe;
  final List<String> timeframes;
  final ValueChanged<String> onTimeframeSelected;
  final Color gridColor;
  final ChartType chartType;
  final ValueChanged<ChartType> onChartTypeChanged;

  const LoadingStateWidget({
    super.key,
    required this.controller,
    required this.selectedTimeframe,
    required this.timeframes,
    required this.onTimeframeSelected,
    required this.gridColor,
    required this.chartType,
    required this.onChartTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChartHeader(
          price: 0,
          change: 0,
          percent: 0,
          color: gridColor,
          gridColor: gridColor,
          selectedTimeframe: selectedTimeframe,
          timeframes: timeframes,
          onTimeframeSelected: onTimeframeSelected,
          controller: controller,
        ),
        const Expanded(child: MarketsChartShimmer()),
        ChartToolbar(
          selectedTimeframe: selectedTimeframe,
          timeframes: timeframes,
          onTimeframeSelected: onTimeframeSelected,
          isDrawing: false,
          onToggleDrawing: () {},
          onShowDrawingTools: () {},
          selectedLineIndex: null,
          onDeleteLine: () {},
          onShowIndicators: () {},
          chartType: chartType,
          onChartTypeChanged: onChartTypeChanged,
          gridColor: gridColor,
        ),
      ],
    );
  }
}
