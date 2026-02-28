import 'package:egx/features/welcome/presentaion/controller/welcome_controller.dart';
import 'package:egx/core/custom/background/candle_stick/presentation/painter/candlestick_painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CandlestickChartBackground extends GetView<WelcomeController> {
  final double? cursorX;
  final double? cursorY;
  final bool showCrosshair;

  const CandlestickChartBackground({
    super.key,
    this.cursorX,
    this.cursorY,
    this.showCrosshair = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.controllerAnimation,
      builder: (context, child) {
        return SizedBox.expand(
          child: CustomPaint(
            painter: CandlestickPainter(
              candlesticks: controller.candlesticks,
              animationValue: controller.controllerAnimation.value,
            ),
          ),
        );
      },
    );
  }
}
