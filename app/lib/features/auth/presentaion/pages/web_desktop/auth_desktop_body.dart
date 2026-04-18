import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/features/auth/presentaion/controller/auth_controller.dart';
import 'package:egx/core/custom/background/candle_stick/presentation/painter/InteractiveCandlestickPainter.dart';
import 'package:egx/features/welcome/presentaion/controller/welcome_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:egx/features/auth/presentaion/widgets/login_page.dart';
import 'package:egx/features/auth/presentaion/widgets/register_page.dart';
import 'package:egx/features/auth/presentaion/widgets/forgot_password_page.dart';
import 'package:egx/features/auth/presentaion/widgets/create_new_password_page.dart';

class AuthDesktopBody extends GetView<WelcomeController> {
  const AuthDesktopBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller2 = Get.find<AuthController>();
    return Row(
      children: [
        // left side
        Expanded(flex: 10, child: _buildChartSection()),

        //Right Side
        Expanded(
          flex: 5,
          child: Container(
            color: context.theme.colorScheme.background,

            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller2.pagecontroller,
                  children: const [
                    LoginPage(),
                    RegisterPage(),
                    ForgotPasswordPage(),
                    CreateNewPasswordPage(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
                style: Get.context?.theme.textTheme.headlineLarge?.copyWith(
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
          style: Get.context?.theme.textTheme.headlineMedium?.copyWith(
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
