import 'package:egx/core/Layout/layout_controller.dart';
import 'package:egx/core/Layout/side_nav_bar.dart';
import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/features/community/presentation/pages/community_page.dart';
import 'package:egx/features/home/presentation/pages/home_page.dart';
import 'package:egx/features/home/presentation/pages/home_page_desktop.dart';
import 'package:egx/features/markets/presentation/pages/markets_page.dart';
import 'package:egx/features/search/presentation/pages/search_page.dart';
import 'package:egx/features/settings/presentaion/pages/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/core/Layout/bottom_nav_bar.dart';
import 'package:egx/features/simulation/presentation/pages/portfolio_page.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final LayoutController controller = Get.find<LayoutController>();

    // Mobile pages
    final mobilePages = const [
      HomePage(),
      MarketsPage(),
      SearchPage(),
      CommunityPage(),
      SettingsView(),
    ];

    // Desktop pages - uses HomePageDesktop instead of HomePage
    final desktopPages = const [
      HomePageDesktop(),
      MarketsPage(),
      SearchPage(),
      CommunityPage(),
      PortfolioPage(),
    ];

    return Obx(
      () => Scaffold(
        body: ResponsiveLayout(
          mobileBody: IndexedStack(
            index: controller.currentIndex.value,
            children: mobilePages,
          ),

          // for desktop or tablet
          desktopBody: Row(
            children: [
              const SideNavBar(),
              Expanded(
                child: IndexedStack(
                  index: controller.currentIndex.value,
                  children: desktopPages,
                ),
              ),
            ],
          ),
        ),

        // for mobile
        bottomNavigationBar: ResponsiveLayout(
          mobileBody: const BottomNavBar(),
          desktopBody: const SizedBox.shrink(),
        ),
      ),
    );
  }
}
