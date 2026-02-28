import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationsController extends GetxController
    with WidgetsBindingObserver {
  final PermissionService _permissionService = PermissionService();
  final box = GetStorage();

  final RxBool isSystemNotificationsEnabled = false.obs;
  final RxBool marketAlerts = true.obs;
  final RxBool newsUpdates = true.obs;
  final RxBool appUpdates = false.obs;
  final RxBool soundEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadSettings();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkSystemPermission();
    }
  }

  void loadSettings() async {
    marketAlerts.value = box.read('marketAlerts') ?? true;
    newsUpdates.value = box.read('newsUpdates') ?? true;
    appUpdates.value = box.read('appUpdates') ?? false;
    soundEnabled.value = box.read('soundEnabled') ?? true;
    await checkSystemPermission();
  }

  Future<void> checkSystemPermission() async {
    bool granted = await _permissionService.isNotificationGranted;
    isSystemNotificationsEnabled.value = granted;
  }

  Future<void> toggleSystemNotifications(bool value) async {
    if (value) {
      bool granted = await _permissionService.requestNotification();
      isSystemNotificationsEnabled.value = granted;
      if (!granted) await _permissionService.openSettings();
    } else {
      final s = Get.context!.s;
      customSnackbar(
        title: s.system_settings,
        message: s.disable_notifications_message,
        color: AppColors.warning,
      );
      await _permissionService.openSettings();
    }
    await checkSystemPermission();
  }

  void updateSetting(String key, bool val, RxBool variable) {
    variable.value = val;
    box.write(key, val);
  }

  void muteAll() {
    updateSetting('marketAlerts', false, marketAlerts);
    updateSetting('newsUpdates', false, newsUpdates);
    updateSetting('appUpdates', false, appUpdates);
    updateSetting('soundEnabled', false, soundEnabled);
    final s = Get.context!.s;
    customSnackbar(
      title: s.muted,
      message: s.all_alerts_muted,
      color: AppColors.success,
    );
  }
}
