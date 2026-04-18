// lib/features/stock_chat/domain/usecases/get_chat_stream_usecase.dart
import 'package:egx/features/stock_chat/domian/entities/chat_message.dart';
import 'package:egx/features/stock_chat/domian/repositories/stock_chat_repository.dart';

class GetChatStreamUseCase {
  final StockChatRepository repository;
  GetChatStreamUseCase(this.repository);

  Stream<List<ChatMessage>> call(String stockId) =>
      repository.getChatStream(stockId);
}

// lib/features/stock_chat/domain/usecases/send_message_usecase.dart
class SendMessageUseCase {
  final StockChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<void> call(String stockId, String message) async {
    return await repository.sendMessage(stockId: stockId, message: message);
  }
}
