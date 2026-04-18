import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';
import 'package:egx/features/home/presentation/widgets/shared/watchlist_section.dart';
import 'package:egx/features/home/presentation/widgets/shared/watchlist_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    // Fetch full watchlist when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFullWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: customAppbar(() => Get.back(), 'Watchlist'),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const WatchlistShimmer();
          }
          return WatchlistSection(watchlist: controller.watchlist.toList());
        }),
      ),
    );
  }
}
