import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/support/data_sources_page.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/support/how_to_use_page.dart';
import 'package:egx/features/settings/presentaion/widgets/app_settings_widgets/modern_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpSupportPage extends StatelessWidget {
  HelpSupportPage({super.key});

  final controller = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppbar(() => Get.back(), s.help_support),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Text(
              s.need_help,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppGaps.h8,
            Text(
              s.need_help_subtitle,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
            ),
            AppGaps.h24,

            // ===== FAQs SECTION =====
            ModernSettingsSection(
              title: s.faqs_section,
              items: [
                SettingItem(
                  title: s.how_to_use_egx360,
                  subtitle: s.how_to_use_subtitle,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HowToUsePage()),
                    );
                  },
                ),
                SettingItem(
                  title: s.data_sources,
                  subtitle: s.data_sources_subtitle,
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DataSourcesPage()),
                    );
                  },
                ),
              ],
            ),

            AppGaps.h24,

            // ===== SUPPORT SECTION =====
            ModernSettingsSection(
              title: s.support_section,
              items: [
                SettingItem(
                  title: s.contact_report,
                  subtitle: s.contact_report_subtitle,
                  onTap: controller.openEmail,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
