import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:egx/core/Layout/layout_controller.dart';
import 'package:egx/core/Layout/side_nav_bar.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
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
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final LayoutController controller = Get.find<LayoutController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWelcomeDialog();
    });
  }

  void _checkAndShowWelcomeDialog() {
    // خلي القيمة الافتراضية true عشان يظهر أول مرة
    final shouldShowWelcome = GetStorage().read('shouldShowWelcome') ?? true;
    final s = context.s;

    if (shouldShowWelcome) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.noHeader,
          animType: AnimType.scale,
          dialogBackgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          body: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500, // هنا بنتحكم في أقصى عرض للديالوج
              minWidth: 300, // وأقل عرض ممكن
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                // الـ Sigma بيحدد درجة الـ "غلوشة"
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.surface.withOpacity(0.85),
                        context.surface.withOpacity(0.65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // الـ Animation مع Container خلفي خفيف
                      Container(
                        height: 160,
                        alignment: Alignment.center,
                        child: Lottie.asset(
                          'assets/animations/congratulations.json',
                          fit: BoxFit.contain,
                          repeat: false,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Balance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.onSurface.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: context.onSurface.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              s.virtual_balance_title.toUpperCase(),
                              style: TextStyle(
                                color: context.onSurface.withOpacity(0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  context.gradients.logo.createShader(bounds),
                              child: const Text(
                                '100,000 EGP',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        s.welcome_dialog_message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.onSurface.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Modern Action Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            GetStorage().write('shouldShowWelcome', false);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryLight,
                                  AppColors.primaryDark,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.35),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                s.start_trading_btn,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ).show();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
