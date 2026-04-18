import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/features/community/presentation/controller/community_controller.dart';
import 'package:egx/features/community/presentation/pages/community_page_desktop.dart';
import 'package:egx/features/community/presentation/pages/community_page_mobile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityPage extends GetView<CommunityController> {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: CommunityPageMobile(),
      desktopBody: CommunityPageDesktop(),
    );
  }
}
