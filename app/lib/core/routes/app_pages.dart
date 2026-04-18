import 'package:egx/core/Layout/main_layout.dart';
import 'package:egx/features/auth/presentaion/bindings/auth_bindings.dart';
import 'package:egx/core/bindings/community_bindings.dart';
import 'package:egx/core/bindings/layout_bindings.dart';
import 'package:egx/core/bindings/news_details_bindings.dart';
import 'package:egx/core/bindings/post_details_binding.dart';
import 'package:egx/core/bindings/profile_bindings.dart';
import 'package:egx/core/bindings/search_bindings.dart';
import 'package:egx/core/bindings/settings_bindings.dart';
import 'package:egx/features/welcome/presentaion/bindings/welcome_bindings.dart';
import 'package:egx/features/auth/presentaion/widgets/email_verification_page.dart';
import 'package:egx/features/home/presentation/bindings/home_binding.dart';
import 'package:egx/features/auth/presentaion/pages/mobile/auth_page.dart';
import 'package:egx/features/auth/presentaion/widgets/create_new_password_page.dart';
import 'package:egx/features/auth/presentaion/widgets/forgot_password_page.dart';
import 'package:egx/features/community/presentation/pages/community_page.dart';
import 'package:egx/features/home/presentation/pages/trending_stocks_page.dart';
import 'package:egx/features/home/presentation/pages/trending_stocks_page_desktop.dart';
import 'package:egx/features/post_details/presentation/page/post_details_page.dart';
import 'package:egx/features/profile/presentations/page/profile_page.dart';
import 'package:egx/features/profile/presentations/page/user_profile_page.dart';
import 'package:egx/features/profile/presentations/page/followers_following_page.dart';
import 'package:egx/features/profile/presentations/page/saved_posts_page.dart';
import 'package:egx/features/search/presentation/pages/news_details_page.dart';
import 'package:egx/features/search/presentation/pages/all_news_page.dart';
import 'package:egx/features/assets/presentation/pages/asset_details_page.dart';

import 'package:egx/features/news_briefing/presentation/pages/news_summary_page.dart';
import 'package:egx/features/assets/presentation/bindings/asset_bindings.dart';
import 'package:egx/features/welcome/presentaion/page/welcome_page.dart';
import 'package:egx/core/widgets/desktop_route_wrapper.dart';
import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/core/Layout/side_nav_bar.dart';
import 'package:egx/core/utils/responsive_transition.dart';
import 'package:egx/features/news_briefing/presentation/bindings/news_briefing_bindings.dart';
import 'package:egx/features/notifications/presentation/page/notification_page.dart';
import 'package:egx/features/chatbot/presentation/pages/chatbot_page.dart';
import 'package:egx/features/notifications/presentation/bindings/notification_binding.dart';
import 'package:egx/features/simulation/presentation/pages/portfolio_page.dart';
import 'package:egx/features/simulation/presentation/pages/transaction_history_page.dart';
import 'package:egx/features/simulation/presentation/bindings/simulation_bindings.dart';
import 'package:egx/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:egx/features/onboarding/presentation/bindings/onboarding_bindings.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:egx/features/home/presentation/pages/watchlist_page.dart';

class AppPages {
  static const welcomePage = '/welcome';
  static const searchPage = '/search';
  static const menuPage = '/menu';
  static const portfolioPage = '/portfolio';
  static const transactionHistoryPage = '/transaction-history';
  static const authPage = '/auth';
  static const homePage = '/home';
  static const watchlistPage = '/watchlist';
  static const trendingStocksPage = '/trending-stocks';
  static const forgotPassPage = '/forgotPass';
  static const createNewPassPage = '/newPass';
  static const verifyEmailPage = '/verify_email';
  static const layoutPage = '/loyoutPage';

  static const profilePage = '/profile';
  static const userProfilePage = '/user_profile'; // New route
  static const followersFollowingPage = '/followers_following';
  static const communityPage = '/community';
  static const showDetailsPage = '/showDetailsPage';
  static const notificationPage = '/notifications';
  static const savedPosts = '/saved_posts';

  static const newsDetailsPage = '/newsDetailsPage';
  static const allNewsPage = '/allNewsPage';

  static const stockDetailsPage = '/stockDetailsPage';
  static const newsSummaryPage = '/newsSummaryPage';
  static const cryptoDetailsPage = '/cryptoDetailsPage';
  static const currencyDetailsPage = '/currencyDetailsPage';
  static const chatbotPage = '/chatbot';
  static const onboardingPage = '/onboarding';

