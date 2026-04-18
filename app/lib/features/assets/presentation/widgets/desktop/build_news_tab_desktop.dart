import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/assets/presentation/widgets/shared/news_item_card.dart';
import 'package:egx/features/news_briefing/domain/entities/news_summary_entity.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

/// Desktop version of the news tab - shows in-panel details and summaries
Widget buildNewsTabDesktop(BuildContext context, dynamic controller) {
  final selectedNews = Rx<NewsEntity?>(null);
  final selectedTimeAgo = ''.obs;
  final showSummary = false.obs;

  final ScrollController scrollController = ScrollController();

  scrollController.addListener(() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreNews();
    }
  });

  return Obx(() {
    // If showing AI summary
    if (showSummary.value && controller.currentSummary.value != null) {
      return _buildSummaryView(
        context,
        controller.currentSummary.value!,
        onBack: () => showSummary.value = false,
      );
    }

    // If a news item is selected, show details
    if (selectedNews.value != null) {
      return _buildNewsDetailsView(
        context,
        selectedNews.value!,
        selectedTimeAgo.value,
        onBack: () => selectedNews.value = null,
      );
    }

    // Otherwise show news list
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

            return buildNewsItemCard(
              context,
              news,
              timeAgo,
              onTap: () {
                // Desktop: Show in-panel
                selectedNews.value = news;
                selectedTimeAgo.value = timeAgo;
              },
            );
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
                  : () async {
                      // Desktop: Show in-panel
                      await controller.generateSummaryInPanel();
                      if (controller.currentSummary.value != null) {
                        showSummary.value = true;
                      }
                    },
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

// News Details View (Desktop only)
Widget _buildNewsDetailsView(
  BuildContext context,
  NewsEntity news,
  String timeAgo, {
  required VoidCallback onBack,
}) {
  return Column(
    children: [
      // Scrollable content
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with back button
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back),
                        onPressed: onBack,
                        tooltip: S.of(context).asset_details_back_news,
                      ),
                    ),
                    const WidgetSpan(child: SizedBox(width: 8)),
                    TextSpan(
                      text: news.title,
                      style: context.textStyles.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Time and source
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: context.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeAgo,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (news.source!.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.newspaper,
                      size: 16,
                      color: context.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      news.source!,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Content
              Text(
                news.content!,
                style: context.textStyles.bodyLarge?.copyWith(
                  height: 1.7,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Read more button
              if (news.url!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(news.url!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: Text(S.of(context).asset_details_read_full),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: context.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

// AI Summary View (Desktop only)
Widget _buildSummaryView(
  BuildContext context,
  NewsSummaryEntity summary, {
  required VoidCallback onBack,
}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with back button
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
              tooltip: S.of(context).asset_details_back_news,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Text(
              S.of(context).asset_details_ai_summary_title,
              style: context.textStyles.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                height: 1.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Metadata
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: context.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              S.of(context).asset_details_ai_generated,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.newspaper,
              size: 16,
              color: context.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              S.of(context).asset_details_latest_news,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Summary content
        Text(
          summary.summary,
          style: context.textStyles.bodyLarge?.copyWith(
            height: 1.7,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
