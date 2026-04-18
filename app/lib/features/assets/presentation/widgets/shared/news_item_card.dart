import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

/// Shared news item card widget used by both mobile and desktop versions
Widget buildNewsItemCard(
  BuildContext context,
  NewsEntity news,
  String timeAgo, {
  required VoidCallback onTap,
}) {
  final isDarkMode = context.isDarkMode;

  return InkWell(
    onTap: onTap,
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
                  timeAgo,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.onSurface.withOpacity(0.3)),
        ],
      ),
    ),
  );
}
