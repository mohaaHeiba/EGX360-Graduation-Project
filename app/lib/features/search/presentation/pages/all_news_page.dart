import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/search/presentation/controllers/search_stocks_controller.dart';
import 'package:egx/features/search/presentation/widgets/search_widgets/build_news_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllNewsPage extends GetView<SearchStocksController> {
  const AllNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllNews(refresh: true);
    });

    return Scaffold(
      backgroundColor: context.background,
      appBar: customAppbar(() => Get.back(), context.s.search_all_news),

      body: Obx(() {
        if (controller.isLoadingAllNews.value) {
          return Center(
            child: CircularProgressIndicator(color: context.primary),
          );
        }

        if (controller.allNews.isEmpty) {
          return Center(
            child: Text(
              context.s.search_no_news,
              style: TextStyle(color: context.onSurface.withOpacity(0.5)),
            ),
          );
        }

        return ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.only(top: 10, bottom: 40),
          itemCount:
              controller.allNews.length +
              (controller.isLoadingMoreNews.value ? 1 : 0),
          itemBuilder: (context, index) {
            // اللودر السفلي
            if (index == controller.allNews.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: context.primary),
                ),
              );
            }
            final news = controller.allNews[index];

            // ✅ إضافة مسافة صغيرة بين كل خبر والتاني
            return buildNewsItem(context, news);
          },
        );
      }),
    );
  }
}
