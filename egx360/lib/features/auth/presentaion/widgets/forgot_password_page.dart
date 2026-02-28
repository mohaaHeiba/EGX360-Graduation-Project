import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/custom/custom_loading.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/custom/text_form_fileds_widget.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/utils/validator.dart';
import 'package:egx/features/auth/presentaion/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends GetView<AuthController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context;
    final s = context.s;
    final validator = Validator();

    return SingleChildScrollView(
      padding: REdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppGaps.h40,

          // 🔹 Title
          Text(
            s.forgot_password,
            textAlign: TextAlign.start,
            style: appTheme.textTheme.headlineSmall?.copyWith(
              fontSize: 32.sp.clamp(24, 36),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: appTheme.onBackground,
            ),
          ),

          AppGaps.h12,

          // 🔹 Description
          Text(
            s.forgot_description,
            textAlign: TextAlign.start,
            style: appTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp.clamp(14, 18),
              height: 1.5,
              color: appTheme.onSurface.withOpacity(0.7),
            ),
          ),

          AppGaps.h40,

          /// 🔹 Email Field
          textFieldWidget(
            controller: controller.emailController,
            hint: s.email_label,
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
            validator: (value) => validator.validateEmail(value ?? '', context),
          ),

          AppGaps.h32,

          /// 🔹 Send Reset Link Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.primary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: controller.isLoding.value
                    ? null
                    : () async {
                        if (controller.formKey.currentState!.validate()) {
                          controller.isLoding.value = true;
                          await controller.resetPassword();
                          controller.isLoding.value = false;
                        }
                      },
                child: controller.isLoding.value
                    ? CandlestickLoader(
                        width: 40.w.clamp(35, 50),
                        height: 35.h.clamp(30, 45),
                        duration: const Duration(milliseconds: 800),
                      )
                    : Text(
                        s.forgot_send_link,
                        style: appTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.background,
                          fontSize: 18.sp.clamp(16, 20),
                        ),
                      ),
              ),
            ),
          ),

          AppGaps.h32,

          /// 🔹 Back to Login
          Center(
            child: GestureDetector(
              onTap: controller.backfromForgotPass,
              child: RichText(
                text: TextSpan(
                  text: "${s.forgot_remember} ",
                  style: appTheme.textTheme.bodyMedium?.copyWith(
                    color: appTheme.onSurface.withOpacity(0.7),
                    fontSize: 15.sp.clamp(13, 15),
                  ),
                  children: [
                    TextSpan(
                      text: s.register_login,
                      style: appTheme.textTheme.bodyMedium?.copyWith(
                        color: appTheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AppGaps.h24,
        ],
      ),
    );
  }
}
