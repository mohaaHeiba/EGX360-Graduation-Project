import 'package:egx/features/notifications/domain/entity/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    required super.senderId,
    required super.resourceId,
    required super.type,
    super.title,
    super.body,
    required super.metadata,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      recipientId: json['recipient_id'] as String,
      senderId: json['sender_id'] as String,
      resourceId: json['resource_id'] as int,
      type: json['type'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'sender_id': senderId,
      'resource_id': resourceId,
      'type': type,
      'title': title,
      'body': body,
      'metadata': metadata,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
