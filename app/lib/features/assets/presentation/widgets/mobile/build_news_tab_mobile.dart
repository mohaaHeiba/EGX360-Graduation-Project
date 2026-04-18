import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';

import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget buildNewsTab(BuildContext context, dynamic controller) {
  // final controller = Get.find<StockDetailsController>(); // Removed

  final ScrollController scrollController = ScrollController();

  scrollController.addListener(() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreNews();
    }
  });

  return Obx(() {
    if (controller.isLoadingNews.value && controller.newsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.newsList.isEmpty) {
      return Center(
        child: Text(
          S.of(context).asset_details_no_news_available,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount:
              controller.newsList.length +
              (controller.isLoadingMoreNews.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.newsList.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final news = controller.newsList[index];
            String timeAgo = "";
            try {
              timeAgo = timeago.format(
                DateTime.parse(news.publishedAt),
                locale: 'en_short',
              );
            } catch (e) {
              timeAgo = "Now";
            }

            return _buildNewsItem(context, news, timeAgo);
          },
        ),
        // Floating Action Button for AI Summary
        Positioned(
          right: 16,
          bottom: 16,
          child: Obx(() {
            final isDisabled = controller.newsList.length < 3;
            final isSummarizing = controller.isSummarizing.value;

            return FloatingActionButton.extended(
              onPressed: isDisabled || isSummarizing
                  ? null
                  : () => controller.summarizeLatestNews(),
              backgroundColor: isDisabled
                  ? Colors.grey
                  : Theme.of(context).colorScheme.primary,
              icon: isSummarizing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome, color: Colors.white),
              label: Text(
                isSummarizing
                    ? S.of(context).asset_details_summarizing
                    : S.of(context).asset_details_ai_summary,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }),
        ),
      ],
    );
  });
}

Widget _buildNewsItem(BuildContext context, NewsEntity news, String time) {
  final isDarkMode = context.isDarkMode;
  return InkWell(
    onTap: () => Get.toNamed(
      AppPages.newsDetailsPage,
      arguments: {'news': news, 'time_ago': time},
    ),
    borderRadius: BorderRadius.circular(8),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? context.surface.withOpacity(0.5) : context.surface,
        borderRadius: BorderRadius.circular(8),
        border: !isDarkMode
            ? Border.all(color: context.onSurface.withOpacity(0.1))
            : null,
        // boxShadow: [
        //   BoxShadow(
        //     color: isDarkMode
        //         ? context.colors.outline.withOpacity(0.1)
        //         : context.colors.outline.withOpacity(0.1),
        //     offset: isDarkMode ? Offset(0, 8) : Offset(0, 2),
        //     blurRadius: isDarkMode ? 0 : 4,
        //   ),
        // ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              //       offset: const Offset(0, 2),
              //       blurRadius: 4,
              //     ),
              //   ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
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
  );
}
