import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/profile/presentations/controller/follow_list_controller.dart';
import 'package:egx/features/profile/presentations/widgets/user_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FollowersFollowingPage extends StatefulWidget {
  const FollowersFollowingPage({super.key});

  @override
  State<FollowersFollowingPage> createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FollowListController controller = Get.find<FollowListController>();
  late String userId;
  late String userName;
  late int initialIndex;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    userId = args['userId'];
    userName = args['userName'];
    initialIndex = args['initialIndex'] ?? 0;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );

    // Fetch data
    controller.fetchFollowers(userId);
    controller.fetchFollowing(userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(Get.context!).colorScheme.background,
        elevation: 0,
        leadingWidth: 80,
        leading: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            return Center(
              child: Container(
                margin: const EdgeInsets.only(left: 0.0),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            );
          },
        ),
        title: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            return Text(
              userName,
              style: TextStyle(
                color: colorScheme.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.s.community_followers),
            Tab(text: context.s.community_following),
          ],
          indicatorColor: context.appTheme.primaryColor,
          labelColor: context.appTheme.primaryColor,
          unselectedLabelColor: context.appTheme.textTheme.bodySmall?.color,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFollowersList(), _buildFollowingList()],
      ),
    );
  }
  // ... بقية الكود كما هو

  Widget _buildFollowersList() {
    return Obx(() {
      if (controller.isLoadingFollowers.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.followers.isEmpty) {
        return Center(child: Text(context.s.profile_no_followers));
      }

      // تم التغيير لـ separated لإضافة الخط الرفيع
      return ListView.separated(
        itemCount: controller.followers.length,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ), // مساحة بسيطة في أول وآخر القائمة
        separatorBuilder: (context, index) => Divider(
          height: 1, // المساحة اللي بياخدها الـ Divider
          thickness: 0.5, // سُمك الخط نفسه (رفيع جداً)
          indent: 20, // بداية الخط (عشان ميبدأش من الحافة خالص)
          endIndent: 20, // نهاية الخط
          color: context.theme.colorScheme.onBackground.withOpacity(
            0.08,
          ), // لون هادي جداً
        ),
        itemBuilder: (context, index) {
          final user = controller.followers[index];
          return UserListItem(user: user, controller: controller);
        },
      );
    });
  }

  Widget _buildFollowingList() {
    return Obx(() {
      if (controller.isLoadingFollowing.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.following.isEmpty) {
        return Center(child: Text(context.s.profile_not_following_anyone));
      }

      // تم التغيير لـ separated هنا أيضاً
      return ListView.separated(
        itemCount: controller.following.length,
        padding: const EdgeInsets.symmetric(vertical: 12),
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          indent: 20,
          endIndent: 20,
          color: context.theme.colorScheme.onBackground.withOpacity(0.08),
        ),
        itemBuilder: (context, index) {
          final user = controller.following[index];
          return UserListItem(user: user, controller: controller);
        },
      );
    });
  }
}
