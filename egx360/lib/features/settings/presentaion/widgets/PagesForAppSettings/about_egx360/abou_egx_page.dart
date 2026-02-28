import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/about_egx360/portfolio_web_view_page.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/about_egx360/show_license_page.dart';
import 'package:egx/features/settings/presentaion/widgets/app_settings_widgets/modern_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:egx/core/constants/app_gaps.dart';

class AboutEGXPage extends StatelessWidget {
  const AboutEGXPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context;
    final s = context.s;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: customAppbar(Get.back, s.about_egx),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSettingsSection(
              title: s.about_section,
              items: [
                SettingItem(
                  icon: LucideIcons.info,
                  title: s.about_egx360,
                  subtitle: s.about_egx360_description,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PortfolioWebViewPage(
                          url: 'https://mohamed-heiba-portfolio.vercel.app/',
                        ),
                      ),
                    );
                  },
                ),
                SettingItem(
                  icon: LucideIcons.user,
                  title: s.about_developer,
                  subtitle: s.about_developer_description,
                  onTap: () {
                    Get.to(
                      () => const PortfolioWebViewPage(
                        url: 'https://mohamed-heiba-portfolio.vercel.app/',
                      ),
                      transition: Transition.rightToLeft,
                    );
                  },
                ),
              ],
            ),
            AppGaps.h24,

            ModernSettingsSection(
              title: s.app_details_section,
              items: [
                SettingItem(
                  icon: LucideIcons.accessibility,
                  title: s.app_version,
                  subtitle: s.app_version_number,
                ),
                SettingItem(
                  icon: LucideIcons.badgeInfo,
                  title: s.licenses,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LicensesPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
