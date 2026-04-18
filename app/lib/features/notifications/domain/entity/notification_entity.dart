import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String recipientId;
  final String senderId;
  final int resourceId;
  final String type;
  final String? title;
  final String? body;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.resourceId,
    required this.type,
    this.title,
    this.body,
    required this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    recipientId,
    senderId,
    resourceId,
    type,
    title,
    body,
    metadata,
    isRead,
    createdAt,
  ];
}
