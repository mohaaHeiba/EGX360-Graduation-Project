import 'package:egx/core/Layout/side_nav_bar.dart';
import 'package:egx/core/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

/// Wraps a page to show SideNavBar on desktop, full-screen on mobile
/// This ensures the side navigation is always visible on desktop
class DesktopRouteWrapper extends StatelessWidget {
  final Widget child;

  const DesktopRouteWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      // Mobile: show page full-screen (no side nav)
      mobileBody: child,

      // Desktop: show with SideNavBar
      desktopBody: Scaffold(
        body: Row(
          children: [
            const SideNavBar(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
