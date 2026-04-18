import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/custom/background/candle_stick/presentation/painter/InteractiveCandlestickPainter.dart';
import 'package:egx/core/custom/custom_loading.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/custom/background/custom_background.dart';
import 'package:egx/core/utils/responsive_layout.dart' show ResponsiveLayout;
import 'package:egx/features/auth/presentaion/controller/auth_controller.dart';
import 'package:egx/features/welcome/presentaion/controller/welcome_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EmailVerificationPage extends GetView<WelcomeController> {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments;
    final appTheme = context;
    final s = context.s;
    final controller2 = Get.find<AuthController>();

    return ResponsiveLayout(
      mobileBody: Stack(
        children: [
          Positioned.fill(child: customBackground(context)),
          Obx(
            () => SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppGaps.h40,
                    if (controller2.isVerified.value) ...[
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: appTheme.primary,
                        size: 60.r,
                      ),
                      AppGaps.h24,
                      Text(
                        s.email_verified_success,
                        style: appTheme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: appTheme.onBackground,
                        ),
                      ),
                      AppGaps.h12,
                      Text(
                        s.email_verified_message,
                        style: appTheme.textTheme.bodyMedium?.copyWith(
                          color: appTheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ] else ...[
                      Text(
                        s.email_verification_sent(email),
                        textAlign: TextAlign.start,
                        style: appTheme.textTheme.headlineSmall?.copyWith(
                          fontSize: 28.sp.clamp(24, 32),
                          fontWeight: FontWeight.bold,
                          color: appTheme.onBackground,
                        ),
                      ),
                      AppGaps.h12,
                      Text(
                        s.email_verification_message,
                        textAlign: TextAlign.start,
                        style: appTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp.clamp(14, 18),
                          height: 1.5,
                          color: appTheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      AppGaps.h40,
                      Center(
                        child: CandlestickLoader(
                          width: 40.w.clamp(35, 50),
                          height: 35.h.clamp(30, 45),
                          duration: const Duration(milliseconds: 800),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      desktopBody: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Expanded(flex: 10, child: _buildChartSection()),
            Expanded(
              flex: 5,
              child: Obx(
                () => SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppGaps.h40,
                        if (controller2.isVerified.value) ...[
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: appTheme.primary,
                            size: 60.r,
                          ),
                          AppGaps.h24,
                          Text(
                            s.email_verified_success,
                            style: appTheme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: appTheme.onBackground,
                            ),
                          ),
                          AppGaps.h12,
                          Text(
                            s.email_verified_message,
                            style: appTheme.textTheme.bodyMedium?.copyWith(
                              color: appTheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ] else ...[
                          AppGaps.h12,

                          Text(
                            s.email_verification_sent(email['email']),
                            textAlign: TextAlign.start,
                            style: appTheme.textTheme.headlineSmall?.copyWith(
                              fontSize: 28.sp.clamp(24, 32),
                              fontWeight: FontWeight.bold,
                              color: appTheme.onBackground,
                            ),
                          ),
                          AppGaps.h12,
                          Text(
                            s.email_verification_message,
                            textAlign: TextAlign.start,
                            style: appTheme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16.sp.clamp(14, 18),
                              height: 1.5,
                              color: appTheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          AppGaps.h40,

                          AppGaps.h40,
                          Center(
                            child: CandlestickLoader(
                              width: 40.w.clamp(35, 50),
                              height: 35.h.clamp(30, 45),
                              duration: const Duration(milliseconds: 800),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Stack(
      children: [
        Positioned(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // تأكد من أن AppColors معرف لديك
                  AppColors.candleGreen.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  AppColors.candleGreen.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        MouseRegion(
          onHover: (event) =>
              controller.updateMousePosition(event.localPosition),
          onExit: (_) => controller.updateMousePosition(null),
          child: Stack(
            children: [
              SizedBox.expand(
                child: AnimatedBuilder(
                  animation: controller.controllerAnimation,
                  builder: (context, child) {
                    return Obx(
                      () => CustomPaint(
                        painter: InteractiveCandlestickPainter(
                          candlesticks: controller.candlesticks,
                          animationValue: controller.controllerAnimation.value,
                          mousePosition: controller.mousePosition.value,
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildInfoOverlay(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoOverlay() {
    return PositionedDirectional(
      top: 60,
      start: 60,
      child: FadeTransition(
        opacity: controller.fadeAnimation,
        child: SlideTransition(
          position: controller.slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "EGX360 Index",
                style: Get.context?.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.sp.clamp(20, 40),
                ),
              ),
              AppGaps.h12,
              _buildIndexValue(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndexValue() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "28,450.50",
          style: Get.context?.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        AppGaps.w16,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF26a69a).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF26a69a).withOpacity(0.3)),
          ),
          child: const Text(
            "+1.25%",
            style: TextStyle(
              color: Color(0xFF26a69a),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
