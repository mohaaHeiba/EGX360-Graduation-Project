import 'package:egx/features/stock_chat/data/model/chat_message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class StockChatRemoteDataSource {
  Stream<List<ChatMessageModel>> getChatStream(String stockId);
  Future<void> sendMessage({required String stockId, required String message});
}

class StockChatRemoteDataSourceImpl implements StockChatRemoteDataSource {
  final SupabaseClient supabaseClient;

  StockChatRemoteDataSourceImpl(this.supabaseClient);

  @override
  Stream<List<ChatMessageModel>> getChatStream(String stockId) {
    // ميزة Supabase القوية: Stream
    // بترجع داتا كل ما يحصل تغيير في الجدول
    return supabaseClient
        .from('stock_messages')
        .stream(primaryKey: ['id'])
        .eq(
          'stock_id',
          int.parse(stockId),
        ) // فلتر بالسهم المحدد (Converted to int)
        .order(
          'created_at',
          ascending: false,
        ) // رتب من الجديد للقديم (عشان ListView reverse: true)
        .map((data) {
          print("Received chat update: ${data.length} messages");
          return data.map((json) => ChatMessageModel.fromJson(json)).toList();
        });
  }

  @override
  Future<void> sendMessage({
    required String stockId,
    required String message,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await supabaseClient.from('stock_messages').insert({
      'stock_id': int.parse(stockId), // Converted to int
      'user_id': user.id,
      'content': message,
      // 'username': user.userMetadata?['name'] ?? 'Unknown', // Optional: Add username if available
    });
  }
}
