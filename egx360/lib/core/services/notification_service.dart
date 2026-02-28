import 'dart:convert';
import 'dart:io';
import 'package:egx/core/routes/app_pages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Note: You cannot use GetX navigation here directly as the app might be in the background/terminated.
  // Navigation is handled when the user taps the notification.
}

class NotificationService {
  static FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  static Future<void> init() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'egx360_notifications', // id
      'General Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
      playSound: true,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Background state (App opened from background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message);
    });
  }

  // Call this from your main App widget or Home controller after GetMaterialApp is mounted
  static Future<void> checkInitialMessage() async {
    // Skip on unsupported platforms
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      print("checkInitialMessage skipped: Not supported on desktop platforms");
      return;
    }

    print("Checking for initial message (Terminated state)...");
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      print("Found initial message: ${initialMessage.messageId}");
      // Small delay to ensure GetX is fully ready
      await Future.delayed(const Duration(milliseconds: 500));
      handleNotificationTap(initialMessage);
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      Get.snackbar(
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? '',
        onTap: (_) => handleNotificationTap(message),
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  static void handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    print("DEBUG: handleNotificationTap called with data: $data");

    final type = data['type'];
    print("DEBUG: Notification Type: $type");

    // Parse metadata if it's a JSON string, or use data directly if keys are flat
    Map<String, dynamic> metadata = {};
    if (data['metadata'] != null && data['metadata'] is String) {
      try {
        metadata = jsonDecode(data['metadata']);
      } catch (e) {
        print("Error parsing metadata json: $e");
      }
    } else {
      metadata = data;
    }

    print("DEBUG: Parsed Metadata: $metadata");

    if (type == 'comment' || type == 'reply' || type == 'like') {
      final postIdStr =
          metadata['post_id']?.toString() ?? data['post_id']?.toString();

      print("DEBUG: Extracted Post ID String: $postIdStr");

      if (postIdStr != null) {
        final postId = int.tryParse(postIdStr);
        print("DEBUG: Parsed Post ID int: $postId");

        if (postId != null) {
          print(
            "DEBUG: Navigating to ${AppPages.showDetailsPage} with postId: $postId",
          );
          Get.toNamed(AppPages.showDetailsPage, arguments: {'postId': postId});
        } else {
          print("DEBUG: Failed to parse postId to int");
        }
      } else {
        print("DEBUG: Post ID is null");
      }
    } else if (type == 'follow') {
      final followerId =
          metadata['follower_id']?.toString() ??
          data['follower_id']?.toString();
      if (followerId != null) {
        Get.toNamed(
          AppPages.userProfilePage,
          arguments: {'userId': followerId},
        );
      }
    }
  }

  // Get Token
  static Future<String?> getToken() async {
    // Skip on unsupported platforms
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      print("FCM Token not available on desktop platforms");
      return null;
    }

    try {
      return await _fcm.getToken();
    } catch (e) {
      print("Error getting FCM token: $e");
      return null;
    }
  }
}
