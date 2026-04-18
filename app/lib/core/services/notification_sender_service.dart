import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

/// Client-Side FCM Push Notification Sender
/// Uses service_account.json from assets for OAuth2 authentication
class NotificationSenderService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Cache for access token
  static String? _cachedAccessToken;
  static DateTime? _tokenExpiry;

  // FCM v1 API endpoint
  static String get _fcmUrl =>
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
  static String? _projectId;

  /// Load service account and get OAuth2 access token
  static Future<String> _getAccessToken() async {
    // Return cached token if still valid
    if (_cachedAccessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedAccessToken!;
    }

    try {
      // Load service account JSON from assets
      final jsonString = await rootBundle.loadString(
        'assets/data/service_account.json',
      );
      final serviceAccount = json.decode(jsonString);

      // Cache project ID
      _projectId = serviceAccount['project_id'];

      // Create service account credentials
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(
        serviceAccount,
      );

      // Get access token
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await auth.clientViaServiceAccount(
        accountCredentials,
        scopes,
      );

      final accessToken = client.credentials.accessToken.data;
      final expiry = client.credentials.accessToken.expiry;

      // Cache token
      _cachedAccessToken = accessToken;
      _tokenExpiry = expiry;

      client.close();

      print('✅ Got FCM access token (expires: $expiry)');
      return accessToken;
    } catch (e) {
      print('❌ Error getting access token: $e');
      rethrow;
    }
  }

  /// Send FCM push notification using HTTP v1 API
  static Future<bool> sendFCMNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final message = {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          'data': data ?? {},
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': 'social_notifications',
              'color': '#1E88E5',
              'sound': 'default',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              if (imageUrl != null) 'image': imageUrl,
            },
          },
          'apns': {
            'payload': {
              'aps': {'sound': 'default', 'badge': 1, 'mutable-content': 1},
            },
            if (imageUrl != null) 'fcm_options': {'image': imageUrl},
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('✅ FCM notification sent successfully');
        return true;
      } else {
        print('❌ FCM HTTP error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending FCM notification: $e');
      return false;
    }
  }

  /// Notify the post owner when someone comments on their post
  static Future<void> notifyPostOwner({
    required String ownerId,
    required String senderName,
    required int postId,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == ownerId) {
        print('⏭️ Skipping notification (user commented on own post)');
        return;
      }

      final response = await _supabase
          .from('profiles')
          .select('fcm_token, name')
          .eq('id', ownerId)
          .single();

      final fcmToken = response['fcm_token'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        print('⚠️ No FCM token found for user $ownerId');
        return;
      }

      await sendFCMNotification(
        token: fcmToken,
        title: '💬 New Comment',
        body: '$senderName commented on your post',
        data: {
          'type': 'comment',
          'post_id': postId.toString(),
          'sender_name': senderName,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      );

      print('📤 Notification sent to post owner');
    } catch (e) {
      print('❌ Error notifying post owner: $e');
    }
  }

  /// Notify all followers when a user creates a new post
  static Future<void> notifyAllFollowers({
    required String currentUserId,
    required String currentUserName,
    required int postId,
    String? postPreview,
    String? postImageUrl,
  }) async {
    try {
      final followersResponse = await _supabase
          .from('follows')
          .select('follower_id')
          .eq('following_id', currentUserId);

      if (followersResponse.isEmpty) {
        print('ℹ️ No followers to notify');
        return;
      }

      final followerIds = (followersResponse as List)
          .map((e) => e['follower_id'] as String)
          .toList();

      print('📊 Found ${followerIds.length} followers to notify');

      final tokensResponse = await _supabase
          .from('profiles')
          .select('fcm_token')
          .inFilter('id', followerIds)
          .not('fcm_token', 'is', null);

      if (tokensResponse.isEmpty) {
        print('⚠️ No FCM tokens found for followers');
        return;
      }

      final tokens = (tokensResponse as List)
          .map((e) => e['fcm_token'] as String)
          .where((token) => token.isNotEmpty)
          .toList();

      print('📤 Sending notifications to ${tokens.length} devices...');

      final preview = postPreview != null && postPreview.length > 30
          ? '${postPreview.substring(0, 30)}...'
          : postPreview ?? 'shared a new post';

      int successCount = 0;
      for (final token in tokens) {
        final success = await sendFCMNotification(
          token: token,
          title: '✨ New Post',
          body: '$currentUserName $preview',
          imageUrl: postImageUrl,
          data: {
            'type': 'new_post',
            'post_id': postId.toString(),
            'sender_id': currentUserId,
            'sender_name': currentUserName,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        );

        if (success) successCount++;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      print('✅ Notifications sent: $successCount/${tokens.length}');
    } catch (e) {
      print('❌ Error notifying followers: $e');
    }
  }

  /// Notify comment owner when someone replies to their comment
  static Future<void> notifyCommentOwner({
    required String commentOwnerId,
    required String senderName,
    required int postId,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == commentOwnerId) {
        print('⏭️ Skipping notification (user replied to own comment)');
        return;
      }

      final response = await _supabase
          .from('profiles')
          .select('fcm_token')
          .eq('id', commentOwnerId)
          .single();

      final fcmToken = response['fcm_token'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        print('⚠️ No FCM token found for comment owner');
        return;
      }

      await sendFCMNotification(
        token: fcmToken,
        title: '↩️ New Reply',
        body: '$senderName replied to your comment',
        data: {
          'type': 'reply',
          'post_id': postId.toString(),
          'sender_name': senderName,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      );

      print('📤 Reply notification sent');
    } catch (e) {
      print('❌ Error notifying comment owner: $e');
    }
  }

  /// Notify post owner when someone likes their post
  static Future<void> notifyPostLike({
    required String postOwnerId,
    required String senderName,
    required int postId,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == postOwnerId) {
        return;
      }

      final response = await _supabase
          .from('profiles')
          .select('fcm_token')
          .eq('id', postOwnerId)
          .single();

      final fcmToken = response['fcm_token'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      await sendFCMNotification(
        token: fcmToken,
        title: '❤️ New Like',
        body: '$senderName liked your post',
        data: {
          'type': 'like',
          'post_id': postId.toString(),
          'sender_name': senderName,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      );
    } catch (e) {
      print('❌ Error notifying post like: $e');
    }
  }

  /// Notify user when someone follows them
  static Future<void> notifyNewFollow({
    required String followedUserId,
    required String followerName,
    required String followerId,
  }) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('fcm_token')
          .eq('id', followedUserId)
          .single();

      final fcmToken = response['fcm_token'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      await sendFCMNotification(
        token: fcmToken,
        title: '👤 New Follower',
        body: '$followerName started following you',
        data: {
          'type': 'follow',
          'follower_id': followerId,
          'follower_name': followerName,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      );
    } catch (e) {
      print('❌ Error notifying new follow: $e');
    }
  }
}
