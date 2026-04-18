import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/widgets/app_settings_widgets/build_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataSourcesPage extends StatelessWidget {
  const DataSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppbar(() => Get.back(), s.data_sources),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.data_sources_description,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 20),
            Text(
              s.data_sources_page_title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              s.data_sources_intro,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),

            // ===== Sections =====
            buildSection(
              s.data_source_1_title,
              s.data_source_1_content,
              theme: theme,
            ),
            buildSection(
              s.data_source_2_title,
              s.data_source_2_content,
              theme: theme,
            ),
            buildSection(
              s.data_source_3_title,
              s.data_source_3_content,
              theme: theme,
            ),
            buildSection(
              s.data_source_4_title,
              s.data_source_4_content,
              theme: theme,
            ),
            buildSection(
              s.data_source_5_title,
              s.data_source_5_content,
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
