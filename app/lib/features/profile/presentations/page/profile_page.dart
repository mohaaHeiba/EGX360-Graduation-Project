import 'package:egx/features/profile/presentations/widgets/create_post_widgets/create_post_inline_widget.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/utils/responsive_layout.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/profile/presentations/controller/profile_controller.dart';
import 'package:egx/features/profile/presentations/page/create_post_sheet.dart';
import 'package:egx/features/profile/presentations/widgets/profile_page.dart/build_action_buttons.dart';
import 'package:egx/features/profile/presentations/widgets/profile_page.dart/build_bio_section.dart';
import 'package:egx/features/profile/presentations/widgets/profile_page.dart/build_header.dart';
import 'package:egx/features/profile/presentations/widgets/profile_page.dart/build_posts_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: const _ProfilePageMobile(),
      desktopBody: const _ProfilePageDesktop(),
    );
  }
}

class _ProfilePageMobile extends GetView<ProfileController> {
  const _ProfilePageMobile();

  @override
  Widget build(BuildContext context) {
    final AuthEntity? argUser = Get.arguments as AuthEntity?;
    final AuthEntity? displayUser = argUser ?? controller.userProfile.value;
    final theme = context;

    if (displayUser == null) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: customAppbar(Get.back, context.s.profile_title),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: customAppbar(Get.back, context.s.profile_title, isActions: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(const CreatePostPage(), arguments: displayUser),
        backgroundColor: theme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadFullData(),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHeader(controller, displayUser, context),
                        AppGaps.h4,
                        buildBioSection(controller, displayUser, context),
                        AppGaps.h16,
                        buildActionButtons(controller, displayUser, context),
                        AppGaps.h12,
                        Divider(color: Colors.grey.withOpacity(0.2)),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Builder(
            builder: (BuildContext context) {
              return buildPostsList(
                controller,
                context,
                posts: controller.userPosts,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfilePageDesktop extends GetView<ProfileController> {
  const _ProfilePageDesktop();

  @override
  Widget build(BuildContext context) {
    final AuthEntity? argUser = Get.arguments as AuthEntity?;
    final AuthEntity? displayUser = argUser ?? controller.userProfile.value;

    if (displayUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: context.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Main Content (Left + Center combined) - Flex 3 (approx 75%)
          Expanded(
            flex: 3,
            child: Container(
              color: context.background,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Obx(() {
                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(32),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Profile Header & Stats
                              buildHeader(controller, displayUser, context),
                              AppGaps.h12,
                              buildBioSection(controller, displayUser, context),
                              AppGaps.h24,
                              buildActionButtons(
                                controller,
                                displayUser,
                                context,
                              ),
                              AppGaps.h24,

                              // Create Post Widget (Inline)
                              CreatePostInlineWidget(user: displayUser),

                              AppGaps.h24,
                              Divider(color: Colors.grey.withOpacity(0.2)),
                              AppGaps.h16,
                            ]),
                          ),
                        ),

                        // Posts List
                        if (controller.isPostsLoading.value)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => buildPostShimmerItem(context),
                              childCount: 3,
                            ),
                          )
                        else if (controller.userPosts.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 60,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  AppGaps.h12,
                                  Text(
                                    context.s.profile_no_posts,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final post = controller.userPosts[index];
                              return buildPostItem(
                                context,
                                post,
                                controller,
                                index,
                              );
                            }, childCount: controller.userPosts.length),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),

          // 2. Right Panel (Trending) - Flex 1 (approx 25%)
          Expanded(flex: 1, child: _buildRightPanel(context)),
        ],
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: context.onSurface.withOpacity(0.05)),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.s.community_trending_topics,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendingItem(context, "EGX30", "12.5K posts", "+1.2%", true),
            _buildTrendingItem(
              context,
              "CIB (COMI)",
              "5.2K posts",
              "-0.5%",
              false,
            ),
            _buildTrendingItem(
              context,
              "Gold 21k",
              "Trending in Egypt",
              "",
              true,
            ),
            const SizedBox(height: 32),
            Text(
              context.s.community_who_to_follow,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSuggestionItem(context, "Ahmed Khalil", "@ahmed_k • Analyst"),
            _buildSuggestionItem(
              context,
              "Mohamed Heiba",
              "@heiba_dev • Developer",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingItem(
    BuildContext context,
    String title,
    String subtitle,
    String change,
    bool isPositive,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: context.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
          if (change.isNotEmpty)
            Text(
              change,
              style: TextStyle(
                color: isPositive ? Colors.greenAccent : Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    String name,
    String handle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.onSurface.withOpacity(0.1),
            child: Icon(Icons.person, size: 20, color: context.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  handle,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.onSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.s.community_follow,
              style: TextStyle(
                color: context.background,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
