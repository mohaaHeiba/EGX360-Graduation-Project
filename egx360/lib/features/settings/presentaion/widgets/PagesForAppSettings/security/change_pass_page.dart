import 'package:egx/core/constants/app_gaps.dart';

import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/custom/text_form_fileds_widget.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/utils/validator.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePassPage extends GetView<SettingsController> {
  const ChangePassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: customAppbar(Get.back, s.change_password_title),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppGaps.h40,
              AppGaps.h40,

              // 🔹 Old Password
              textFieldPasswordWidget(
                controller: controller.oldPasswordController,
                hint: s.current_password,
                icon: Icons.lock_outline,
                isObsure: true.obs,
                validator: (value) => Validator().validatePassword(
                  controller.oldPasswordController.text,
                  context,
                ),
              ),
              AppGaps.h18,

              // 🔹 New Password
              textFieldPasswordWidget(
                controller: controller.newPasswordController,
                hint: s.new_password,
                icon: Icons.lock_outline,
                isObsure: true.obs,
                validator: (value) => Validator().validatePassword(
                  controller.newPasswordController.text,
                  context,
                ),
              ),
              AppGaps.h24,

              // 🔹 Change Password Button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.formKey.currentState!.validate()) {
                      if (controller.newPasswordController.text
                              .trim()
                              .isNotEmpty &&
                          controller.oldPasswordController.text
                              .trim()
                              .isNotEmpty) {
                        await controller.changePassword();
                      }
                    }
                  },
                  child: Text(
                    s.update_password,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
