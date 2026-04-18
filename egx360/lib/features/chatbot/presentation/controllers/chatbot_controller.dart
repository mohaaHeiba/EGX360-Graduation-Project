import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/features/chatbot/data/chatbot_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotController extends GetxController {
  final ChatbotService _service = ChatbotService();

  // ── Observable state ────────────────────────────────────────────
  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;
  final errorMessage = ''.obs;

  // ── Controllers / nodes ─────────────────────────────────────────
  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  // ── Sliding history window (last 12 entries = 6 turns) ──────────
  final List<Map<String, String>> _history = [];

  // ── User identity from InitLocalData ────────────────────────────
  String get _userId => Get.find<InitLocalData>().currentUser.value?.id ?? '';
  String get _userName =>
      Get.find<InitLocalData>().currentUser.value?.name ?? 'Investor';

  bool get isEmpty => messages.isEmpty && !isTyping.value;

  // ── Predefined action chips ─────────────────────────────────────
  final List<String> suggestions = const [
    '☀️ Get My Daily Summary',
    '📊 How is my portfolio doing?',
    '💰 Did I gain or lose today?',
    '📰 What\'s the latest market news?',
    '🌐 What does the community think?',
    '🤖 AI predictions for my stocks?',
    '🛡️ Show my protection rules',
  ];

  // ═══════════════════════════════════════════════════════════════
  // SEND MESSAGE
  // ═══════════════════════════════════════════════════════════════

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isTyping.value) return;

    inputController.clear();
    errorMessage.value = '';

    // Add user bubble
    messages.add(
      ChatMessage(text: trimmed, isUser: true, timestamp: DateTime.now()),
    );
    _history.add({'role': 'user', 'content': trimmed});

    isTyping.value = true;
    _scrollToBottom();

    try {
      final response = await _service.chat(
        userId: _userId,
        userName: _userName,
        userMessage: trimmed,
        conversationHistory: List.from(_history),
      );

      messages.add(
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
      _history.add({'role': 'assistant', 'content': response});

      // Keep history at max 12 entries (6 turns)
      if (_history.length > 12) {
        _history.removeRange(0, _history.length - 12);
      }
    } on Exception catch (e) {
      final errText = _friendlyError(e.toString());
      errorMessage.value = errText;
      messages.add(
        ChatMessage(text: errText, isUser: false, timestamp: DateTime.now()),
      );
    } finally {
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  // Quick daily summary shortcut
  Future<void> sendDailySummary() => sendMessage(
    'عايز ملخص يومي كامل: وضع محفظتي مع الأرباح والخسائر، '
    'أخبار السوق، رأي المجتمع، وتوقعات الذكاء الاصطناعي.',
  );

  void clearChat() {
    messages.clear();
    _history.clear();
    errorMessage.value = '';
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _friendlyError(String raw) {
    if (raw.contains('timeout') || raw.contains('TimeoutException')) {
      return '⏱️ **انتهت مدة الانتظار.**\nالذكاء الاصطناعي بطيء شوية، حاول تاني بعد لحظة.';
    }
    if (raw.contains('SocketException') || raw.contains('Network')) {
      return '📡 **مفيش إنترنت.**\nتأكد من اتصالك وحاول تاني.';
    }
    if (raw.contains('401') || raw.contains('Unauthorized')) {
      return '🔑 **خطأ في مفتاح API.** تواصل مع الدعم.';
    }
    return '⚠️ **حصل خطأ غير متوقع.**\nحاول تاني بعد لحظة.';
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
