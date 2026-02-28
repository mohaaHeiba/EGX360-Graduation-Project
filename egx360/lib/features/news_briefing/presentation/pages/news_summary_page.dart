import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/news_briefing/presentation/controllers/news_summary_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/core/constants/app_colors.dart';

class NewsSummaryPage extends GetView<NewsSummaryController> {
  const NewsSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final S = Get.context!.s;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: customAppbar(Get.back, S.ai_news_summary, withIcon: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Articles Analyzed - styled like news items
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? context.surface.withOpacity(0.5)
                    : context.surface,
                borderRadius: BorderRadius.circular(8),
                border: !context.isDarkMode
                    ? Border.all(color: context.onSurface.withOpacity(0.1))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.summary.newsCount} ${S.articles_analyzed}',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.summary.getDateRangeText(),
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.onSurface.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Summary Text - no container, just text
            Text(
              controller.summary.summary,
              style: context.textStyles.bodyLarge?.copyWith(
                height: 1.8,
                color: context.onSurface,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: context.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      S.alert_summry,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.onSurface.withOpacity(0.5),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: controller.toggleSpeech,
          backgroundColor: controller.isSpeaking.value
              ? AppColors.candleRed
              : AppColors.candleGreen,
          child: Icon(
            controller.isSpeaking.value ? Icons.stop : Icons.headphones,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
