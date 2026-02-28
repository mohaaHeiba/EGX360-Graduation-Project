import 'dart:convert';
import 'package:egx/core/errors/app_exception.dart';
import 'package:egx/features/notifications/data/model/notification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  });
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead(String userId);

  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabase;

  NotificationRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await supabase
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      return (response as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    } catch (e) {
      throw DatabaseAppException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw DatabaseAppException(e.toString());
    }
  }

  /// Mark all notifications as read for the current user
  Future<void> markAllAsRead(String userId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw DatabaseAppException(e.toString());
    }
  }

  @override
  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      final String serverKey = dotenv.env['FCM_SERVER_KEY'] ?? '';
      if (serverKey.isEmpty) {
        print("Error: FCM_SERVER_KEY is missing in .env");
        return;
      }

      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      };

      final payload = {
        'to': token,
        'notification': {'title': title, 'body': body},
        'data': data,
        'priority': 'high',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully: ${response.body}");
      } else {
        print(
          "Failed to send notification: ${response.statusCode} - ${response.body}",
        );
        throw UnknownAppException(
          "Failed to send notification: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error sending notification: $e");
      throw UnknownAppException("Error sending notification: $e");
    }
  }
}