  static List<GetPage> routes = [
    // Onboarding (shown once after first registration)
    GetPage(
      name: onboardingPage,
      page: () => const OnboardingPage(),
      binding: OnboardingBindings(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    // welcome
    GetPage(
      name: welcomePage,
      page: () => const WelcomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700),
      binding: WelcomeBindings(),
    ),
    // Auth
    GetPage(
      name: authPage,
      page: () => AuthPage(),
      transition: Transition.fadeIn,
      binding: AuthBindings(),
    ),
    GetPage(
      name: verifyEmailPage,
      page: () => const EmailVerificationPage(), // تأكد إنك عامل import للصفحة
      binding: AuthBindings(), // مهم جداً عشان الكنترولر يشتغل
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: forgotPassPage,
      page: () => ForgotPasswordPage(),
      transition: Transition.fadeIn,
      binding: AuthBindings(),
    ),
    GetPage(
      name: createNewPassPage,
      page: () => CreateNewPasswordPage(),
      transition: Transition.fadeIn,
      binding: AuthBindings(),
    ),
    // layout
    GetPage(
      name: layoutPage,
      page: () => MainLayout(),
      transition: Transition.fadeIn,
      bindings: [
        LayoutBindings(),
        SettingsBinding(),
        CommunityBindings(),
        SearchBindings(),
        HomeBinding(),
        SimulationBindings(),
      ],
    ),
    // show post
    GetPage(
      name: showDetailsPage,
      page: () => DesktopRouteWrapper(child: PostDetailsPage()),
      binding: PostDetailsBinding(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.fadeIn,
      ),
    ),

    //////////////////////////////
    GetPage(
      name: profilePage,
      page: () => const DesktopRouteWrapper(child: ProfilePage()),
      binding: ProfileBindings(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    ),
    GetPage(
      name: userProfilePage,
      page: () => const DesktopRouteWrapper(child: UserProfilePage()),
      binding: ProfileBindings(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.rightToLeft,
      ),
    ),
    GetPage(
      name: followersFollowingPage,
      page: () => const FollowersFollowingPage(),
      binding: ProfileBindings(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.rightToLeft,
      ),
    ),
    GetPage(
      name: communityPage,
      page: () => const CommunityPage(),
      binding: CommunityBindings(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    ///////////////////////////////////////
    ///
    GetPage(
      name: newsDetailsPage,
      page: () => DesktopRouteWrapper(child: NewsDetailsPage()),
      binding: NewsDetailsBindings(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.fadeIn,
      ),
    ),
    GetPage(
      name: allNewsPage,
      page: () => const AllNewsPage(),
      // Reuse SearchBindings or rely on existing controller if kept alive
      // Since SearchStocksController is likely in memory from SearchPage, we might not need a binding if we navigate from there.
      // However, to be safe, we can use SearchBindings or just ensure the controller is available.
    ),
    GetPage(
      name: stockDetailsPage,
      page: () => const DesktopRouteWrapper(child: AssetDetailsPage()),
      binding: AssetBindings(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.downToUp,
      ),
    ),
    GetPage(
      name: newsSummaryPage,
      page: () => const NewsSummaryPage(),
      binding: NewsBriefingBindings(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.rightToLeft,
      ),
    ),
    GetPage(
      name: cryptoDetailsPage,
      page: () => const DesktopRouteWrapper(child: AssetDetailsPage()),
      binding: AssetBindings(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.downToUp,
      ),
    ),
    GetPage(
      name: currencyDetailsPage,
      page: () => const DesktopRouteWrapper(child: AssetDetailsPage()),
      binding: AssetBindings(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.downToUp,
      ),
    ),
    GetPage(
      name: watchlistPage,
      page: () => const WatchlistPage(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.rightToLeft,
      ),
    ),
    GetPage(
      name: trendingStocksPage,
      page: () => ResponsiveLayout(
        mobileBody: const TrendingStocksPage(),
        desktopBody: Row(
          children: [
            const SideNavBar(),
            const Expanded(child: TrendingStocksPageDesktop()),
          ],
        ),
      ),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.rightToLeft,
      ),
    ),
    GetPage(
      name: notificationPage,
      page: () => const NotificationPage(),
      binding: NotificationBinding(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.rightToLeft,
      ),
    ),
    GetPage(
      name: savedPosts,
      page: () => const SavedPostsPage(),
      binding: ProfileBindings(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.rightToLeft,
      ),
    ),
    GetPage(
      name: portfolioPage,
      page: () => const PortfolioPage(),
      binding: SimulationBindings(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.rightToLeft,
      ),
    ),
    GetPage(
      name: transactionHistoryPage,
      page: () => const TransactionHistoryPage(),
      binding: SimulationBindings(),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.rightToLeft,
      ),
    ),
    GetPage(
      name: chatbotPage,
      page: () => ResponsiveLayout(
        mobileBody: const ChatbotPage(),
        desktopBody: Scaffold(
          body: Row(
            children: [
              const SideNavBar(),
              const Expanded(child: ChatbotPage(isDesktop: true)),
            ],
          ),
        ),
      ),
      customTransition: ResponsiveTransition.adaptive(
        mobileTransition: Transition.downToUp,
      ),
    ),
  ];
}
