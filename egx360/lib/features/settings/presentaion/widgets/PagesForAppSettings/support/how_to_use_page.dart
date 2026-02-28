import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/features/settings/presentaion/widgets/app_settings_widgets/build_section.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColorPrimary = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final textColorSecondary = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final hintColor = theme.textTheme.bodySmall?.color ?? Colors.grey.shade400;
    final s = context.s;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: customAppbar(() => Get.back(), s.how_to_use_page_title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.how_to_use_description,
              style: TextStyle(color: hintColor, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Text(
              s.how_to_use_page_title,
              style: TextStyle(
                color: textColorPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              s.how_to_use_intro,
              style: TextStyle(color: textColorSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            buildSection(
              s.how_to_step_1_title,
              s.how_to_step_1_content,
              theme: theme,
            ),
            buildSection(
              s.how_to_step_2_title,
              s.how_to_step_2_content,
              theme: theme,
            ),
            buildSection(
              s.how_to_step_3_title,
              s.how_to_step_3_content,
              theme: theme,
            ),
            buildSection(
              s.how_to_step_4_title,
              s.how_to_step_4_content,
              theme: theme,
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                s.copyright,
                style: TextStyle(color: hintColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
