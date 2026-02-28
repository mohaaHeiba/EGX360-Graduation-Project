// lib/features/stock_chat/data/repositories/stock_chat_repository_impl.dart
import 'package:egx/features/stock_chat/domian/entities/chat_message.dart';
import 'package:egx/features/stock_chat/domian/repositories/stock_chat_repository.dart';

import '../datasources/stock_chat_remote_datasource.dart';

class StockChatRepositoryImpl implements StockChatRepository {
  final StockChatRemoteDataSource remoteDataSource;

  StockChatRepositoryImpl(this.remoteDataSource);

  // lib/features/stock_chat/data/repositories/stock_chat_repository_impl.dart

  @override
  Stream<List<ChatMessage>> getChatStream(String stockId) {
    return remoteDataSource.getChatStream(stockId).map((models) {
      // هنا بنحول الـ List<ChatMessageModel> لـ List<ChatMessage>
      return models.cast<ChatMessage>();
    });
  }

  @override
  Future<void> sendMessage({
    required String stockId,
    required String message,
  }) async {
    await remoteDataSource.sendMessage(stockId: stockId, message: message);
  }
}
