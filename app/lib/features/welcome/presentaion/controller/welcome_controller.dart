import 'dart:math' as math;
import 'package:egx/core/utils/platform_detector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/core/services/permission_service.dart';
import 'package:egx/core/custom/background/candle_stick/domain/entity/candlestick_data.dart';

class WelcomeController extends GetxController
    with GetTickerProviderStateMixin {
  // Animation controllers
  late AnimationController controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Candlestick Animation
  late AnimationController controllerAnimation;
  final List<CandlestickData> candlesticks = [];

  // إعدادات الشموع
  final double candleWidth = PlatformDetector.isMobile ? 7.0 : 15.0;
  final double spacing = 4.0;

  @override
  void onInit() {
    super.onInit();

    int totalCandles = (Get.width / (candleWidth + spacing)).ceil() + 2;

    controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    _generateCandlestickData(totalCandles);

    controllerAnimation = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    controller.forward();
    controllerAnimation.forward();
  }

  void _generateCandlestickData(int count) {
    final random = math.Random();
    double currentPrice = 100.0;

    for (int i = 0; i < count; i++) {
      final change = (random.nextDouble() - 0.45) * 8;
      currentPrice += change;

      final isGreen = random.nextBool();
      final bodySize = 3 + random.nextDouble() * 12;
      final wickTop = 2 + random.nextDouble() * 8;
      final wickBottom = 2 + random.nextDouble() * 8;

      double open, close, high, low;

      if (isGreen) {
        open = currentPrice;
        close = currentPrice + bodySize;
        high = close + wickTop;
        low = open - wickBottom;
      } else {
        open = currentPrice + bodySize;
        close = currentPrice;
        high = open + wickTop;
        low = close - wickBottom;
      }

      candlesticks.add(
        CandlestickData(open: open, close: close, high: high, low: low),
      );

      currentPrice = close;
    }
  }

  @override
  void onClose() {
    controllerAnimation.dispose();
    controller.dispose();
    super.onClose();
  }

  Future<void> goAuth() async {
    PermissionService p = PermissionService();
    // await GetStorage().write('seenWelcome', true);
    await p.requestAll();
    await Get.toNamed(AppPages.authPage);
  }

  var mousePosition = Rxn<Offset>();
  void updateMousePosition(Offset? position) {
    mousePosition.value = position;
  }
}
