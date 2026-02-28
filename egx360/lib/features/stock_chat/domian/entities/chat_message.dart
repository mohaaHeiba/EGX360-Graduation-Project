// lib/features/stock_chat/domain/entities/chat_message.dart
class ChatMessage {
  final int id;
  final String stockId;
  final String userId;
  final String message;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.stockId,
    required this.userId,
    required this.message,
    required this.createdAt,
  });
}
