// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// /// Seasonals chart showing multi-year monthly performance
// /// Displays 3 years of data with different colored lines
// class SeasonalsChart extends StatelessWidget {
//   final List<double>? data2024;
//   final List<double>? data2025;
//   final List<double>? data2026;
//   final VoidCallback? onMoreTap;

//   const SeasonalsChart({
//     super.key,
//     this.data2024,
//     this.data2025,
//     this.data2026,
//     this.onMoreTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Use mock data if no real data provided
//     final mock2024 = data2024 ?? _generateMockData(seed: 2024, trend: 15);
//     final mock2025 = data2025 ?? _generateMockData(seed: 2025, trend: -5);
//     final mock2026 = data2026 ?? _generateMockData(seed: 2026, trend: 25);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Chart
//         SizedBox(
//           height: 180,
//           child: LineChart(
//             _buildChartData(
//               context,
//               data2024: mock2024,
//               data2025: mock2025,
//               data2026: mock2026,
//             ),
//           ),
//         ),

//         const SizedBox(height: 12),

//         // Legend
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildLegendItem('2026', Colors.orange[600]!),
//             const SizedBox(width: 20),
//             _buildLegendItem('2025', Colors.green[600]!),
//             const SizedBox(width: 20),
//             _buildLegendItem('2024', Colors.blue[600]!),
//           ],
//         ),

//         const SizedBox(height: 16),

//         // More seasonals button
//         if (onMoreTap != null)
//           Center(
//             child: TextButton(
//               onPressed: onMoreTap,
//               style: TextButton.styleFrom(
//                 backgroundColor: Theme.of(context).cardColor.withOpacity(0.5),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text(
//                 'More seasonals',
//                 style: TextStyle(fontSize: 13),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildLegendItem(String label, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 8,
//           height: 8,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 6),
//         Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
//       ],
//     );
//   }

//   LineChartData _buildChartData(
//     BuildContext context, {
//     required List<double> data2024,
//     required List<double> data2025,
//     required List<double> data2026,
//   }) {
//     return LineChartData(
//       gridData: FlGridData(
//         show: true,
//         drawVerticalLine: true,
//         horizontalInterval: 20,
//         verticalInterval: 3,
//         getDrawingHorizontalLine: (value) {
//           return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
//         },
//         getDrawingVerticalLine: (value) {
//           return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
//         },
//       ),
//       titlesData: FlTitlesData(
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             interval: 4,
//             getTitlesWidget: (value, meta) {
//               const months = ['Jan', 'May', 'Sep'];
//               final index = value.toInt() ~/ 4;
//               if (index >= 0 && index < months.length) {
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: Text(
//                     months[index],
//                     style: TextStyle(fontSize: 11, color: Colors.grey[400]),
//                   ),
//                 );
//               }
//               return const SizedBox();
//             },
//           ),
//         ),
//         leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       ),
//       borderData: FlBorderData(show: false),
//       minX: 0,
//       maxX: 11,
//       minY: -30,
//       maxY: 40,
//       lineBarsData: [
//         // 2026 line (orange)
//         _buildLineChartBarData(data2026, Colors.orange[600]!),
//         // 2025 line (green)
//         _buildLineChartBarData(data2025, Colors.green[600]!),
//         // 2024 line (blue)
//         _buildLineChartBarData(data2024, Colors.blue[600]!),
//       ],
//       lineTouchData: LineTouchData(
//         enabled: true,
//         touchTooltipData: LineTouchTooltipData(
//           getTooltipColor: (touchedSpot) => Colors.black87,
//           tooltipBorderRadius: BorderRadius.circular(8),
//           getTooltipItems: (touchedSpots) {
//             return touchedSpots.map((spot) {
//               return LineTooltipItem(
//                 '${spot.y.toStringAsFixed(1)}%',
//                 const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               );
//             }).toList();
//           },
//         ),
//       ),
//     );
//   }

//   LineChartBarData _buildLineChartBarData(List<double> data, Color color) {
//     return LineChartBarData(
//       spots: List.generate(
//         data.length,
//         (index) => FlSpot(index.toDouble(), data[index]),
//       ),
//       isCurved: true,
//       color: color,
//       barWidth: 2,
//       isStrokeCapRound: true,
//       dotData: FlDotData(show: false),
//       belowBarData: BarAreaData(show: false),
//     );
//   }

//   // Generate mock seasonal data
//   List<double> _generateMockData({required int seed, required double trend}) {
//     final data = <double>[];
//     double baseValue = 0;

//     for (int i = 0; i < 12; i++) {
//       // Add some variation
//       final variation = ((seed + i) % 10 - 5) * 2.0;
//       final monthlyTrend = (trend / 12) * i;
//       data.add(baseValue + monthlyTrend + variation);
//     }

//     return data;
//   }
// }
