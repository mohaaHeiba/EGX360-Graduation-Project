import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget buildNewsItem(BuildContext context, NewsEntity news) {
  final symbol = news.stock?.symbol ?? 'Market';

  String timeAgo = "";
  try {
    timeAgo = timeago.format(
      DateTime.parse(news.publishedAt),
      locale: 'en_short',
    );
  } catch (e) {
    timeAgo = "Now";
  }

  return InkWell(
    onTap: () => Get.toNamed(
      AppPages.newsDetailsPage,
      arguments: {"news": news, "time_ago": timeAgo},
    ),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  symbol,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timeAgo,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            news.title,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
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
