class ChatbotTrendingContext {
  final List<Map<String, dynamic>> egxTrending;
  final List<Map<String, dynamic>> globalTrending;

  ChatbotTrendingContext({
    required this.egxTrending,
    required this.globalTrending,
  });

  bool get isEmpty => egxTrending.isEmpty && globalTrending.isEmpty;
}
