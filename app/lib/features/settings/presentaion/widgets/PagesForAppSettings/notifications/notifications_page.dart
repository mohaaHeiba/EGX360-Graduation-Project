import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:egx/features/settings/presentaion/controller/notifications_controller.dart';
import 'package:egx/features/settings/presentaion/widgets/app_settings_widgets/modern_settings_section.dart';
import 'package:egx/core/custom/custom_appbar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    final theme = Theme.of(context);
    final s = context.s;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppbar(() => Get.back(), s.notifications),

      body: Obx(() {
        final systemEnabled = controller.isSystemNotificationsEnabled.value;

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            ModernSettingsSection(
              title: s.general_section,
              items: [
                SettingItem(
                  icon: Icons.notifications_active_rounded,
                  title: s.allow_notifications,
                  subtitle: systemEnabled
                      ? s.system_notifications_on
                      : s.tap_to_enable,
                  iconColor: systemEnabled ? null : theme.disabledColor,
                  trailing: Switch(
                    value: systemEnabled,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) =>
                        controller.toggleSystemNotifications(val),
                  ),
                ),
              ],
            ),

            AppGaps.h20,
            IgnorePointer(
              ignoring: !systemEnabled,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: systemEnabled ? 1.0 : 0.5,
                child: Column(
                  children: [
                    ModernSettingsSection(
                      title: s.categories_section,
                      items: [
                        SettingItem(
                          icon: Icons.show_chart_rounded,
                          title: s.market_alerts,
                          subtitle: s.market_alerts_subtitle,
                          trailing: Switch(
                            value: controller.marketAlerts.value,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (val) => controller.updateSetting(
                              'marketAlerts',
                              val,
                              controller.marketAlerts,
                            ),
                          ),
                        ),
                        SettingItem(
                          icon: Icons.article_outlined,
                          title: s.news_updates,
                          subtitle: s.news_updates_subtitle,
                          trailing: Switch(
                            value: controller.newsUpdates.value,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (val) => controller.updateSetting(
                              'newsUpdates',
                              val,
                              controller.newsUpdates,
                            ),
                          ),
                        ),
                        SettingItem(
                          icon: Icons.system_update_alt_rounded,
                          title: s.app_updates,
                          subtitle: s.app_updates_subtitle,
                          trailing: Switch(
                            value: controller.appUpdates.value,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (val) => controller.updateSetting(
                              'appUpdates',
                              val,
                              controller.appUpdates,
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppGaps.h20,

                    ModernSettingsSection(
                      title: s.sounds_alerts_section,
                      items: [
                        SettingItem(
                          icon: Icons.volume_up_rounded,
                          title: s.notification_sounds,
                          subtitle: s.notification_sounds_subtitle,
                          trailing: Switch(
                            value: controller.soundEnabled.value,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (val) => controller.updateSetting(
                              'soundEnabled',
                              val,
                              controller.soundEnabled,
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppGaps.h32,

                    ElevatedButton.icon(
                      onPressed: () => controller.muteAll(),
                      icon: Icon(
                        Icons.notifications_off_outlined,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        s.mute_all_alerts,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        side: BorderSide(
                          color: theme.colorScheme.error.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
