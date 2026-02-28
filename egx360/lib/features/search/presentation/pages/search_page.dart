import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/features/search/presentation/controllers/search_stocks_controller.dart';
import 'package:egx/features/search/presentation/pages/search_page_desktop.dart';
import 'package:egx/features/search/presentation/pages/search_page_mobile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends GetView<SearchStocksController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: SearchPageMobile(),
      desktopBody: SearchPageDesktop(),
    );
  }
}
