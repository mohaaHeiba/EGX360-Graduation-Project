import 'package:egx/features/chatbot/domain/entities/chatbot_trending_context.dart';
import 'package:egx/features/chatbot/domain/entities/technical_table_data.dart';

abstract class ChatbotRepository {
  /// Detects the user's intent using a small LLM call, returning a JSON-like map.
  Future<Map<String, dynamic>> detectIntentWithAi(String message, List<Map<String, dynamic>> assets);

  /// Fetch a list of all supported EGX stocks and valid Crypto USDT pairs.
  Future<List<Map<String, dynamic>>> fetchSupportedAssets();

  // ── User Context ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getWallet(String userId);

  Future<List<Map<String, dynamic>>> getHoldings(String userId);

  Future<List<Map<String, dynamic>>> getUserProtectionRules(String userId);

  // ── Market Data ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getStockNews({
    List<String>? symbols,
    int limit = 10,
  });

  Future<List<dynamic>> getMarketPrices({int limit = 50});

  Future<double> getUsdRate();

  Future<List<Map<String, dynamic>>> getTrendingStocks({int limit = 10});

  Future<List<Map<String, dynamic>>> getTrendingCrypto({int limit = 10});

  Future<ChatbotTrendingContext> getUnifiedTrendingData();

  Future<List<Map<String, dynamic>>> getCommunityPulse({int limit = 10});

  // ── AI & Analytics ──────────────────────────────────────────────────────────

  /// Returns a fully hydrated [TechnicalTableData] for a given symbol,
  /// or null if no prediction data exists.
  Future<TechnicalTableData?> getTechnicalAnalysis(String symbol);

  Future<List<Map<String, dynamic>>> getPortfolioAiPredictions(
    List<String> symbols,
  );

  // ── Response Generation ─────────────────────────────────────────────────────

  /// Assembles a surgical prompt and streams the LLM response token by token.
  Stream<String> generateFinalResponseStream({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>> history = const [],
  });
}
