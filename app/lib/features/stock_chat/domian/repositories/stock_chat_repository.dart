// lib/features/stock_chat/domain/repositories/stock_chat_repository.dart
import '../entities/chat_message.dart';

abstract class StockChatRepository {
  Stream<List<ChatMessage>> getChatStream(String stockId);
  Future<void> sendMessage({required String stockId, required String message});
}
