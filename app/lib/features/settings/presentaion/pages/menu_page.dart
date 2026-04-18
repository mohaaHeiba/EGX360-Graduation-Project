import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:egx/features/settings/presentaion/widgets/ProfileWidgets/build_profile_card.dart';
import 'package:egx/features/settings/presentaion/widgets/ProfileWidgets/build_simulation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MenuPage extends GetView<SettingsController> {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context;
    final gradients = context.gradients;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: theme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 80,

        // 🔹 Title
        title: ShaderMask(
          shaderCallback: (bounds) => gradients.logo.createShader(bounds),
          child: Text(
            "EGX360",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1,
              fontSize: 34.sp.clamp(28, 36),
              shadows: [
                Shadow(
                  color: theme.onSurface.withValues(alpha: 0.2),
                  blurRadius: 8.r,
                  offset: Offset(2.r, 2.r),
                ),
              ],
            ),
          ),
        ),

        // 🔹 Right Button (Settings)
        actions: [
          Center(
            child: Container(
              margin: EdgeInsets.only(right: 18.0.w),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.2),
                    blurRadius: 10.r,
                    offset: Offset(0.w, 4.h),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: controller.goToSettingsPage,
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),

      // 🔹 Body
      body: buildMenuContent(context, controller),
    );
  }

  static Widget buildMenuContent(
    BuildContext context,
    SettingsController controller,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final user = controller.currentUser.value;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ProfileCard(
              currentUser: user,
              postsCount: controller.userStats.value?.postsCount ?? 0,
              followersCount: controller.userStats.value?.followersCount ?? 0,
              followingCount: controller.userStats.value?.followingCount ?? 0,
            );
          }),
          AppGaps.h12,
          buildSimulationCard(context),
        ],
      ),
    );
  }
}
