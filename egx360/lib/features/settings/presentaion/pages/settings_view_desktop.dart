import 'package:egx/features/settings/presentaion/controller/settings_controller.dart';
import 'package:egx/features/settings/presentaion/pages/app_settings_page.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsViewDesktop extends GetView<SettingsController> {
  const SettingsViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 20,
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            if (Navigator.canPop(context))
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                            Text(
                              "Settings",
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: AppSettingsPage.buildSettingsContent(
                          context,
                          controller,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
