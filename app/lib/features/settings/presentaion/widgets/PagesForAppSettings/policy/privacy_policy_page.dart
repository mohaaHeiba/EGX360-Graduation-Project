import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/widgets/app_settings_widgets/build_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppbar(Get.back, s.privacy_policy),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.last_updated,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 20),
            Text(
              s.privacy_policy_title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              s.privacy_intro,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
            buildSection(
              s.privacy_section_1_title,
              s.privacy_section_1_content,
              theme: theme,
            ),
            buildSection(
              s.privacy_section_2_title,
              s.privacy_section_2_content,
              theme: theme,
            ),
            buildSection(
              s.privacy_section_3_title,
              s.privacy_section_3_content,
              theme: theme,
            ),
            buildSection(
              s.privacy_section_4_title,
              s.privacy_section_4_content,
              theme: theme,
            ),
            buildSection(
              s.privacy_section_5_title,
              s.privacy_section_5_content,
              theme: theme,
            ),
            buildSection(
              s.privacy_section_6_title,
              s.privacy_section_6_content,
              theme: theme,
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                s.copyright,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
