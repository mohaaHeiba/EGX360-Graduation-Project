import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/custom/custom_loading.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/custom/text_form_fileds_widget.dart';
import 'package:egx/core/utils/validator.dart';
import 'package:egx/features/auth/presentaion/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:egx/core/constants/app_colors.dart';

class CreateNewPasswordPage extends GetView<AuthController> {
  const CreateNewPasswordPage({super.key});

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
            s.create_password_title,
            textAlign: TextAlign.start,
            style: appTheme.textTheme.headlineSmall?.copyWith(
              fontSize: 30.sp.clamp(24, 36),
              fontWeight: FontWeight.bold,
              color: appTheme.onBackground,
            ),
          ),

          AppGaps.h12,

          // 🔹 Description
          Text(
            s.create_password_description,
            textAlign: TextAlign.start,
            style: appTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp.clamp(14, 18),
              height: 1.5,
              color: appTheme.onSurface.withOpacity(0.7),
            ),
          ),

          AppGaps.h40,

          // 🔹 New Password field
          textFieldPasswordWidget(
            controller: controller.passController,
            hint: s.create_password_new,
            icon: Icons.lock_outline,
            isObsure: controller.isPasswordObscure,
            validator: (value) =>
                validator.validatePassword(value ?? '', context),
          ),

          AppGaps.h18,

          // 🔹 Confirm New Password field
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

          AppGaps.h32,

          // 🔹 Submit button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: Obx(
              () => ElevatedButton(
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
                          final newPassword = controller.passController.text
                              .trim();
                          await controller.updatePassword(newPassword);
                        }
                      },
                child: controller.isLoding.value
                    ? CandlestickLoader(
                        width: 40.w.clamp(35, 50),
                        height: 35.h.clamp(30, 45),
                        duration: const Duration(milliseconds: 800),
                      )
                    : Text(
                        s.create_password_update_button,
                        style: appTheme.textTheme.titleMedium?.copyWith(
                          fontSize: 18.sp.clamp(16, 20),
                          fontWeight: FontWeight.w600,
                          color: AppColors.background,
                        ),
                      ),
              ),
            ),
          ),

          AppGaps.h32,

          // 🔹 Back to Login link
          Center(
            child: GestureDetector(
              onTap: controller.goToLogin,
              child: RichText(
                text: TextSpan(
                  text: "${s.create_password_remember} ",
                  style: appTheme.textTheme.bodyMedium?.copyWith(
                    color: appTheme.onSurface.withOpacity(0.7),
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
    );
  }
}
