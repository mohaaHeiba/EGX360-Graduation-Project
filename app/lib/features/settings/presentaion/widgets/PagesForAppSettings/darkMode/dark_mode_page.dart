import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DarkModePage extends GetView<ThemeController> {
  const DarkModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context;
    final s = context.s;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: customAppbar(Get.back, s.theme),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8.0.w, bottom: 16.h),
                child: Text(
                  s.choose_theme,
                  style: TextStyle(
                    fontSize: 15.sp.clamp(12, 15),
                    color: Colors.grey,
                  ),
                ),
              ),
              Obx(
                () => Row(
                  spacing: 6,
                  children: [
                    _buildThemePreviewBox(
                      controller: controller,
                      label: s.light,
                      imagePath: 'assets/images/lightMode.png',
                      mode: ThemeModeSelection.light,
                      theme: theme,
                    ),
                    AppGaps.w16,
                    _buildThemePreviewBox(
                      controller: controller,
                      label: s.dark,
                      imagePath: 'assets/images/darkMode.png',
                      mode: ThemeModeSelection.dark,
                      theme: theme,
                    ),
                  ],
                ),
              ),
              AppGaps.h32,

              // ===== Use System Theme =====
              Obx(() {
                final bool isSelected =
                    controller.selectedMode.value == ThemeModeSelection.system;
                return InkWell(
                  onTap: () => controller.selectMode(ThemeModeSelection.system),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 14.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.brightness_auto_rounded,
                            color: theme.primary,
                            size: 22.sp.clamp(12, 22),
                          ),
                        ),
                        AppGaps.w14,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.use_system_theme,
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.primary
                                      : theme.textTheme.bodyMedium!.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp.clamp(12, 18),
                                ),
                              ),
                              Text(
                                s.system_theme_description,
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.primary
                                      : theme.textTheme.bodySmall!.color,
                                  fontSize: 12.sp.clamp(10, 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: theme.primary,
                            size: 20.sp.clamp(12, 22),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemePreviewBox({
    required controller,
    required String label,
    required String imagePath,
    required ThemeModeSelection mode,
    required BuildContext theme,
  }) {
    final bool isSelected = controller.selectedMode.value == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectMode(mode),
        child: Column(
          children: [
            Container(
              height: 250.h.clamp(200, 250),
              width: 200.w.clamp(150, 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? theme.primary : Colors.grey[800]!,
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            AppGaps.h12,
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.primary
                    : theme.textTheme.bodySmall!.color,
                fontSize: 16.sp.clamp(12, 18),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
