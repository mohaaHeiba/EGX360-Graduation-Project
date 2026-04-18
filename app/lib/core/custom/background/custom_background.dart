import 'package:egx/core/custom/background/candle_stick/presentation/widgets/candlestick_child_background.dart';
import 'package:egx/core/theme/app_gredients.dart';
import 'package:flutter/material.dart';

Widget customBackground(final context) {
  final gradients = Theme.of(context).extension<AppGradients>()!;

  return Stack(
    children: [
      Container(
        decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: [
          //       Color.fromARGB(255, 0, 0, 0),
          //       Color.fromARGB(255, 0, 0, 0),
          //       Color.fromARGB(255, 5, 5, 7),
          //     ],
          //   ),
          // ),
          gradient: gradients.background,
        ),
      ),

      const Positioned.fill(child: CandlestickChartBackground()),

      // Subtle Gradient Overlay - lighter to show charts
      // Positioned.fill(
      //   child: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         begin: Alignment.bottomCenter,
      //         end: Alignment.topCenter,
      //         colors: [
      //           const Color(0xFF1a1d29).withValues(alpha: 0.1),
      //           const Color(0xFF16181f).withValues(alpha: 0.2),
      //           const Color(0xFF0f1117).withValues(alpha: 0.6),
      //         ],
      //         stops: const [0.0, 0.55, 0.9],
      //       ),
      //     ),
      //   ),
      // ),
    ],
  );
}
