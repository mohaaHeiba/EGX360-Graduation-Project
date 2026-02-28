import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/profile/domain/usecase/get_user_profile_usecase.dart';
import 'package:egx/features/stock_chat/data/model/chat_message_model.dart';
import 'package:egx/features/stock_chat/domian/entities/chat_message.dart';
import 'package:egx/features/stock_chat/domian/usecases/get_chat_stream_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockChatController extends GetxController {
  // UseCases
  final GetChatStreamUseCase getChatStreamUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;

  // المتغيرات اللي جاية من بره (زي الـ arguments)
  final String stockId;

  StockChatController({
    required this.getChatStreamUseCase,
    required this.sendMessageUseCase,
    required this.getUserProfileUseCase,
    required this.stockId,
  });

  String get currentUserId => Supabase.instance.client.auth.currentUser!.id;

  // قائمة الرسائل (Reactive)
  RxList<ChatMessage> messages = <ChatMessage>[].obs;

  // Cache for user profiles
  RxMap<String, AuthEntity> userProfiles = <String, AuthEntity>{}.obs;

  // للتحكم في حقل النص
  TextEditingController messageController = TextEditingController();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // السحر بتاع GetX: اربط المتغير بالستريم مباشرة
    messages.bindStream(
      getChatStreamUseCase(stockId).map((list) {
        final castedList = list.cast<ChatMessage>();
        _fetchMissingProfiles(castedList);
        return castedList;
      }),
    );
  }

  void _fetchMissingProfiles(List<ChatMessage> msgs) {
    final userIds = msgs.map((m) => m.userId).toSet();
    for (final uid in userIds) {
      if (!userProfiles.containsKey(uid)) {
        // Fetch profile
        getUserProfileUseCase(uid)
            .then((profile) {
              userProfiles[uid] = profile;
            })
            .catchError((e) {
              // print("Error fetching profile for $uid: $e");
            });
      }
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();

    // 1. Optimistic Update: Show message immediately
    final tempId = DateTime.now().millisecondsSinceEpoch;
    // Use ChatMessageModel to avoid type errors if the list expects subtypes
    final tempMessage = ChatMessageModel(
      id: tempId, // Temporary ID
      stockId: stockId,
      userId: currentUserId,
      message: text,
      createdAt: DateTime.now(),
    );

    messages.insert(0, tempMessage); // Add to top (since list is reversed)

    try {
      await sendMessageUseCase(stockId, text);
      // Success: The stream will eventually update the list with the real message
      // We don't need to remove the temp message manually because the stream update will replace the whole list
      // BUT, to avoid duplication if the stream is fast, we might want to handle it.
      // However, since bindStream replaces the list, it should be fine.
    } catch (e) {
      // Failure: Remove the temp message
      messages.removeWhere((msg) => msg.id == tempId);
      Get.snackbar("Error", "Failed to send message: $e");
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
