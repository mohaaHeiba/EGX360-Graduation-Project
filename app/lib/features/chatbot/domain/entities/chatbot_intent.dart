enum ChatIntentType {
  portfolioDeepDive,
  generalMarketSummary,
  specificStock,
  generalChat,
  unknown
}

class ChatbotIntent {
  final ChatIntentType type;
  final List<String> symbols; // e.g., ['TMGH']
  final double? investmentAmount;
  final String? riskTolerance;
  final String? detectedLanguage;
  final String originalMessage;

  ChatbotIntent({
    required this.type, 
    this.symbols = const [], 
    this.investmentAmount,
    this.riskTolerance,
    this.detectedLanguage,
    required this.originalMessage,
  });

  @override
  String toString() => 'ChatbotIntent(type: $type, symbols: $symbols, lang: $detectedLanguage, amount: $investmentAmount)';
}
