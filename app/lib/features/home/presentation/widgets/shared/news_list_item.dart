// import 'package:egx/core/helper/context_extensions.dart';
// import 'package:egx/core/routes/app_pages.dart';
// import 'package:egx/features/home/data/models/news_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NewsListItem extends StatelessWidget {
//   final NewsModel news;

//   const NewsListItem({super.key, required this.news});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Get.toNamed(
//           AppPages.newsDetailsPage,
//           arguments: {
//             'news': news,
//             'time_ago': timeago.format(DateTime.parse(news.publishedAt)),
//           },
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: context.surface.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: context.colors.outline.withOpacity(0.1)),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Thumbnail
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: news.stock?.logoUrl != null
//                   ? Image.network(
//                       news.stock!.logoUrl!,
//                       width: 80,
//                       height: 80,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return _buildPlaceholder(context);
//                       },
//                     )
//                   : _buildPlaceholder(context),
//             ),

//             const SizedBox(width: 12),

//             // Content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Title
//                   Text(
//                     news.title ?? 'No title',
//                     style: context.textStyles.titleSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),

//                   const SizedBox(height: 6),

//                   // Content Preview
//                   if (news.content != null && news.content!.isNotEmpty)
//                     Text(
//                       news.content!,
//                       style: context.textStyles.bodySmall?.copyWith(
//                         color: context.onSurface.withOpacity(0.6),
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),

//                   const SizedBox(height: 8),

//                   // Meta info
//                   Row(
//                     children: [
//                       if (news.source != null && news.source!.isNotEmpty) ...[
//                         Icon(
//                           Icons.article_outlined,
//                           size: 12,
//                           color: context.primary,
//                         ),
//                         const SizedBox(width: 4),
//                         Flexible(
//                           child: Text(
//                             news.source!,
//                             style: context.textStyles.labelSmall?.copyWith(
//                               color: context.primary,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                       ],
//                       Icon(
//                         Icons.access_time,
//                         size: 12,
//                         color: context.onSurface.withOpacity(0.5),
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         news.publishedAt != null
//                             ? timeago.format(DateTime.parse(news.publishedAt))
//                             : 'Unknown',
//                         style: context.textStyles.labelSmall?.copyWith(
//                           color: context.onSurface.withOpacity(0.5),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlaceholder(BuildContext context) {
//     return Container(
//       width: 80,
//       height: 80,
//       decoration: BoxDecoration(
//         color: context.surface,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Icon(
//         Icons.newspaper,
//         color: context.primary.withOpacity(0.5),
//         size: 32,
//       ),
//     );
//   }
// }
