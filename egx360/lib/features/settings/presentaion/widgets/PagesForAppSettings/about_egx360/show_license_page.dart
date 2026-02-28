import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:flutter/foundation.dart' show LicenseParagraph;
import 'package:flutter/material.dart';
import 'package:egx/core/custom/custom_appbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart' show LucideIcons;

class LicensesPage extends GetView<SettingsController> {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context;
    final s = context.s;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: customAppbar(() => Get.back(), s.licenses),
      body: FutureBuilder<LicenseData>(
        future: controller.loadLicenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: theme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "${s.error_loading_licenses}: ${snapshot.error}",
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          final data = snapshot.data!;
          final packages = data.packages.keys.toList();

          return ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              Icon(LucideIcons.barChart, size: 50, color: theme.primary),
              AppGaps.h12,
              Text(
                s.egx360_app_name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge!.color,
                  fontSize: 22.sp.clamp(18, 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppGaps.h4,
              Text(
                s.version_number,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textTheme.bodyMedium!.color),
              ),
              AppGaps.h16,
              Text(
                s.copyright_notice,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium!.color,
                  fontSize: 13.sp.clamp(10, 13),
                ),
              ),
              AppGaps.h32,
              Text(
                s.open_source_licenses,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge!.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp.clamp(15, 18),
                ),
              ),
              AppGaps.h12,

              // ===== Packages list =====
              Container(
                decoration: BoxDecoration(
                  color: theme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8.r,
                      offset: Offset(0, 3.r),
                    ),
                  ],
                ),
                child: Column(
                  children: packages.asMap().entries.map((entry) {
                    final pkg = entry.value;
                    final isLast = entry.key == packages.length - 1;

                    return InkWell(
                      borderRadius: isLast
                          ? BorderRadius.vertical(bottom: Radius.circular(12.r))
                          : BorderRadius.zero,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LicenseDetailsPage(
                              package: pkg,
                              paragraphs: data.packages[pkg]!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          border: !isLast
                              ? Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[850]!,
                                    width: 0.7.w,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                pkg,
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge!.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp.clamp(12, 15),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: theme.textTheme.bodySmall!.color
                                  ?.withValues(alpha: 0.5),
                              size: 16.sp.clamp(12, 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LicenseDetailsPage extends StatelessWidget {
  final String package;
  final List<LicenseParagraph> paragraphs;

  const LicenseDetailsPage({
    super.key,
    required this.package,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppbar(() => Get.back(), package),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: paragraphs.map((p) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Text(
              p.text,
              style: TextStyle(
                color: theme.textTheme.bodyMedium!.color,
                fontSize: 14.sp.clamp(12, 16),
                height: 1.4,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class LicenseData {
  final Map<String, List<LicenseParagraph>> packages;
  LicenseData(this.packages);
}
