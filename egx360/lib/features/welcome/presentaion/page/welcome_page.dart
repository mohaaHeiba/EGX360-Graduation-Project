import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/custom/background/candle_stick/presentation/widgets/candlestick_child_background.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/welcome/presentaion/controller/welcome_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:egx/core/constants/app_colors.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final S = context.s;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CandlestickChartBackground()),

          Positioned(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.candleGreen.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.candleGreen.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: context.width > 600 ? 400 : double.infinity,
              padding: REdgeInsets.symmetric(horizontal: 28.h),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppGaps.h40,
                  AppGaps.h24,

                  FadeTransition(
                    opacity: controller.fadeAnimation,
                    child: SlideTransition(
                      position: controller.slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            "EGX360",
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 52.sp.clamp(30, 52),
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          AppGaps.h8,
                          Text(
                            "Egyptian Stock Exchange",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 18.sp.clamp(14, 18),
                              color: AppColors.primary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56.h.clamp(48, 56),
                          child: ElevatedButton(
                            onPressed: () => controller.goAuth(),
                            child: Text(
                              S.get_started,
                              style: TextStyle(
                                fontSize: 18.sp.clamp(16, 18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        AppGaps.h24,
                        Text(
                          S.policy_agreement,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp.clamp(10, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppGaps.h40,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
