import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/settings/presentaion/widgets/app_settings_widgets/modern_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActiveSessionsPage extends StatelessWidget {
  const ActiveSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;

    // ✅ Map for session info
    final Map<String, dynamic> session = {
      'device': s.this_device,
      'location': s.location_egypt,
      'lastActive': s.last_active_now,
      'isCurrent': true,
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: customAppbar(() => Get.back(), s.active_sessions),
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            s.active_sessions_description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          AppGaps.h24,

          ModernSettingsSection(
            title: s.current_session_section,
            items: [
              SettingItem(
                icon: Icons.smartphone_rounded,
                iconColor: theme.colorScheme.primary,
                title: session['device'],
                subtitle:
                    "${session['location']} • Last active: ${session['lastActive']}",
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.session_active,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
