import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/constants/app_images.dart';
import 'package:egx/core/custom/custom_loading.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/custom/text_form_fileds_widget.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/utils/validator.dart';
import 'package:egx/features/auth/presentaion/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

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
              s.welcome_title,
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
              s.welcome_subtitle,
              textAlign: TextAlign.start,
              style: appTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp.clamp(14, 18),
                height: 1.4,
                color: appTheme.onBackground.withOpacity(0.6),
              ),
            ),

            AppGaps.h40,

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

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.goToForgotPass,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  s.forgot_password,
                  style: appTheme.textTheme.bodySmall?.copyWith(
                    color: appTheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: appTheme.primary,
                    fontSize: 13.sp.clamp(11, 15),
                  ),
                ),
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
                    await controller.signIn(
                      email: controller.emailController.text,
                      password: controller.passController.text,
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
                            s.auth_sign_in,
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

            AppGaps.h24,

            // Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: appTheme.onBackground.withOpacity(0.1),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    s.continue_with,
                    style: appTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 14.sp.clamp(12, 16),
                      color: appTheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: appTheme.onBackground.withOpacity(0.1),
                    thickness: 1,
                  ),
                ),
              ],
            ),

            AppGaps.h24,

            // Google Sign-In Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: controller.googleSignIn,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: appTheme.onBackground.withOpacity(0.1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: appTheme.onBackground.withOpacity(0.02),
                ),
                icon: Image.asset(AppImages.logoGoogle, height: 24),
                label: Text(
                  s.sign_google,
                  style: appTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16.sp.clamp(14, 18),
                    fontWeight: FontWeight.w500,
                    color: appTheme.onBackground,
                  ),
                ),
              ),
            ),

            AppGaps.h40,

            // Sign Up Link
            Center(
              child: GestureDetector(
                onTap: controller.goToRegister,
                child: RichText(
                  text: TextSpan(
                    text: "${s.create_account}? ",
                    style: appTheme.textTheme.bodyMedium?.copyWith(
                      color: appTheme.onBackground.withOpacity(0.7),
                      fontSize: 15.sp.clamp(13, 15),
                    ),
                    children: [
                      TextSpan(
                        text: s.auth_sign_up,
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
