import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/custom/custom_dialogs.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/security/active_sessions_page.dart';
import 'package:egx/features/settings/presentaion/widgets/PagesForAppSettings/security/change_pass_page.dart';
import 'package:egx/features/settings/presentaion/widgets/app_settings_widgets/modern_settings_section.dart'
    show ModernSettingsSection, SettingItem;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/core/custom/custom_appbar.dart';

class PrivacySecurityPage extends GetView<SettingsController> {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context;
    final s = context.s;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: customAppbar(() => Get.back(), s.privacy_security),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AppGaps.h12,

          /// SECURITY SECTION
          ModernSettingsSection(
            title: s.security_section,
            items: [
              SettingItem(
                icon: Icons.lock_outline_rounded,
                title: s.change_password,
                subtitle: s.change_password_subtitle,
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => ChangePassPage()));
                },
              ),
              SettingItem(
                icon: Icons.devices_other_outlined,
                title: s.active_sessions,
                subtitle: s.active_sessions_subtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ActiveSessionsPage()),
                  );
                },
              ),
            ],
          ),

          AppGaps.h32,

          /// ACCOUNT ACTIONS SECTION
          ModernSettingsSection(
            title: s.account_actions_section,
            items: [
              SettingItem(
                icon: Icons.delete_outline_rounded,
                title: s.delete_account,
                subtitle: s.delete_account_subtitle,
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: () {
                  CustomDialogs.showConfirm(
                    context,
                    title: s.delete_account,
                    desc: s.delete_account_confirm,
                    dialogType: DialogType.error,
                    btnOkText: s.delete,
                    btnOkColor: AppColors.error,
                    onConfirm: () async {
                      CustomDialogs.showLoading(context);
                      await controller.deleteAccount();
                    },
                  );
                },
              ),
            ],
          ),

          AppGaps.h32,
        ],
      ),
    );
  }
}
