import 'dart:ui';
import 'package:egx/core/Layout/layout_controller.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/constants/app_images.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/pages/settings_view_desktop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SideNavBar extends GetView<LayoutController> {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.context!;
    final s = context.s;

    return Obx(
      () => SizedBox(
        width: 80.w.clamp(70, 90),

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              AppGaps.h32,
              // Logo Project EGX360
              Image.asset(AppImages.logo, height: 60.h),
              AppGaps.h12,

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(color: theme.onSurface.withOpacity(0.5)),
              ),
              // Navigation Items Section
              Expanded(
                child: Column(
                  children: [
                    _sideNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: s.nav_home,
                    ),
                    _sideNavItem(
                      index: 1,
                      icon: Icons.show_chart_outlined,
                      activeIcon: Icons.show_chart_rounded,
                      label: s.nav_markets,
                    ),
                    _sideNavItem(
                      index: 2,
                      icon: Icons.search_outlined,
                      activeIcon: Icons.search_rounded,
                      label: s.nav_search,
                    ),
                    _sideNavItem(
                      index: 3,
                      icon: Icons.groups_outlined,
                      activeIcon: Icons.groups_rounded,
                      label: s.nav_community,
                    ),
                    _sideNavItem(
                      index: 4,
                      icon: Icons.pie_chart_outline_rounded,
                      activeIcon: Icons.pie_chart_rounded,
                      label: s.nav_simulation,
                    ),
                  ],
                ),
              ),
              // Bottom Section: Settings
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: IconButton(
                  onPressed: () {
                    Get.bottomSheet(
                      Container(
                        height: Get.height * 0.95,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: const ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: SettingsViewDesktop(),
                        ),
                      ),
                      isScrollControlled: true,
                    );
                  },
                  icon: Icon(
                    Icons.settings_outlined,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    size: 28,
                  ),
                  tooltip: s.nav_settings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sideNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () {
        // First, change the tab index
        controller.changeTab(index);

        // If we're on a detail page route (not in MainLayout),
        // navigate back to MainLayout without destroying it
        if (Get.currentRoute != '/loyoutPage') {
          // Navigate back to MainLayout (preserves controllers)
          Get.until((route) => route.settings.name == '/loyoutPage');
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: isActive ? 0 : -5,
            child: Container(
              width: 8,
              height: 40.h,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.candleGreen
                    : AppColors.candleGreen.withAlpha(10),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.candleGreen.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            color: Colors.transparent,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    size: isActive ? 30.r : 26.r,
                    color: isActive
                        ? AppColors.candleGreen
                        : Get.context!.textTheme.bodyMedium!.color,
                  ),
                ),
                AppGaps.h4,
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.candleGreen
                        : Get.context!.textTheme.bodyMedium!.color,
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
