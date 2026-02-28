import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/features/assets/presentation/pages/asset_details_page_desktop.dart';
import 'package:egx/features/assets/presentation/pages/asset_details_page_mobile.dart';
import 'package:flutter/material.dart';

class AssetDetailsPage extends StatelessWidget {
  const AssetDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: AssetDetailsPageMobile(),
      desktopBody: AssetDetailsPageDesktop(),
    );
  }
}
