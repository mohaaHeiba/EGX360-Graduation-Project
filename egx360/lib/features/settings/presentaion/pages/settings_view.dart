import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:egx/features/settings/presentaion/pages/app_settings_page.dart';
import 'package:egx/features/settings/presentaion/pages/menu_page.dart';
import 'package:egx/features/settings/presentaion/pages/settings_view_desktop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: Scaffold(
        body: PageView(
          controller: controller.pagecontroller,
          onPageChanged: controller.onPageChange,
          physics: const NeverScrollableScrollPhysics(),
          children: const [MenuPage(), AppSettingsPage()],
        ),
      ),
      desktopBody: const SettingsViewDesktop(),
    );
  }
}
