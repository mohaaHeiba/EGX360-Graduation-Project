import 'package:egx/features/chatbot/domain/entities/chatbot_context_data.dart';
import 'package:egx/features/chatbot/domain/entities/chatbot_intent.dart';
import 'package:egx/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:egx/features/chatbot/domain/entities/technical_table_data.dart';

class GetContextualDataUseCase {
  final ChatbotRepository repository;

  GetContextualDataUseCase(this.repository);

  Future<ChatbotContextData> call(String userId, ChatbotIntent intent) async {
    final futures = <String, Future<dynamic>>{};



    switch (intent.type) {
      case ChatIntentType.portfolioDeepDive:
        futures['usdPrice'] = repository.getUsdRate();
        final holdings = await repository.getHoldings(userId);
        final symbols = holdings.map((h) => h['ticker'] as String? ?? h['symbol'] as String).toList();
        futures['holdings'] = Future.value(holdings);
        futures['wallet'] = repository.getWallet(userId);
        futures['news'] = repository.getStockNews(symbols: symbols, limit: 8);
        
        if (symbols.isNotEmpty) {
          futures['portfolioPredictions'] = repository.getPortfolioAiPredictions(symbols);
        }
        break;

      case ChatIntentType.generalMarketSummary:
        futures['usdPrice'] = repository.getUsdRate();
        futures['trendingContext'] = repository.getUnifiedTrendingData();
        futures['news'] = repository.getStockNews(limit: 5);
        futures['pulse'] = repository.getCommunityPulse();
        break;

      case ChatIntentType.specificStock:
        futures['usdPrice'] = repository.getUsdRate();
        if (intent.symbols.isNotEmpty) {
          final symbolsToFetch = intent.symbols.take(3).toList();
          futures['news'] = repository.getStockNews(symbols: symbolsToFetch, limit: 3);
          futures['stockDetails'] = Future.wait(
            symbolsToFetch.map((s) => repository.getTechnicalAnalysis(s))
          ).then((tables) {
            final map = <String, TechnicalTableData>{};
            for (var i = 0; i < symbolsToFetch.length; i++) {
              if (tables[i] != null) {
                map[symbolsToFetch[i]] = tables[i]!;
              }
            }
            return map;
          });
        } else {
          futures['trendingContext'] = repository.getUnifiedTrendingData();
        }
        break;

      case ChatIntentType.generalChat:
        // No heavy data needed — greetings and educational questions use general knowledge
        break;

      case ChatIntentType.unknown:
        futures['usdPrice'] = repository.getUsdRate();
        futures['trendingContext'] = repository.getUnifiedTrendingData();
        futures['pulse'] = repository.getCommunityPulse();
        break;
    }

    if (futures.isEmpty) return ChatbotContextData();

    // Wrap each future so one failure doesn't kill all results
    final safeFutures = futures.map((key, future) {
      return MapEntry(key, future.catchError((e) {
        print('⚠️ [Chatbot RAG] Failed to fetch $key: $e');
        return null;
      }));
    });

    final results = await Future.wait(safeFutures.values);
    final resultMap = <String, dynamic>{};
    int i = 0;
    for (var key in safeFutures.keys) {
      resultMap[key] = results[i++];
    }

    return ChatbotContextData(
      wallet: resultMap['wallet'],
      holdings: resultMap['holdings'],
      news: resultMap['news'],
      prices: resultMap['prices'],
      trendingStocks: resultMap['trendingStocks'],
      trendingCrypto: resultMap['trendingCrypto'],
      trendingContext: resultMap['trendingContext'],
      currentUsdPrice: resultMap['usdPrice'],
      protectionRules: resultMap['protectionRules'],
      portfolioPredictions: resultMap['portfolioPredictions'],
      pulse: resultMap['pulse'],
      analytics: resultMap['analytics'],
      stockDetails: resultMap['stockDetails'],
    );
  }
}
