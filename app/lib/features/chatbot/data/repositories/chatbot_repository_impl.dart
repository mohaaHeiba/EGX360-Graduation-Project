import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:egx/core/services/cerebras_ai_service.dart';
import 'package:egx/features/chatbot/data/datasources/chatbot_remote_datasource.dart';
import 'package:egx/features/chatbot/domain/entities/chatbot_intent.dart';
import 'package:egx/features/chatbot/domain/entities/chatbot_trending_context.dart';
import 'package:egx/features/chatbot/domain/entities/technical_table_data.dart';
import 'package:egx/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:egx/core/errors/app_exception.dart';

// Cross-feature repositories
import 'package:egx/features/simulation/domain/repositories/simulation_repository.dart';
import 'package:egx/features/home/domain/repositories/home_repository.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';
import 'package:egx/features/community/domain/repositories/community_repository.dart';
import 'package:egx/features/assets/domain/repositories/asset_repository.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource remoteDataSource;
  final CerebrasAiService aiService;
  final SimulationRepository simulationRepository;
  final HomeRepository homeRepository;
  final SearchRepository searchRepository;
  final CommunityRepository communityRepository;
  final AssetRepository assetRepository;

  ChatbotRepositoryImpl({
    required this.remoteDataSource,
    required this.aiService,
    required this.simulationRepository,
    required this.homeRepository,
    required this.searchRepository,
    required this.communityRepository,
    required this.assetRepository,
  });

  // ── Intent Detection ────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> detectIntentWithAi(String message, List<Map<String, dynamic>> assets) async {
    try {
      final String assetsStr = assets.map((a) => '${a['symbol']} (${a['company_name_en']} - ${a['company_name_ar']})').join(', ');
      final systemPrompt = '''
Role: You are the core Intent Analyzer, Language Detector, and Ticker Mapper for the EGX 360 financial system.

Context:
Below is the official list of supported stocks in our system. Each entry contains the Ticker Symbol, English Name, and Arabic Name.
[$assetsStr]

Instructions:
1. Read the user's message carefully.
2. Intent: Identify the core intent (`portfolio_review`, `new_investment`, `stock_analysis`, `market_news`, `general_chat`).
3. Ticker Mapping (CRITICAL): Extract any mentioned stocks. You MUST map the user's input (whether Arabic, English, or slang) to the exact official Ticker Symbol from the provided list.
   - Example: If the user says "سهم ابوقير" or "أبو قير", look at the list, find the match, and output ONLY "ABUK".
   - If the stock is NOT in the list, return the raw text the user typed.
4. Language: Detect the user's language (`ar` or `en`).
5. Budget: Extract any investment budget numbers (e.g., 50000). Return `null` if none.

Output Format (STRICTLY JSON):
Do not write any explanations, greetings, or text outside the JSON object.

{
  "intent": "string",
  "symbols": ["SYMBOL1", "SYMBOL2"],
  "budget_amount": number or null,
  "detected_language": "ar" or "en"
}

Examples:
User: "ايه رأيك في سهم ابوقير والتجاري الدولي؟"
Output: {"intent": "stock_analysis", "symbols": ["ABUK", "COMI"], "budget_amount": null, "detected_language": "ar"}

User: "I have 100k want to invest in Apple"
Output: {"intent": "new_investment", "symbols": ["AAPL"], "budget_amount": 100000, "detected_language": "en"}
''';
      final response = await aiService.generateCompletion(
        content: '',
        systemPrompt: systemPrompt,
        userPrompt: message,
        temperature: 0.1,
        maxTokens: 800,
      );

      final clean = response
          .trim()
          .replaceAll(RegExp(r'```json\n?'), '')
          .replaceAll(RegExp(r'```\n?'), '');
      final jsonResponse = jsonDecode(clean);

      ChatIntentType intentType = ChatIntentType.unknown;
      final String i = (jsonResponse['intent']?.toString() ?? '').toLowerCase();
      
      print('🧠 [Intent] AI returned intent: "$i", symbols: ${jsonResponse['symbols']}');

      if (i.contains('portfolio') || i.contains('deep') || i.contains('holdings')) {
        intentType = ChatIntentType.portfolioDeepDive;
      } else if (i.contains('news') || i.contains('summary') || i.contains('overview')) {
        intentType = ChatIntentType.generalMarketSummary;
      } else if (i.contains('stock') || i.contains('analy') || i.contains('specific') || i.contains('technical')) {
        intentType = ChatIntentType.specificStock;
      } else if (i.contains('chat') || i.contains('greet') || i.contains('general_chat') || i.contains('education')) {
        intentType = ChatIntentType.generalChat;
      } else if (i.contains('invest') || i.contains('allocat') || i.contains('budget')) {
        if (jsonResponse['symbols'] != null && (jsonResponse['symbols'] as List).isNotEmpty) {
          intentType = ChatIntentType.specificStock;
        } else {
          intentType = ChatIntentType.unknown;
        }
      }

      // SAFETY NET: If we still don't know the intent, but the AI found symbols,
      // the user definitely wants info about those specific stocks!
      if (intentType == ChatIntentType.unknown && 
          jsonResponse['symbols'] != null && 
          (jsonResponse['symbols'] as List).isNotEmpty) {
        intentType = ChatIntentType.specificStock;
        print('🧠 [Intent] Safety net triggered → specificStock for symbols: ${jsonResponse['symbols']}');
      }

      print('🧠 [Intent] Final intent: $intentType');
      jsonResponse['intent'] = intentType;
      return jsonResponse as Map<String, dynamic>;
    } on RateLimitException {
      rethrow;
    } catch (e) {
      print('❌ [Intent] Detection failed: $e');
      return {'intent': ChatIntentType.unknown};
    }
  }

  // ── Asset Discovery ─────────────────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> fetchSupportedAssets() async {
    return await remoteDataSource.fetchSupportedAssets();
  }

  // ── User Context ────────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>?> getWallet(String userId) async {
    print('🤖 [Chatbot RAG] Fetching wallet for user: $userId');
    final wallet = await simulationRepository.getWallet(userId);
    if (wallet == null) {
      print('⚠️ [Chatbot RAG] Wallet is empty or null.');
      return null;
    }
    
    final result = {
      'balance': wallet.balance,
      'initial_balance': wallet.initialBalance,
      'profit': wallet.balance - wallet.initialBalance,
      'profit_pct': wallet.initialBalance > 0
          ? ((wallet.balance - wallet.initialBalance) / wallet.initialBalance) * 100
          : 0.0,
    };
    print('✅ [Chatbot RAG] Wallet fetched: $result');
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getHoldings(String userId) async {
    try {
      print('🤖 [Chatbot RAG] Fetching holdings for user: $userId');
      final rawHoldings = await simulationRepository.getHoldings(userId);
      print('🤖 [Chatbot RAG] Found ${rawHoldings.length} raw holdings. Hydrating live prices...');
      final double rate = await getUsdRate();

      final holdingsWithLivePrices = await Future.wait(
        rawHoldings.map((h) async {
          final symbol = h.symbol.toUpperCase().trim();
          try {
            final stock = await searchRepository.getStockBySymbol(symbol);
            double currentPrice = stock.currentPrice ?? 0.0;
            final bool isUsd = _isUsdAsset(stock.sector, stock.candleTableName);

            if (isUsd && currentPrice > 0) currentPrice = currentPrice * rate;

            final double costBasis = h.quantity * h.averagePrice;
            final double currentValue =
                h.quantity * (currentPrice > 0 ? currentPrice : h.averagePrice);
            final double pnl = currentValue - costBasis;

            final double buyNative =
                h.averagePriceNative ?? (h.averagePrice / rate);
            final double nowNative =
                isUsd ? (stock.currentPrice ?? 0.0) : currentPrice;
            final double pnlNative = isUsd
                ? ((nowNative * h.quantity) - (buyNative * h.quantity))
                : pnl;

            return {
              'ticker': symbol,
              'qty': h.quantity,
              'buy_price': h.averagePrice,
              'now_price': currentPrice > 0 ? currentPrice : null,
              'buy_price_native': buyNative,
              'now_price_native': nowNative > 0 ? nowNative : null,
              'pnl': pnl,
              'pnl_native': pnlNative,
              'pnl_pct':
                  costBasis != 0 ? (pnl / costBasis) * 100 : 0.0,
              'is_usd': isUsd,
            };
          } catch (_) {
            return null;
          }
        }),
      );

      final result = holdingsWithLivePrices
          .whereType<Map<String, dynamic>>()
          .toList();
      print('✅ [Chatbot RAG] Successfully hydrated ${result.length} holdings with live prices.');
      return result;
    } catch (e) {
      print('❌ [Chatbot RAG] Error fetching holdings: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserProtectionRules(
      String userId) async {
    final rules = await simulationRepository.getProtectionRules(userId);
    return rules
        .map((r) => {'symbol': r.symbol, 'sl': r.alertPercentage})
        .toList();
  }

  // ── Market Data ─────────────────────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getStockNews({
    List<String>? symbols,
    int limit = 5,
  }) async {
    try {
      print('🤖 [Chatbot RAG] Fetching stock news for: ${symbols ?? "general"}');
      List news = [];
      if (symbols != null && symbols.isNotEmpty) {
        news = await searchRepository.getNewsForSymbols(symbols);
      } else {
        news = await searchRepository.getLatestNews(limit: limit);
      }

      // Filter to last 3 days; fall back to raw list if too strict
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      var recentNews = news.where((n) {
        try {
          return DateTime.parse(n.publishedAt).isAfter(threeDaysAgo);
        } catch (_) {
          return true;
        }
      }).toList();
      if (recentNews.isEmpty) recentNews = news.toList();

      // Cap at 2 news items per ticker
      final Map<String, int> stockCount = {};
      final List result = [];
      for (final n in recentNews) {
        final symbol = n.stock?.symbol ?? 'GENERAL';
        stockCount[symbol] = (stockCount[symbol] ?? 0) + 1;
        if (stockCount[symbol]! <= 2) result.add(n);
      }

      final mappedNews = result
          .map<Map<String, dynamic>>((n) => {
                'title': n.title,
                'sentiment': n.sentimentLabel ?? 'Neutral',
              })
          .toList();
          
      print('✅ [Chatbot RAG] Fetched ${mappedNews.length} news items.');
      return mappedNews;
    } catch (e) {
      print('❌ [Chatbot RAG] Error fetching news: $e');
      return [];
    }
  }

  @override
  Future<List<dynamic>> getMarketPrices({int limit = 50}) =>
      remoteDataSource.fetchMarketPrices();

  @override
  Future<List<Map<String, dynamic>>> getTrendingStocks(
      {int limit = 10}) async {
    final stocks = await homeRepository.getTrendingStocks(limit: limit);
    return stocks.map((s) {
      return {
        'symbol': s.symbol,
        'price': s.currentPrice,
        'change_pct': 0.0,
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingCrypto({int limit = 5}) =>
      remoteDataSource.fetchTrendingCrypto();

  Future<List<Map<String, dynamic>>> _getTrendingUSStocks() async {
    try {
      final usStocks =
          await searchRepository.getInitialStocks(category: 'US Stocks', limit: 5);
      final apiKey = dotenv.env['FINNHUB_API_KEY']!;
      final baseUrl = dotenv.env['FINNHUB_BASE_URL']!;
      final futures = usStocks.map((s) async {
        try {
          final res = await http.get(
              Uri.parse('$baseUrl/quote?symbol=${s.symbol}&token=$apiKey'));
          if (res.statusCode == 200) {
            final data = json.decode(res.body);
            return <String, dynamic>{
              'symbol': s.symbol,
              'price': double.tryParse(data['c'].toString()) ?? 0.0,
              'change_pct':
                  double.tryParse(data['dp'].toString()) ?? 0.0,
            };
          }
        } catch (_) {}
        return null;
      });
      final fetched = await Future.wait(futures);
      return fetched.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getMarketIndices() async {
    try {
      final indices =
          await searchRepository.getInitialStocks(category: 'Indices', limit: 5);
      return indices.map((s) {
        return {
          'symbol': s.symbol,
          'price': s.currentPrice,
          'change_pct': 0.0,
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ChatbotTrendingContext> getUnifiedTrendingData() async {
    print('🤖 [Chatbot RAG] Fetching unified trending data...');
    final results = await Future.wait([
      getTrendingStocks(limit: 20),
      getTrendingCrypto(),
      _getTrendingUSStocks(),
      _getMarketIndices(),
    ]);

    final allEgx = List<Map<String, dynamic>>.from(results[0] as List);
    final filteredEgx = allEgx.where((s) {
      final sym = s['symbol'].toString().toUpperCase();
      return !sym.startsWith('EGX') &&
          !['EGP', 'USD', 'GOLD'].contains(sym);
    }).take(10).toList();

    // Insert market indices (EGX30, EGX70) at the very top of the EGX list
    final indices = List<Map<String, dynamic>>.from(results[3] as List);
    filteredEgx.insertAll(0, indices);

    final List<Map<String, dynamic>> globalAssets = [];
    for (final r in results[1] as List) {
      globalAssets.add(Map<String, dynamic>.from(r as Map)); // Crypto
    }
    for (final r in results[2] as List) {
      globalAssets.add(Map<String, dynamic>.from(r as Map)); // US Stocks
    }

    print('✅ [Chatbot RAG] Found ${filteredEgx.length} EGX trending and ${globalAssets.length} Global trending assets.');
    return ChatbotTrendingContext(
        egxTrending: filteredEgx, globalTrending: globalAssets);
  }

  @override
  Future<List<Map<String, dynamic>>> getCommunityPulse({int limit = 5}) async {
    try {
      final posts =
          await communityRepository.getAllPosts(limit: limit, offset: 0);
      return posts
          .map((p) => {'content': p.content, 'sentiment': p.sentiment})
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── AI & Analytics ──────────────────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getPortfolioAiPredictions(
      List<String> symbols) async {
    print('🤖 [Chatbot RAG] Fetching AI predictions for portfolio: $symbols');
    final results = await Future.wait(
        symbols.map((s) => searchRepository.getLatestAiPrediction(s)));
    // whereType<AiPrediction>() drops nulls; cast to dynamic once per item
    final mappedResults = results.whereType<Object>().map((obj) {
      final pred = obj as dynamic;
      return <String, dynamic>{
        'symbol': pred.symbol as String,
        'trend': pred.overallTrend as String,
        'signal': pred.mlSignal as String,
        'conf': pred.probability as double,
        'recommendation': pred.recommendation as String,
      };
    }).toList();
    
    print('✅ [Chatbot RAG] Found ${mappedResults.length} AI predictions.');
    return mappedResults;
  }

  /// Fully hydrates a [TechnicalTableData] for a given symbol in 3 stages:
  ///   1. Price chunk  → current price + 1-day change
  ///   2. Technicals   → EMA10/20/50, RSI14, MACD from allComputedFeatures
  ///   3. AI verdict   → synthesised signal from probability + smartAnalysis
  @override
  Future<TechnicalTableData?> getTechnicalAnalysis(String symbol) async {
    print('🤖 [Chatbot RAG] Fetching technical analysis for: $symbol');
    final p = await searchRepository.getLatestAiPrediction(symbol);
    
    TechnicalTableData table = TechnicalTableData.empty(symbol);
    
    // Always attempt to fetch the live price chunk (this hits Finnhub/Binance/EGX via searchRepository)
    table = await _fillPriceChunk(symbol, table, p?.closePrice ?? 0.0);

    if (p == null) {
      print('⚠️ [Chatbot RAG] No technical analysis / AI prediction found for $symbol. Returning only price data.');
      return table;
    }

    table = await _fillTechnicalsChunk(table, p);
    final newsSummary = await _fetchNewsSentimentSummary(symbol);
    table = _fillAiVerdictChunk(table, p, newsSummary);
    
    print('✅ [Chatbot RAG] Technical analysis hydrated for $symbol.');
    return table;
  }

  // ── Private Technical Fill Helpers ──────────────────────────────────────────

  /// Fills `current_price` and `change_1d` rows using the stock entity and
  /// the AI prediction's last-known close as the previous-day reference.
  Future<TechnicalTableData> _fillPriceChunk(
    String symbol,
    TechnicalTableData tableData,
    double predictionClosePrice,
  ) async {
    try {
      final stock = await searchRepository.getStockBySymbol(symbol);

      final bool isUsd = _isUsdAsset(stock.sector, stock.candleTableName);

      double currentPrice = stock.currentPrice ?? 0.0;
      final String currency = isUsd ? 'USD' : 'EGP';

      // 1-day change: compare live price against prediction's close (prev close)
      final double prevClose =
          predictionClosePrice > 0 ? predictionClosePrice : (stock.prevClose ?? 0.0);
      double changePct = 0.0;
      if (prevClose > 0 && currentPrice > 0) {
        changePct = ((currentPrice - prevClose) / prevClose) * 100;
      }

      final priceStr = currentPrice > 0
          ? '${currentPrice.toStringAsFixed(2)} $currency'
          : 'N/A';
      final changeStr = prevClose > 0
          ? '${changePct >= 0 ? '+' : ''}${changePct.toStringAsFixed(2)}%'
          : 'N/A';
      final changeSig = changePct > 0
          ? SignalType.bullish
          : changePct < 0
              ? SignalType.bearish
              : SignalType.neutral;

      Map<String, TableRowData> rows = Map.from(tableData.rows);
      rows['current_price'] = rows['current_price']!.copyWith(
        value: priceStr,
        signal: SignalType.neutral,
      );
      rows['change_1d'] = rows['change_1d']!.copyWith(
        value: changeStr,
        signal: changeSig,
      );
      return tableData.copyWith(rows: rows);
    } catch (_) {
      return tableData;
    }
  }

  /// Fills EMA10/20/50, SMA50/200 (if present), RSI14, MACD rows using the
  /// `allComputedFeatures` nested map from [AiPrediction].
  Future<TechnicalTableData> _fillTechnicalsChunk(
    TechnicalTableData tableData,
    dynamic prediction,
  ) async {
    try {
      // allComputedFeatures is the nested map from the new-format prediction.
      // For legacy flat-format rows we fall back to rawFeatures directly.
      final Map<String, dynamic> features = prediction.isNewFormat
          ? Map<String, dynamic>.from(prediction.allComputedFeatures)
          : Map<String, dynamic>.from(prediction.rawFeatures);

      double _f(String key) =>
          (features[key] as num?)?.toDouble() ?? 0.0;

      final double ema10 = _f('ema_10');
      final double ema20 = _f('ema_20');
      final double ema50 = _f('ema_50');
      final double rsi = _f('rsi');
      final double macdHist = _f('macd_hist');

      // SMA50 / SMA200 — not always in the features; use 0 as sentinel
      final double sma50 = _f('sma_50');
      final double sma200 = _f('sma_200');

      final closePrice = prediction.closePrice as double;

      SignalType _emaSig(double ema) {
        if (ema <= 0) return SignalType.neutral;
        return closePrice > ema ? SignalType.bullish : SignalType.bearish;
      }

      SignalType _rsiSig(double r) {
        if (r > 70) return SignalType.bearish;  // Overbought → caution
        if (r > 60) return SignalType.bullish;
        if (r < 30) return SignalType.bullish;  // Oversold → bounce potential
        if (r < 40) return SignalType.bearish;
        return SignalType.neutral;
      }

      SignalType _macdSig(double hist) {
        if (hist > 0) return SignalType.bullish;
        if (hist < 0) return SignalType.bearish;
        return SignalType.neutral;
      }

      Map<String, TableRowData> rows = Map.from(tableData.rows);

      if (ema10 > 0) {
        rows['ema10'] = rows['ema10']!.copyWith(
          value: ema10.toStringAsFixed(2),
          signal: _emaSig(ema10),
        );
      }
      if (ema20 > 0) {
        rows['ema20'] = rows['ema20']!.copyWith(
          value: ema20.toStringAsFixed(2),
          signal: _emaSig(ema20),
        );
      }
      if (ema50 > 0) {
        rows['ema50'] = rows['ema50']!.copyWith(
          value: ema50.toStringAsFixed(2),
          signal: _emaSig(ema50),
        );
      }
      if (sma50 > 0) {
        rows['sma50'] = rows['sma50']!.copyWith(
          value: sma50.toStringAsFixed(2),
          signal: _emaSig(sma50),
        );
      }
      if (sma200 > 0) {
        rows['sma200'] = rows['sma200']!.copyWith(
          value: sma200.toStringAsFixed(2),
          signal: _emaSig(sma200),
        );
      }
      if (rsi > 0) {
        String rsiLabel = rsi.toStringAsFixed(1);
        if (rsi > 70) rsiLabel += ' (Overbought)';
        else if (rsi < 30) rsiLabel += ' (Oversold)';
        rows['rsi14'] = rows['rsi14']!.copyWith(
          value: rsiLabel,
          signal: _rsiSig(rsi),
        );
      }
      // MACD: show histogram value alongside the status string
      final macdStatus = prediction.macdStatus as String? ?? '-';
      rows['macd'] = rows['macd']!.copyWith(
        value: macdHist != 0
            ? '${macdHist.toStringAsFixed(4)} ($macdStatus)'
            : macdStatus,
        signal: _macdSig(macdHist),
      );

      return tableData.copyWith(rows: rows);
    } catch (_) {
      return tableData;
    }
  }

  /// Derives the AI verdict row by counting bullish/bearish signals across
  /// the already-filled rows and incorporating the ML probability score.
  TechnicalTableData _fillAiVerdictChunk(
    TechnicalTableData tableData,
    dynamic prediction,
    String newsSentimentSummary,
  ) {
    try {
      int bullish = 0, bearish = 0;
      final rowsToCount = ['ema10', 'ema20', 'ema50', 'rsi14', 'macd', 'change_1d'];
      for (final key in rowsToCount) {
        final row = tableData.rows[key];
        if (row?.signal == SignalType.bullish) bullish++;
        if (row?.signal == SignalType.bearish) bearish++;
      }

      final double prob = (prediction.probability as num).toDouble();
      final String mlSignal = prediction.mlSignal as String? ?? '-';
      final String recommendation = prediction.recommendation as String? ?? 'Neutral';
      final String overallTrend = prediction.overallTrend as String? ?? 'NEUTRAL';

      // Build the verdict sentence — no filler, just the facts
      final confidencePct = (prob * 100).toStringAsFixed(1);
      final signalBias = bullish > bearish
          ? 'Bullish bias'
          : bearish > bullish
              ? 'Bearish bias'
              : 'Mixed signals';

      String verdictText =
          '$signalBias ($bullish↑ / $bearish↓ indicators). '
          'ML Signal: $mlSignal | Confidence: $confidencePct% | Trend: $overallTrend. '
          'Recommendation: $recommendation.';

      if (newsSentimentSummary.isNotEmpty) {
        verdictText += ' News: $newsSentimentSummary.';
      }

      final SignalType verdictSig = bullish > bearish
          ? SignalType.bullish
          : bearish > bullish
              ? SignalType.bearish
              : SignalType.neutral;

      Map<String, TableRowData> rows = Map.from(tableData.rows);
      rows['verdict'] = rows['verdict']!.copyWith(
        value: verdictText,
        signal: verdictSig,
      );
      return tableData.copyWith(rows: rows);
    } catch (_) {
      return tableData;
    }
  }

  /// Fetches the most recent news for a symbol and returns a concise 1-line
  /// sentiment summary (e.g. "2 Positive, 1 Negative") for the verdict row.
  Future<String> _fetchNewsSentimentSummary(String symbol) async {
    try {
      final news = await getStockNews(symbols: [symbol], limit: 5);
      if (news.isEmpty) return '';

      int pos = 0, neg = 0, neu = 0;
      for (final n in news) {
        final s = (n['sentiment'] ?? '').toString().toLowerCase();
        if (s.contains('positive') || s.contains('إيجابي')) pos++;
        else if (s.contains('negative') || s.contains('سلبي')) neg++;
        else neu++;
      }

      final parts = <String>[];
      if (pos > 0) parts.add('$pos Positive');
      if (neg > 0) parts.add('$neg Negative');
      if (neu > 0) parts.add('$neu Neutral');
      return parts.join(', ');
    } catch (_) {
      return '';
    }
  }

  // ── Response Generation ─────────────────────────────────────────────────────

  @override
  Stream<String> generateFinalResponseStream({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>> history = const [],
  }) async* {
    final enhancedSystemPrompt = '''
[MANDATORY OPERATING RULES — NON-NEGOTIABLE]
1. LANGUAGE COMMAND: The system prompt specifies the exact language you MUST use (e.g., Egyptian Arabic or English). Follow it strictly.
2. ZERO HALLUCINATION (MARKET DATA ONLY): When citing specific stock prices, percentages, predictions, or market figures, they MUST come from the HIDDEN MARKET CONTEXT below. If data is missing, say "Data not available". However, for general financial education (e.g., "what are mutual funds?"), greetings, or conversational questions, you MAY freely use your general knowledge — the zero-hallucination rule does NOT apply to general knowledge.
3. TABLE FORMAT: Use Markdown tables wherever structured data appears. The separator row "|---|---|" MUST follow the header row immediately, or the table will be broken.
4. ROUNDING: All financial values and percentages MUST be rounded to exactly 2 decimal places.
5. SENTIMENT EMOJIS: Prefix sentiment labels with 🟢 Positive / 🔴 Negative / 🟡 Neutral. For Arabic: 🟢 إيجابي / 🔴 سلبي / 🟡 محايد.
6. STOCK LINKS: Every ticker symbol MUST be a markdown link: [SYMBOL](stock:SYMBOL).
7. HARD FILTER: Never recommend market indices (EGX30, EGX50) or currencies (EGP, USD) as tradeable stocks.
8. CONCISENESS: Stop immediately after delivering the requested analysis. No repetition, no filler, no "I hope this helps".
9. CONVERSATIONAL AWARENESS: If the user is greeting you, chatting casually, or asking educational/definition questions, respond naturally and conversationally. Do NOT jump into portfolio creation or market analysis unless the user explicitly asks for it.

$systemPrompt
''';

    final fullUserPrompt = userMessage;

    print('\n======================================================');
    print('🚀 [Chatbot LLM] Sending Prompt to AI...');
    print('SYSTEM PROMPT LENGTH: ${enhancedSystemPrompt.length} chars');
    print('USER PROMPT LENGTH: ${fullUserPrompt.length} chars');
    print('--- SYSTEM PROMPT SNIPPET ---');
    print(enhancedSystemPrompt.length > 500 ? enhancedSystemPrompt.substring(0, 500) + '...' : enhancedSystemPrompt);
    print('======================================================\n');

    try {
      final response = await aiService.generateCompletion(
        content: '',
        systemPrompt: enhancedSystemPrompt,
        userPrompt: fullUserPrompt,
        temperature: 0.3,
        maxTokens: 4096,
        history: history,
      );
      
      print('✅ [Chatbot LLM] Received full completion. Starting word-by-word streaming.');

      // Stream word-by-word for real-time feel
      final chunks = response.split(RegExp(r'(?<=\s)'));
      for (final chunk in chunks) {
        await Future.delayed(const Duration(milliseconds: 10));
        yield chunk;
      }
    } catch (e) {
      print('❌ [Chatbot LLM] Exception: $e');
      rethrow;
    }
  }

  // ── Private Helpers ─────────────────────────────────────────────────────────

  bool _isUsdAsset(String? sector, String? candleTableName) {
    return sector == 'Crypto' ||
        sector == 'US ETFs' ||
        sector == 'US Stocks' ||
        candleTableName == 'API' ||
        candleTableName == 'API_FINNHUB';
  }

  @override
  Future<double> getUsdRate() async {
    try {
      final prices = await assetRepository.getCurrencyLivePrices();
      return prices['USDEGP'] ?? 50.0;
    } catch (_) {
      return 50.0;
    }
  }
}
