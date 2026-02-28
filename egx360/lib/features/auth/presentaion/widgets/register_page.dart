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

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context;
    final s = context.s;
    final validator = Validator();

    return SafeArea(
      child: SingleChildScrollView(
        padding: REdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppGaps.h24,
            AppGaps.h24,

            Text(
              s.auth_sign_up,
              textAlign: TextAlign.start,
              style: appTheme.textTheme.headlineSmall?.copyWith(
                fontSize: 32.sp.clamp(24, 36),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: appTheme.onBackground,
              ),
            ),

            AppGaps.h12,

            Text(
              s.register_description,
              textAlign: TextAlign.start,
              style: appTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp.clamp(14, 18),
                height: 1.4,
                color: appTheme.onBackground.withOpacity(0.6),
              ),
            ),

            AppGaps.h40,

            // Full Name field
            textFieldWidget(
              controller: controller.nameController,
              hint: s.name_label,
              icon: Icons.person_outline,
              validator: (value) =>
                  validator.validateName(value ?? '', context),
            ),

            AppGaps.h20,
            // Email field
            textFieldWidget(
              controller: controller.emailController,
              hint: s.email_label,
              icon: Icons.email_outlined,
              inputType: TextInputType.emailAddress,
              validator: (value) =>
                  validator.validateEmail(value ?? '', context),
            ),

            AppGaps.h20,

            // Password field
            textFieldPasswordWidget(
              controller: controller.passController,
              hint: s.password_label,
              icon: Icons.lock_outline,
              isObsure: controller.isPasswordObscure,
              validator: (value) =>
                  validator.validatePassword(value ?? '', context),
            ),

            AppGaps.h20,

            // Confirm Password field
            textFieldPasswordWidget(
              controller: controller.confirmPassController,
              hint: s.confirmPassword,
              icon: Icons.lock_outline,
              isObsure: controller.isConfirmPasswordObscure,
              validator: (value) => validator.validateConfirmPassword(
                controller.passController.text,
                controller.confirmPassController.text,
                context,
              ),
            ),

            AppGaps.h24,

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.primary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (controller.formKey.currentState!.validate()) {
                    controller.isLoding.value = !controller.isLoding.value;
                    await controller.signUp(
                      controller.nameController.text,
                      controller.emailController.text,
                      controller.passController.text,
                    );
                  }
                },
                child: Center(
                  child: Obx(
                    () => controller.isLoding.value
                        ? CandlestickLoader(
                            width: 40.w.clamp(35, 50),
                            height: 35.h.clamp(30, 45),
                            duration: const Duration(milliseconds: 800),
                          )
                        : Text(
                            s.auth_sign_up,
                            style: appTheme.textTheme.titleMedium?.copyWith(
                              fontSize: 18.sp.clamp(16, 20),
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            AppGaps.h40,

            Center(
              child: GestureDetector(
                onTap: controller.goToLogin,
                child: RichText(
                  text: TextSpan(
                    text: "${s.register_have_account} ",
                    style: appTheme.textTheme.bodyMedium?.copyWith(
                      color: appTheme.onBackground.withOpacity(0.7),
                      fontSize: 15.sp.clamp(13, 15),
                    ),
                    children: [
                      TextSpan(
                        text: s.register_login,
                        style: TextStyle(
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
      ),
    );
  }
}
