import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';

class EditProfilePage extends GetView<SettingsController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final s = context.s;

    final double itemsRadius = 20.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppbar(() => Get.back(), s.edit_profile),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===== Avatar Section =====
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Obx(() {
                    final avatar =
                        controller.currentUser.value?.avatarUrl ?? '';
                    final name = controller.currentUser.value?.name ?? '';

                    return Container(
                      width: 135.w.clamp(100, 135),
                      height: 135.h.clamp(100, 135),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(itemsRadius),
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white10
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                        image: (avatar.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(avatar),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (avatar.isEmpty)
                          ? Text(
                              (name.isNotEmpty) ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    );
                  }),

                  Positioned(
                    bottom: -6,
                    right: -6,
                    child: Container(
                      width: 43.w,
                      height: 43.h,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.edit, color: Colors.black),
                          onPressed: () async {
                            await controller.pickImage();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppGaps.h32,

            // ===== Name Field =====
            _buildField(
              context: context,
              controller: controller.nameController,
              label: s.full_name,
              icon: Icons.person_outline_rounded,
              hint: s.full_name_hint,
            ),
            AppGaps.h20,

            // ===== Bio Field =====
            _buildField(
              context: context,
              controller: controller.bioController,
              label: s.bio,
              icon: Icons.info_outline_rounded,
              hint: s.bio_hint,
              maxLines: 4,
              alignTop: true,
            ),
            AppGaps.h20,

            // ===== Email (read-only) =====
            _buildField(
              context: context,
              controller: controller.emailController,
              label: s.email_address,
              icon: Icons.email_outlined,
              readOnly: true,
            ),
            AppGaps.h40,

            // ===== Save Button =====
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  Get.back();
                  await controller.updateDataUser();
                },
                child: Text(
                  s.save_changes,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool readOnly = false,
    int maxLines = 1,
    bool alignTop = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      textAlignVertical: alignTop
          ? TextAlignVertical.top
          : TextAlignVertical.center,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: readOnly
            ? theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6)
            : theme.textTheme.bodyLarge?.color,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
          child: Icon(icon, color: readOnly ? Colors.grey : AppColors.primary),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        labelText: label,
        labelStyle: TextStyle(
          color: readOnly ? Colors.grey : AppColors.textSecondary,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textFaint.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: readOnly
            ? (isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1))
            : (isDarkMode ? const Color(0xFF1F222A) : Colors.white),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
