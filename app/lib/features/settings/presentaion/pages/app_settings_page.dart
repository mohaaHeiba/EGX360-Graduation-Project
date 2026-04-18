import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/custom/custom_dialogs.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/about_egx360/abou_egx_page.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/darkMode/dark_mode_page.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/edit_Profile/edit_profile_page.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/support/help_support_page.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/language/language_page.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/notifications/notifications_page.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/policy/privacy_policy_page.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/security/privacy_security_page.dart';
import 'package:egx/features/settings/presentaion/widgets/app_settings_widgets/modern_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AppSettingsPage extends GetView<SettingsController> {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context;
    final s = context.s;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: customAppbar(controller.backToProfilePage, s.menu_settings),
      body: buildSettingsContent(context, controller),
    );
  }

  static Widget buildSettingsContent(
    BuildContext context,
    SettingsController controller,
  ) {
    final s = context.s;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
            child: Column(
              children: [
                // ===== Section 1: ACCOUNT =====
                ModernSettingsSection(
                  title: s.account_section,
                  items: [
                    SettingItem(
                      icon: Icons.person_outline_rounded,
                      title: s.edit_profile,
                      subtitle: s.edit_profile_subtitle,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EditProfilePage()),
                      ),
                    ),
                    SettingItem(
                      icon: Icons.lock_outline,
                      title: s.privacy_security,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacySecurityPage(),
                        ),
                      ),
                    ),
                    SettingItem(
                      icon: Icons.notifications_none,
                      title: s.notifications,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      ),
                    ),
                  ],
                ),
                AppGaps.h24,

                // ===== Section 2: PREFERENCES =====
                ModernSettingsSection(
                  title: s.preferences_section,
                  items: [
                    SettingItem(
                      icon: Icons.color_lens_outlined,
                      title: s.dark_mode,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DarkModePage()),
                      ),
                    ),
                    SettingItem(
                      icon: Icons.language_rounded,
                      title: s.language,
                      subtitle: s.language_english,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LanguagePage()),
                      ),
                    ),
                  ],
                ),
                AppGaps.h24,

                // ===== Section 3: ABOUT & LOGOUT =====
                ModernSettingsSection(
                  title: s.about_section,
                  items: [
                    SettingItem(
                      icon: Icons.info_outline,
                      title: s.about_egx,
                      subtitle: s.about_version,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutEGXPage()),
                      ),
                    ),
                    SettingItem(
                      icon: Icons.policy_outlined,
                      title: s.privacy_policy,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage(),
                        ),
                      ),
                    ),
                    SettingItem(
                      icon: Icons.help_outline_rounded,
                      title: s.help_support,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => HelpSupportPage()),
                      ),
                    ),
                    SettingItem(
                      icon: Icons.logout_rounded,
                      title: s.logout,
                      titleColor: AppColors.error,
                      iconColor: AppColors.error,
                      onTap: () => CustomDialogs.showConfirm(
                        context,
                        title: s.confirm_logout,
                        desc: s.confirm_logout_message,
                        dialogType: DialogType.warning,
                        btnOkText: s.logout,
                        btnOkColor: AppColors.error,
                        onConfirm: () async {
                          CustomDialogs.showLoading(context);
                          await controller.logout();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
