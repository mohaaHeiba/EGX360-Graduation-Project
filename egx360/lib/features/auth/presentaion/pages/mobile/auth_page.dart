import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/features/auth/presentaion/controller/auth_controller.dart';
import 'package:egx/features/auth/presentaion/pages/web_desktop/auth_desktop_body.dart'; // تأكد من المسار
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/core/custom/background/custom_background.dart';
import 'package:egx/features/auth/presentaion/widgets/login_page.dart';
import 'package:egx/features/auth/presentaion/widgets/register_page.dart';
import 'package:egx/features/auth/presentaion/widgets/forgot_password_page.dart';
import 'package:egx/features/auth/presentaion/widgets/create_new_password_page.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom / 1.4;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: controller.formKey,
        child: ResponsiveLayout(
          mobileBody: Stack(
            children: [
              customBackground(context),

              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.candleGreen.withOpacity(0.2),
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.candleGreen.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: keyboardSpace),
                child: SafeArea(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller.pagecontroller,
                    onPageChanged: controller.onPageChanged,
                    children: const [
                      LoginPage(),
                      RegisterPage(),
                      ForgotPasswordPage(),
                      CreateNewPasswordPage(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- نسخة الويب والديسكوتوب ---
          desktopBody: const AuthDesktopBody(),
        ),
      ),
    );
  }
}
