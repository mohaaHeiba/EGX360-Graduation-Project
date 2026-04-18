// import 'package:egx/core/helper/context_extensions.dart';
// import 'package:egx/features/markets/presentation/widgets/chart_types.dart';
// import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart';

// /// Widget to display chart type selection in a bottom sheet
// class ChartTypeMenuWidget extends StatelessWidget {
//   final ChartType selectedType;
//   final ValueChanged<ChartType> onTypeSelected;

//   const ChartTypeMenuWidget({
//     super.key,
//     required this.selectedType,
//     required this.onTypeSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             children: [
//               Icon(LucideIcons.barChart2, color: context.primary, size: 24),
//               const SizedBox(width: 12),
//               Text(
//                 context.s.chart_type_menu_title,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: context.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // Chart Type Grid
//           GridView.count(
//             crossAxisCount: 2,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             mainAxisSpacing: 12,
//             crossAxisSpacing: 12,
//             childAspectRatio: 2.5,
//             children: [
//               _buildChartTypeItem(
//                 context,
//                 ChartType.candle,
//                 context.s.chart_type_candles,
//                 LucideIcons.barChart2,
//                 context.s.chart_type_candles_desc,
//               ),
//               _buildChartTypeItem(
//                 context,
//                 ChartType.bar,
//                 context.s.chart_type_bars,
//                 LucideIcons.barChart,
//                 context.s.chart_type_bars_desc,
//               ),
//               _buildChartTypeItem(
//                 context,
//                 ChartType.line,
//                 context.s.chart_type_line,
//                 LucideIcons.lineChart,
//                 context.s.chart_type_line_desc,
//               ),
//               _buildChartTypeItem(
//                 context,
//                 ChartType.heikinAshi,
//                 context.s.chart_type_heikin_ashi,
//                 LucideIcons.candlestickChart,
//                 context.s.chart_type_heikin_ashi_desc,
//               ),
//               _buildChartTypeItem(
//                 context,
//                 ChartType.renko,
//                 context.s.chart_type_renko,
//                 LucideIcons.component,
//                 context.s.chart_type_renko_desc,
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }

//   Widget _buildChartTypeItem(
//     BuildContext context,
//     ChartType type,
//     String label,
//     IconData icon,
//     String description,
//   ) {
//     final isSelected = selectedType == type;
//     return GestureDetector(
//       onTap: () {
//         onTypeSelected(type);
//         Navigator.pop(context);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? context.primary.withOpacity(0.15)
//               : context.surface,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected
//                 ? context.primary
//                 : context.onSurface.withOpacity(0.15),
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? context.primary.withOpacity(0.2)
//                     : context.onSurface.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: isSelected ? context.primary : context.onSurface,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: isSelected
//                           ? FontWeight.bold
//                           : FontWeight.w500,
//                       color: isSelected ? context.primary : context.onSurface,
//                     ),
//                   ),
//                   Text(
//                     description,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: context.onSurface.withOpacity(0.5),
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             if (isSelected)
//               Icon(Icons.check_circle, color: context.primary, size: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
