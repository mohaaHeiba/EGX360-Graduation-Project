import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/features/markets/presentation/controllers/seasonals_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SeasonalsChart extends StatefulWidget {
  final VoidCallback? onMoreTap;

  const SeasonalsChart({Key? key, this.onMoreTap}) : super(key: key);

  @override
  State<SeasonalsChart> createState() => _SeasonalsChartState();
}

class _SeasonalsChartState extends State<SeasonalsChart> {
  final SeasonalsController controller = Get.put(SeasonalsController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Seasonals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.onMoreTap != null)
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
                    onPressed: widget.onMoreTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Displays a symbol's value movements over previous years to identify recurring trends.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[400],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        // Chart Area
        Obx(() {
          if (controller.isLoading.value) {
            return const SizedBox(
              height: 250,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return SizedBox(
              height: 250,
              child: Center(
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            );
          }

          if (controller.seasonalsSeries.isEmpty) {
            return SizedBox(
              height: 250,
              child: Center(
                child: Text(
                  "No seasonal data available.",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            );
          }

          return SizedBox(
            height: 300,
            child: SfCartesianChart(
              margin: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
              plotAreaBorderWidth: 0,
              
              // X-Axis (Months)
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat.MMM(),
                intervalType: DateTimeIntervalType.months,
                interval: 2, // Jan, Mar, May, Jul, Sep, Nov
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Colors.white.withOpacity(0.1),
                  dashArray: const [5, 5],
                ),
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
                minimum: DateTime(2024, 1, 1),
                maximum: DateTime(2024, 12, 31),
              ),

              // Y-Axis (Percentage)
              primaryYAxis: NumericAxis(
                opposedPosition: true, // Labels on the right side
                labelFormat: '{value}%',
                majorGridLines: const MajorGridLines(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
                plotBands: [
                  // Plot band for the 0.00% reference line
                  PlotBand(
                    start: 0,
                    end: 0,
                    borderColor: Colors.white.withOpacity(0.3),
                    borderWidth: 1.5,
                  ),
                ],
              ),
              
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: const TextStyle(color: Colors.white, fontSize: 13),
              ),

              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'series.name : point.y%', // Shows "2026 : -3.89%"
                header: '',
                canShowMarker: true,
              ),

              series: _buildSeries(controller.seasonalsSeries),
            ),
          );
        }),
      ],
    );
  }

  List<CartesianSeries<SeasonalityDataPoint, DateTime>> _buildSeries(List<SeasonalitySeries> seriesData) {
    List<CartesianSeries<SeasonalityDataPoint, DateTime>> chartSeries = [];

    // The series Data has years descending. Sort them ascending to draw older years first
    final sortedSeries = List<SeasonalitySeries>.from(seriesData)
      ..sort((a, b) => a.year.compareTo(b.year)); // e.g., 2024, 2025, 2026

    for (int i = 0; i < sortedSeries.length; i++) {
      final s = sortedSeries[i];
      
      // Calculate color based on how new the year is
      // i = length - 1 is the NEWEST year (e.g., 2026) -> Blue
      // i = length - 2 is the PREVIOUS year (e.g., 2025) -> Green
      // i = length - 3 is the OLDEST year (e.g., 2024) -> Orange
      Color color = Colors.grey; 
      int distanceFromNewest = (sortedSeries.length - 1) - i;
      
      if (distanceFromNewest == 0) {
        color = Colors.blueAccent;
      } else if (distanceFromNewest == 1) {
        color = Colors.greenAccent;
      } else if (distanceFromNewest == 2) {
        color = Colors.orangeAccent;
      } else {
        color = Colors.purpleAccent; // Fallback for 4th year if any
      }
      
      chartSeries.add(
        FastLineSeries<SeasonalityDataPoint, DateTime>(
          name: '${s.year}',
          dataSource: s.dataPoints,
          xValueMapper: (SeasonalityDataPoint point, _) => point.date,
          yValueMapper: (SeasonalityDataPoint point, _) => point.percentageReturn,
          color: color,
          width: 2.5, // slightly thicker for better visibility
          animationDuration: 1500,
          // Removed markerSettings to make lines smooth and linear
          // Removed dataLabelSettings because we now use a clean Legend
        ),
      );
    }
    return chartSeries;
  }
}
