import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/search/presentation/controllers/news_tts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewsDetailsPage extends GetView<NewsTtsController> {
  const NewsDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final news = Get.arguments['news'] as NewsEntity;
    final timeAgo = Get.arguments['time_ago'];

    return Scaffold(
      backgroundColor: context.background,
      appBar: customAppbar(Get.back, context.s.search_news_details),
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: () => controller.speak(
            news.content ??
                "${news.title}. ${context.s.search_tts_check_source}",
          ),
          backgroundColor: controller.isSpeaking.value
              ? AppColors.candleRed
              : AppColors.candleGreen,
          child: Icon(
            controller.isSpeaking.value ? Icons.stop : Icons.headphones,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    news.source ?? context.s.search_egx_news,
                    style: TextStyle(
                      color: context.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  timeAgo,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              news.title,
              style: TextStyle(
                color: context.onBackground,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Text(
              news.content ?? context.s.search_no_content,
              style: TextStyle(
                color: context.onBackground,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Read More Button (if URL exists)
            if (news.url != null && news.url!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.openUrl(news.url!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.surface.withOpacity(0.5)),
                    ),
                  ),
                  label: Text(
                    context.s.search_read_original,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
