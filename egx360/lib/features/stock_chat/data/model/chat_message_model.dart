// lib/features/stock_chat/data/model/chat_message_model.dart

// 1. لازم تعمل import للـ Entity
import 'package:egx/features/stock_chat/domian/entities/chat_message.dart';

// 2. لازم تضيف extends ChatMessage
class ChatMessageModel extends ChatMessage {
  // نفس المتغيرات مش محتاج تعرفها تاني لأنها موجودة في الأب (ChatMessage)
  // بس محتاج تمررها للـ super constructor

  ChatMessageModel({
    required int id,
    required String stockId,
    required String userId,
    required String message,
    required DateTime createdAt,
  }) : super(
         // تمرير البيانات للكلاس الأب
         id: id,
         stockId: stockId,
         userId: userId,
         message: message,
         createdAt: createdAt,
       );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      stockId: json['stock_id'].toString(), // Converted to String
      userId: json['user_id'],
      message: json['content'], // Mapped from 'content' column
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // toMap أو toJson
  Map<String, dynamic> toJson() {
    return {'stock_id': stockId, 'user_id': userId, 'message': message};
  }
}
