import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/search/presentation/controllers/search_stocks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Latest News Section - Uses SearchStocksController's latestNews
class LatestNewsSection extends StatelessWidget {
  final int limit;

  const LatestNewsSection({super.key, this.limit = 5});

  @override
  Widget build(BuildContext context) {
    // Use the already-registered SearchStocksController
    final controller = Get.find<SearchStocksController>();
    final s = context.s;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.primary.withOpacity(0.2),
                      context.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.newspaper_rounded,
                  color: context.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                s.latest_news_title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.toNamed(AppPages.allNewsPage),
                child: Text(
                  s.see_all_btn,
                  style: TextStyle(
                    color: context.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content - Use Obx to reactively display news from controller
          Obx(() {
            final news = controller.latestNews.take(limit).toList();

            if (news.isEmpty) {
              return _buildEmptyState(context);
            }

            return Column(
              children: news.map((n) => _buildNewsItem(context, n)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: context.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              color: context.onSurface.withOpacity(0.3),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              context.s.no_news_available,
              style: TextStyle(
                color: context.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, NewsEntity news) {
    final s = context.s;
    String timeAgoStr = "";
    try {
      timeAgoStr = timeago.format(
        DateTime.parse(news.publishedAt),
        locale: 'en_short',
      );
    } catch (e) {
      timeAgoStr = s.now_label;
    }
    // ... (rest of the method unchanged, but using s.market_label later)

    return InkWell(
      onTap: () => Get.toNamed(
        AppPages.newsDetailsPage,
        arguments: {"news": news, "time_ago": timeAgoStr},
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.onSurface.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source and Time row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    news.stock?.symbol ?? s.market_label,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  timeAgoStr,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              news.title,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Source
            Text(
              news.source ?? 'Google News',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
