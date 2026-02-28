import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Helper to check if we're on a desktop platform
  bool get _isDesktopPlatform =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  Future<bool> requestMicrophone() async {
    // Desktop platforms don't need runtime permissions
    if (_isDesktopPlatform) {
      print("Microphone permission auto-granted on desktop platform");
      return true;
    }
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> requestNotification() async {
    // Desktop platforms don't need runtime permissions
    if (_isDesktopPlatform) {
      print("Notification permission auto-granted on desktop platform");
      return true;
    }
    var status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> requestAll() async {
    await requestMicrophone();
    await requestNotification();
    // await requestCamera();
  }

  Future<bool> get isMicrophoneGranted async {
    if (_isDesktopPlatform) return true;
    return await Permission.microphone.isGranted;
  }

  Future<bool> get isNotificationGranted async {
    if (_isDesktopPlatform) return true;
    return await Permission.notification.isGranted;
  }

  Future<bool> openSettings() async {
    if (_isDesktopPlatform) {
      print("Settings not available on desktop platform");
      return false;
    }
    return await openAppSettings();
  }
}
