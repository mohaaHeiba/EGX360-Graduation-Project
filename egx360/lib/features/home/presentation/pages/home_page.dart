import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/features/home/presentation/pages/home_page_desktop.dart';
import 'package:egx/features/home/presentation/pages/home_page_mobile.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: HomePageMobile(),
      desktopBody: HomePageDesktop(),
    );
  }
}
