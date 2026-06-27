import 'package:egx/features/chatbot/domain/entities/chatbot_trending_context.dart';
import 'package:egx/features/chatbot/domain/entities/technical_table_data.dart';

class ChatbotContextData {
  final Map<String, dynamic>? wallet;
  final List<Map<String, dynamic>>? holdings;
  final List<Map<String, dynamic>>? news;
  final List<dynamic>? prices;
  final List<Map<String, dynamic>>? trendingStocks;
  final List<Map<String, dynamic>>? trendingCrypto;
  final ChatbotTrendingContext? trendingContext;
  final double? currentUsdPrice;
  final List<Map<String, dynamic>>? protectionRules;
  final List<Map<String, dynamic>>? portfolioPredictions;
  final List<Map<String, dynamic>>? pulse;
  final Map<String, TechnicalTableData>? stockDetails;
  final TechnicalTableData? analytics;
  
  // Simulation Totals
  final double? totalPortfolioValue;
  final double? totalProfitLoss;
  final double? totalProfitLossPercent;

  ChatbotContextData({
    this.wallet,
    this.holdings,
    this.news,
    this.prices,
    this.trendingStocks,
    this.trendingCrypto,
    this.trendingContext,
    this.currentUsdPrice,
    this.protectionRules,
    this.portfolioPredictions,
    this.pulse,
    this.stockDetails,
    this.analytics,
    this.totalPortfolioValue,
    this.totalProfitLoss,
    this.totalProfitLossPercent,
  });

  bool get isEmpty =>
      wallet == null &&
      holdings == null &&
      news == null &&
      prices == null &&
      trendingStocks == null &&
      trendingCrypto == null &&
      trendingContext == null &&
      currentUsdPrice == null &&
      protectionRules == null &&
      portfolioPredictions == null &&
      pulse == null &&
      stockDetails == null &&
      analytics == null;
}
