import 'dart:async';
import 'dart:convert';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/core/services/technical_analysis_service.dart';
import 'package:egx/core/services/technical_result.dart';
import 'package:egx/core/utils/candle_aggregator.dart';
import 'package:egx/features/assets/domain/entities/asset_type.dart';
import 'package:egx/features/assets/domain/usecases/get_stock_candles_usecase.dart';
import 'package:egx/features/assets/domain/usecases/get_stock_news_usecase.dart';
import 'package:egx/features/assets/domain/usecases/get_material_price_usecase.dart';
import 'package:egx/features/assets/domain/usecases/get_crypto_candles_usecase.dart';
import 'package:egx/features/assets/domain/usecases/get_crypto_ticker_usecase.dart';
import 'package:egx/features/community/domain/usecase/get_all_posts_usecase.dart';
import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/news_briefing/domain/entities/news_summary_entity.dart';
import 'package:egx/features/news_briefing/domain/usecases/summarize_news_usecase.dart';
import 'package:egx/features/profile/domain/entity/post_entity.dart';
import 'package:egx/features/profile/domain/usecase/interaction_usecases.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/search/domain/usecases/get_latest_news_usecase.dart';
import 'package:egx/features/search/domain/usecases/get_watchlist_status_usecase.dart';
import 'package:egx/features/search/domain/usecases/toggle_watchlist_usecase.dart'
    as watchlist;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

/// Unified controller for all asset types (stocks, crypto, materials, indices)
class AssetDetailsController extends GetxController
    with WidgetsBindingObserver {
  final String stockId;
  final String symbol;
  final AssetType assetType;

  // Dependencies - Use cases
  final GetStockNewsUseCase? getStockNewsUseCase;
  final GetStockCandlesUseCase? getStockCandlesUseCase;
  final GetCryptoCandlesUseCase? getCryptoCandlesUseCase;
  final GetCryptoTickerUseCase? getCryptoTickerUseCase;
  final GetMaterialPriceUseCase? getMaterialPriceUseCase;
  final GetAllPostsUseCase getAllPostsUseCase;
  final TogglePostVoteUseCase togglePostVoteUseCase;
  final ToggleBookmarkUseCase toggleBookmarkUseCase;
  final watchlist.ToggleWatchlistUseCase toggleWatchlistUseCase;
  final GetWatchlistStatusUseCase getWatchlistStatusUseCase;
  final GetLatestNewsUseCase? getLatestNewsUseCase;
  final SummarizeNewsUseCase? summarizeNewsUseCase;

  AssetDetailsController({
    required this.stockId,
    required this.symbol,
    required this.assetType,
    this.getStockNewsUseCase,
    this.getStockCandlesUseCase,
    this.getCryptoCandlesUseCase,
    this.getCryptoTickerUseCase,
    this.getMaterialPriceUseCase,
    required this.getAllPostsUseCase,
    required this.togglePostVoteUseCase,
    required this.toggleBookmarkUseCase,
    required this.toggleWatchlistUseCase,
    required this.getWatchlistStatusUseCase,
    this.getLatestNewsUseCase,
    this.summarizeNewsUseCase,
  });

  // Observables - Chart & Price
  var candleData = <CandleEntity>[].obs;
  var isLoadingChart = false.obs;
  var currentPrice = 0.0.obs;
  var prevClosePrice = 0.0.obs;
  var priceChangePercent = 0.0.obs;
  var isPositivePerformance = true.obs;
  var currentTooltipColor = Rx<Color>(const Color(0xFF2A2A35));

  // Crypto-specific market stats
  var high24h = 0.0.obs;
  var low24h = 0.0.obs;
  var volume24h = 0.0.obs;

  // Material prices (Gold/Silver)
  var materialPrice = Rx<MaterialPriceEntity?>(null);

  // News
  var newsList = <NewsEntity>[].obs;
  var isLoadingNews = false.obs;
  var isLoadingMoreNews = false.obs;
  var newsPage = 0;
  final int newsLimit = 10;
  var hasMoreNews = true.obs;

  // News Summarization
  var isSummarizing = false.obs;
  var currentSummary = Rxn<NewsSummaryEntity>();

  // Community Posts
  var postsList = <PostEntity>[].obs;
  var isLoadingPosts = false.obs;
  var hasMore = true.obs;
  var isLoadMore = false.obs;
  int _page = 0;
  final int _limit = 10;

  // Chart
  var selectedTimeRange = '1D'.obs;
  List<String> get timeRanges => assetType.isCrypto
      ? ['1D', '5D', '1W', '1M', '6M', '1Y', 'All']
      : ['1D', '5D', '1W', '1M', '6M', '1Y', 'All'];
  var selectedSpotX = Rxn<double>();

  // Watchlist
  var isWatchlisted = false.obs;

  // Currency toggle (for materials)
  var isEgp = false.obs;
  final double usdToEgpRate = 51.0;

  // Technical analysis — anchored to fixed 15m timeframe
  var technicalResult = Rxn<TechnicalResult>();
  var gaugeCandles = <CandleEntity>[].obs;

  // Timers & WebSocket
  Timer? _voteDebounceTimer;
  Timer? _pollingTimer;
  WebSocketChannel? _channel;
  final Map<int, PostEntity> _originalPostStates = {};

  String get currentUserId => Supabase.instance.client.auth.currentUser!.id;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    fetchNews(refresh: true);
    checkWatchlistStatus();
    fetchPosts();

    if (assetType.isCrypto) {
      _initCryptoData();
    } else {
      _initStockData();
    }

    // Fetch dedicated 15m data for Technical Gauge
    _fetchGaugeCandles();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _voteDebounceTimer?.cancel();
    _pollingTimer?.cancel();
    _channel?.sink.close();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!assetType.isCrypto) {
        startPolling();
      }
    } else if (state == AppLifecycleState.paused) {
      _pollingTimer?.cancel();
    }
  }

  // ============ HELPER METHODS ============

  /// Compute technical analysis score from dedicated 15m gauge candles.
  void calculateTechnicals() {
    if (gaugeCandles.isEmpty) {
      technicalResult.value = TechnicalResult.empty;
      return;
    }
    final isEgx = assetType.isStock && !assetType.isMaterial;
    technicalResult.value = TechnicalAnalysisService.calculateTechnicalScore(
      gaugeCandles.toList(),
      isEgx: isEgx,
    );
  }

  /// Fetch dedicated 15m candle data for the Technical Gauge.
  /// Independent from chart timeframe — always 15m "Hawk's Eye" view.
  Future<void> _fetchGaugeCandles() async {
    try {
      const gaugeInterval = '15m';
      const gaugeLimit = 100;

      if (assetType.isCrypto) {
        // Crypto → use existing use case with 15m interval
        final candles = await getCryptoCandlesUseCase!(
          symbol: symbol,
          interval: gaugeInterval,
          limit: gaugeLimit,
        );
        gaugeCandles.value = candles;
      } else if (assetType.isMaterial) {
        // Gold/Silver → Binance directly
        final binanceSymbol = symbol == 'GOLD' ? 'PAXGUSDT' : 'LTCUSDT';
        final url =
            'https://api.binance.com/api/v3/klines?symbol=$binanceSymbol&interval=$gaugeInterval&limit=$gaugeLimit';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          gaugeCandles.value = data.map((item) {
            return CandleEntity(
              candleTime: DateTime.fromMillisecondsSinceEpoch(item[0]),
              open: double.parse(item[1]),
              high: double.parse(item[2]),
              low: double.parse(item[3]),
              close: double.parse(item[4]),
              volume: double.parse(item[5]).toInt(),
              timeframe: gaugeInterval,
            );
          }).toList();
        }
      } else {
        // EGX stock → fetch 1m data via use case, aggregate to 15m
        final candleTableName =
            Get.arguments?['candle_table_name'] ?? 'egx30_candles';
        final data = await getStockCandlesUseCase!(
          symbol: symbol,
          tableName: candleTableName,
          interval: '1m',
          limit: 1500,
        );
        if (data.isNotEmpty) {
          data.sort((a, b) => a.candleTime.compareTo(b.candleTime));
          final aggregated = CandleAggregator.aggregate(data, 15);
          // Deduplicate
          final Map<String, CandleEntity> unique = {};
          for (var c in aggregated) {
            unique[c.candleTime.toIso8601String()] = c;
          }
          gaugeCandles.value = unique.values.toList()
            ..sort((a, b) => a.candleTime.compareTo(b.candleTime));
        }
      }

      calculateTechnicals();
    } catch (e) {
      // print('Gauge candle fetch error: $e');
      technicalResult.value = TechnicalResult.empty;
    }
  }

  ({List<CandleEntity> candles, double prevClose}) getChartDisplayData(
    double initialPrevClose,
  ) {
    double prevClose = initialPrevClose;

    // Fallback if prevClose is 0 and we have data
    if (prevClose == 0 && candleData.isNotEmpty) {
      prevClose = candleData.first.open;
    }

    // Currency Conversion Logic
    final isMaterial = symbol == 'GOLD' || symbol == 'SILVER';
    final currentIsEgp = isMaterial ? isEgp.value : true;
    final rate = isMaterial ? usdToEgpRate : 1.0;

    List<CandleEntity> displayCandles = candleData;
    double displayPrevClose = prevClose;

    if (currentIsEgp && rate != 1.0) {
      displayPrevClose = prevClose * rate;
      displayCandles = candleData.map((c) {
        return CandleEntity(
          candleTime: c.candleTime,
          open: c.open * rate,
          high: c.high * rate,
          low: c.low * rate,
          close: c.close * rate,
          volume: c.volume,
        );
      }).toList();
    }

    // Override prevClose for Crypto if available
    if (assetType.isCrypto && prevClosePrice.value != 0) {
      return (candles: displayCandles, prevClose: prevClosePrice.value);
    }

    return (candles: displayCandles, prevClose: displayPrevClose);
  }

  // ============ INITIALIZATION ============

  Future<void> _initCryptoData() async {
    await fetchHistoricalData('1D');
    await fetch24hrTicker();
    connectWebSocket();
  }

  Future<void> _initStockData() async {
    if (symbol == 'GOLD' || symbol == 'SILVER') {
      selectedTimeRange.value = '1M';
      await fetchChartData('1M');
      fetchMaterialPrice();
    } else {
      await fetchChartData('1D');
    }
    startPolling();
  }

  // ============ CHART DATA ============

  void updateTimeRange(String range) {
    if (selectedTimeRange.value == range) return;
    selectedTimeRange.value = range;

    if (assetType.isCrypto) {
      fetchHistoricalData(range);
      connectWebSocket(); // Reconnect with new interval
    } else {
      fetchChartData(range);
      startPolling(); // Restart polling
    }
  }

  Future<void> fetchHistoricalData(String range) async {
    if (!assetType.isCrypto) return;

    isLoadingChart.value = true;
    try {
      String interval = '5m';
      int limit = 500;
      DateTime? startDate; // Used for client-side filtering

      switch (range) {
        case '1D':
          interval = '5m';
          limit = 288; // 24 * 12 = 288
          startDate = DateTime.now().subtract(const Duration(days: 1));
          break;
        case '5D':
          interval = '1h';
          limit = 125; // 5 * 24 = 120 + buffer
          startDate = DateTime.now().subtract(const Duration(days: 5));
          break;
        case '1W':
          interval = '1h';
          limit = 175; // 7 * 24 = 168 + buffer
          startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case '1M':
          interval = '4h';
          limit = 190; // 30 * 6 = 180 + buffer
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case '1Y':
          interval = '1d';
          limit = 370;
          startDate = DateTime.now().subtract(const Duration(days: 365));
          break;
        case '6M':
          interval = '1d';
          limit = 185; // ~180 + buffer
          startDate = DateTime.now().subtract(const Duration(days: 180));
          break;
        case 'All':
          interval = '1M';
          limit = 1000; // Monthly data
          startDate = null;
          break;
      }

      var candles = await getCryptoCandlesUseCase!(
        symbol: symbol,
        interval: interval,
        limit: limit,
      );

      // Client-side filtering to ensure precise range
      if (startDate != null) {
        candles = candles
            .where((c) => c.candleTime.isAfter(startDate!))
            .toList();
      }

      candleData.value = candles;
      if (candles.isNotEmpty) {
        currentPrice.value = candles.last.close;

        // Calculate positive based on visible chart trend (First OPEN vs Last CLOSE)
        // Chart visually starts at first candle's OPEN, not CLOSE
        final firstPrice = candles.first.open;
        final lastPrice = candles.last.close;
        isPositivePerformance.value = lastPrice >= firstPrice;
      }
    } catch (e) {
      // print('Error fetching crypto historical data: $e');
    } finally {
      isLoadingChart.value = false;
    }
  }

  Future<void> fetchChartData(String range) async {
    if (assetType.isCrypto) return;

    isLoadingChart.value = true;
    String? candleTableName;

    if (symbol == 'GOLD') {
      candleTableName = 'gold_candles';
    } else if (symbol == 'SILVER') {
      candleTableName = 'silver_candles';
    } else {
      candleTableName = Get.arguments['candle_table_name'];
    }

    String resolution = '1d';
    int limit = 100;
    bool needsAggregation = false;
    int aggregationInterval = 30;
    DateTime? startTime;

    switch (range) {
      case '1D':
        if (symbol == 'GOLD' || symbol == 'SILVER') {
          resolution = '5m';
          limit = 300;
        } else {
          resolution = '1m';
          limit = 300;
        }
        break;
      case '5D':
        startTime = DateTime.now().subtract(const Duration(days: 5));
        if (symbol == 'GOLD' || symbol == 'SILVER') {
          resolution = '1h';
          limit = 150;
          needsAggregation = false;
        } else {
          resolution = '1m';
          limit = 2000;
          needsAggregation = true;
          aggregationInterval = 30;
        }
        break;
      case '1W':
        startTime = DateTime.now().subtract(const Duration(days: 7));
        resolution = '1m';
        if (symbol == 'GOLD' || symbol == 'SILVER') {
          resolution = '1h';
          limit = 200;
          needsAggregation = false;
        } else {
          limit = 2500;
          needsAggregation = true;
          aggregationInterval = 20;
        }
        break;
      case '1M':
        resolution = '1d';
        limit = 45;
        break;
      case '6M':
        resolution = '1d';
        limit = 200;
        break;
      case '1Y':
        resolution = '1d';
        limit = 365;
        break;
      case 'All':
        // Fetch all available daily data and aggregate by month
        resolution = '1d';
        limit = 4000; // ~8 years of daily data
        needsAggregation = true;
        aggregationInterval = 43200; // Aggregate 30 days into 1 month
        break;
    }

    try {
      var candles = await getStockCandlesUseCase!(
        symbol: symbol,
        tableName: candleTableName ?? 'egx30_candles',
        interval: resolution,
        limit: limit,
        startTime: startTime,
      );

      candles.sort((a, b) => a.candleTime.compareTo(b.candleTime));

      if (needsAggregation) {
        candles = CandleAggregator.aggregate(candles, aggregationInterval);
      }

      if (candles.isNotEmpty) {
        if (range == '1D') {
          final double prevClose =
              (Get.arguments['prev_close'] as num?)?.toDouble() ?? 0.0;
          if (prevClose > 0) {
            isPositivePerformance.value = candles.last.close >= prevClose;
          } else {
            isPositivePerformance.value =
                candles.last.close >= candles.first.open;
          }
        } else {
          isPositivePerformance.value =
              candles.last.close >= candles.first.open;
        }
      } else {
        isPositivePerformance.value = true;
      }

      candleData.value = candles;

      // Handle WebSocket for Gold/Silver
      if ((symbol == 'GOLD' || symbol == 'SILVER') &&
          (range == '1D' || range == '1W')) {
        connectBinanceWebSocket(range);
      } else {
        _channel?.sink.close();
      }
    } catch (e) {
      // print('Error fetching stock candles: $e');
    } finally {
      isLoadingChart.value = false;
    }
  }

  // ============ CRYPTO SPECIFIC ============

  Future<void> fetch24hrTicker() async {
    if (!assetType.isCrypto) return;

    try {
      final data = await getCryptoTickerUseCase!(symbol);
      prevClosePrice.value = double.parse(data['prevClosePrice']);
      priceChangePercent.value = double.parse(data['priceChangePercent']);
      high24h.value = double.parse(data['highPrice']);
      low24h.value = double.parse(data['lowPrice']);
      volume24h.value = double.parse(data['volume']);

      isPositivePerformance.value = priceChangePercent.value >= 0;
    } catch (e) {
      // print('Error fetching 24hr ticker: $e');
    }
  }

  void connectWebSocket() {
    if (!assetType.isCrypto) return;

    _channel?.sink.close();

    String interval = '5m';
    switch (selectedTimeRange.value) {
      case '1D':
        interval = '5m';
        break;
      case '5D':
        interval = '1h';
        break;
      case '1W':
        interval = '1h';
        break;
      case '1M':
        interval = '4h';
        break;
      case '1Y':
        interval = '1d';
        break;
      case '6M':
        interval = '1d';
        break;
      case 'All':
        interval = '1M'; // Monthly for all-time
        break;
    }

    final wsUrl = Uri.parse(
      'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}usdt@kline_$interval',
    );

    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (message) {
        final data = json.decode(message);
        final k = data['k'];

        final time = DateTime.fromMillisecondsSinceEpoch(k['t'], isUtc: true);
        final open = double.parse(k['o']);
        final high = double.parse(k['h']);
        final low = double.parse(k['l']);
        final close = double.parse(k['c']);
        final volume = double.parse(k['v']).toInt();

        final newCandle = CandleEntity(
          candleTime: time,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        );

        currentPrice.value = close;

        if (prevClosePrice.value != 0) {
          double change = close - prevClosePrice.value;
          priceChangePercent.value = (change / prevClosePrice.value) * 100;
          isPositivePerformance.value = priceChangePercent.value >= 0;
        }

        if (candleData.isNotEmpty) {
          final lastCandle = candleData.last;
          if (lastCandle.candleTime.isAtSameMomentAs(newCandle.candleTime)) {
            candleData[candleData.length - 1] = newCandle;
          } else if (newCandle.candleTime.isAfter(lastCandle.candleTime)) {
            candleData.add(newCandle);
          }
        } else {
          candleData.add(newCandle);
        }

        candleData.refresh();

        // Recalculate trend based on visible data (First OPEN vs Last CLOSE)
        if (candleData.isNotEmpty) {
          final firstPrice = candleData.first.open;
          final lastPrice = candleData.last.close;
          isPositivePerformance.value = lastPrice >= firstPrice;
        }
      },
      onError: (error) => print('WebSocket Error: $error'),
      onDone: () => print('WebSocket Closed'),
    );
  }

  // ============ STOCK SPECIFIC ============

  bool get isMarketOpen {
    if (assetType.isCrypto) return true; // Crypto markets always open

    final now = DateTime.now().toUtc().add(const Duration(hours: 2));
    if (now.weekday == DateTime.friday || now.weekday == DateTime.saturday) {
      return false;
    }
    final start = DateTime.utc(now.year, now.month, now.day, 10, 0);
    final end = DateTime.utc(now.year, now.month, now.day, 14, 50);
    return now.isAfter(start) && now.isBefore(end);
  }

  void startPolling() {
    if (assetType.isCrypto) return;

    _pollingTimer?.cancel();

    if ((symbol == 'GOLD' || symbol == 'SILVER') &&
        (selectedTimeRange.value == '1D' || selectedTimeRange.value == '1W')) {
      return; // Using WebSocket instead
    }

    final range = selectedTimeRange.value;

    if (range == '1D') {
      if (isMarketOpen) {
        _pollingTimer = Timer.periodic(
          const Duration(seconds: 20),
          (_) => updateDataSmartly(),
        );
      }
    } else if (range == '1W') {
      _pollingTimer = Timer.periodic(
        const Duration(minutes: 20),
        (_) => fetchChartData('1W'),
      );
    }
  }

  Future<void> updateDataSmartly() async {
    if (candleData.isEmpty || selectedTimeRange.value != '1D') return;

    final lastTime = candleData.last.candleTime;
    final candleTableName = Get.arguments['candle_table_name'];

    try {
      final newCandles = await getStockCandlesUseCase!(
        symbol: symbol,
        tableName: candleTableName ?? 'egx30_candles',
        interval: '1m',
        limit: 5,
      );

      if (newCandles.isEmpty) return;

      final currentCandles = List<CandleEntity>.from(candleData);
      for (final newCandle in newCandles) {
        if (newCandle.candleTime.isAfter(lastTime)) {
          currentCandles.add(newCandle);
        } else if (newCandle.candleTime.isAtSameMomentAs(lastTime)) {
          final index = currentCandles.indexWhere(
            (c) => c.candleTime == lastTime,
          );
          if (index != -1) currentCandles[index] = newCandle;
        }
      }

      currentCandles.sort((a, b) => a.candleTime.compareTo(b.candleTime));

      if (currentCandles.isNotEmpty) {
        isPositivePerformance.value =
            currentCandles.last.close >= currentCandles.first.open;
      }

      candleData.value = currentCandles;
    } catch (e) {
      // print('Error updating stock candles: $e');
    }
  }

  void connectBinanceWebSocket(String range) {
    _channel?.sink.close();

    String binanceSymbol = symbol == 'GOLD' ? 'paxgusdt' : 'ltcusdt';
    String interval = range == '1W' ? '1h' : '5m';

    final wsUrl = Uri.parse(
      'wss://stream.binance.com:9443/ws/$binanceSymbol@kline_$interval',
    );

    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (message) {
        final data = json.decode(message);
        final k = data['k'];

        final time = DateTime.fromMillisecondsSinceEpoch(k['t'], isUtc: true);
        final open = double.parse(k['o']);
        final high = double.parse(k['h']);
        final low = double.parse(k['l']);
        final close = double.parse(k['c']);
        final volume = double.parse(k['v']).toInt();

        final newCandle = CandleEntity(
          candleTime: time,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        );

        if (candleData.isNotEmpty) {
          final lastCandle = candleData.last;
          if (lastCandle.candleTime.isAtSameMomentAs(newCandle.candleTime)) {
            candleData[candleData.length - 1] = newCandle;
          } else if (newCandle.candleTime.isAfter(lastCandle.candleTime)) {
            candleData.add(newCandle);
          }

          isPositivePerformance.value =
              candleData.last.close >= candleData.first.open;
          candleData.refresh();
        }
      },
      onError: (error) {
        // print('WebSocket Error: $error');
      },
      onDone: () {
        // print('WebSocket Closed');
      },
    );
  }

  Future<void> fetchMaterialPrice() async {
    if (getMaterialPriceUseCase == null) return;
    try {
      final price = await getMaterialPriceUseCase!();
      materialPrice.value = price;
    } catch (e) {
      // print('Error fetching material price: $e');
    }
  }

  void toggleCurrency() {
    isEgp.value = !isEgp.value;
  }

  // ============ NEWS ============

  Future<void> fetchNews({bool refresh = false}) async {
    if (refresh) {
      newsPage = 0;
      hasMoreNews.value = true;
      newsList.clear();
      isLoadingNews.value = true;
    } else {
      if (!hasMoreNews.value || isLoadingMoreNews.value) return;
      isLoadingMoreNews.value = true;
    }

    try {
      List<NewsEntity> news = [];

      if (assetType.isCrypto) {
        // Fetch crypto news from stock_news table
        final response = await Supabase.instance.client
            .from('stock_news')
            .select()
            .eq('stock_id', stockId)
            .order('published_at', ascending: false)
            .range(newsPage * newsLimit, (newsPage + 1) * newsLimit - 1);

        news = (response as List).map((e) {
          return NewsEntity(
            id: e['id'].toString(),
            title: e['title'] ?? '',
            source: e['source'],
            publishedAt: e['published_at'] ?? '',
            content: e['content'],
            url: e['url'],
          );
        }).toList();
      } else {
        final stockData = Get.arguments;
        final isIndex = stockData['sector'] == 'Indices';

        if (isIndex) {
          news = await getLatestNewsUseCase!(
            category: 'Stocks',
            limit: newsLimit,
            offset: newsPage * newsLimit,
          );
        } else {
          news = await getStockNewsUseCase!(
            stockId: stockId,
            limit: newsLimit,
            offset: newsPage * newsLimit,
          );
        }
      }

      if (news.length < newsLimit) {
        hasMoreNews.value = false;
      }

      if (refresh) {
        newsList.assignAll(news);
      } else {
        newsList.addAll(news);
      }

      newsPage++;
    } catch (e) {
      // print('Error fetching news: $e');
    } finally {
      isLoadingNews.value = false;
      isLoadingMoreNews.value = false;
    }
  }

  Future<void> loadMoreNews() async {
    await fetchNews();
  }

  Future<void> summarizeLatestNews() async {
    if (summarizeNewsUseCase == null) return;

    if (newsList.isEmpty) {
      Get.snackbar(
        S.current.asset_details_news_no_news,
        S.current.asset_details_news_no_news_msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (newsList.length < 3) {
      Get.snackbar(
        S.current.asset_details_news_insufficient,
        S.current.asset_details_news_insufficient_msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isSummarizing.value = true;

    try {
      final newsToSummarize = newsList.take(10).toList();
      final summary = await summarizeNewsUseCase!(newsItems: newsToSummarize);
      currentSummary.value = summary;
      Get.toNamed(AppPages.newsSummaryPage, arguments: summary);
    } catch (e) {
      // print('Error summarizing news: $e');
      Get.snackbar(
        S.current.asset_details_news_fail,
        e.toString().contains('Not enough news')
            ? e.toString().replaceAll('Exception: ', '')
            : S.current.asset_details_news_fail_msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isSummarizing.value = false;
    }
  }

  // Generate summary for in-panel display (no navigation)
  Future<void> generateSummaryInPanel() async {
    if (summarizeNewsUseCase == null) return;

    if (newsList.isEmpty) {
      Get.snackbar(
        S.current.asset_details_news_no_news,
        S.current.asset_details_news_no_news_msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (newsList.length < 3) {
      Get.snackbar(
        S.current.asset_details_news_insufficient,
        S.current.asset_details_news_insufficient_msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isSummarizing.value = true;

    try {
      final newsToSummarize = newsList.take(10).toList();
      final summary = await summarizeNewsUseCase!(newsItems: newsToSummarize);
      currentSummary.value = summary;
      // No navigation - summary will be shown in-panel
    } catch (e) {
      // print('Error summarizing news: $e');
      Get.snackbar(
        S.current.asset_details_news_fail,
        e.toString().contains('Not enough news')
            ? e.toString().replaceAll('Exception: ', '')
            : S.current.asset_details_news_fail_msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isSummarizing.value = false;
    }
  }

  // ============ COMMUNITY POSTS ============

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      hasMore.value = true;
      postsList.clear();
      isLoadingPosts.value = true;
    } else if (!hasMore.value || isLoadMore.value) {
      return;
    } else {
      isLoadMore.value = true;
    }

    try {
      final offset = _page * _limit;
      final posts = await getAllPostsUseCase(
        limit: _limit,
        offset: offset,
        category: symbol,
      );

      if (posts.length < _limit) {
        hasMore.value = false;
      }

      if (refresh) {
        postsList.value = posts;
      } else {
        postsList.addAll(posts);
      }

      _page++;
    } catch (e) {
      // print('Error fetching posts: $e');
    } finally {
      isLoadingPosts.value = false;
      isLoadMore.value = false;
    }
  }

  Future<void> loadMorePosts() async {
    await fetchPosts();
  }

  void navigateToPostDetails(PostEntity post) {
    Get.toNamed(AppPages.showDetailsPage, arguments: post);
  }

  Future<void> toggleLike(int index) async {
    final post = postsList[index];

    if (_voteDebounceTimer?.isActive ?? false) {
      _voteDebounceTimer!.cancel();
    }

    if (!_originalPostStates.containsKey(post.id)) {
      _originalPostStates[post.id] = post;
    }

    final bool newLikedStatus = !post.isLiked;
    final int newLikesCount = newLikedStatus
        ? post.likesCount + 1
        : (post.likesCount > 0 ? post.likesCount - 1 : 0);

    final newPost = post.copyWith(
      isLiked: newLikedStatus,
      likesCount: newLikesCount,
    );

    postsList[index] = newPost;
    postsList.refresh();

    _voteDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final int? voteType = newPost.isLiked ? 1 : null;
        await togglePostVoteUseCase.call(currentUserId, newPost.id, voteType);
        _originalPostStates.remove(newPost.id);
      } catch (e) {
        if (_originalPostStates.containsKey(newPost.id)) {
          final original = _originalPostStates[newPost.id]!;
          final revertIndex = postsList.indexWhere((p) => p.id == original.id);
          if (revertIndex != -1) {
            postsList[revertIndex] = original;
            postsList.refresh();
          }
          _originalPostStates.remove(newPost.id);
        }
        Get.snackbar(
          S.current.error_label,
          S.current.asset_details_post_like_error,
        );
      }
    });
  }

  Future<void> toggleBookmark(int index) async {
    final post = postsList[index];
    final oldPost = post;
    final newPost = post.copyWith(isBookmarked: !post.isBookmarked);

    postsList[index] = newPost;
    postsList.refresh();

    try {
      await toggleBookmarkUseCase.call(currentUserId, post.id);
    } catch (e) {
      postsList[index] = oldPost;
      postsList.refresh();
      Get.snackbar(
        S.current.error_label,
        S.current.asset_details_post_save_error,
      );
    }
  }

  // ============ WATCHLIST ============

  Future<void> checkWatchlistStatus() async {
    try {
      final status = await getWatchlistStatusUseCase(currentUserId, symbol);
      isWatchlisted.value = status;
    } catch (e) {
      // print('Error checking watchlist status: $e');
    }
  }

  Future<void> toggleWatchlist() async {
    final originalStatus = isWatchlisted.value;
    isWatchlisted.value = !originalStatus;

    try {
      await toggleWatchlistUseCase(currentUserId, symbol, isWatchlisted.value);

      Get.snackbar(
        isWatchlisted.value
            ? S.current.asset_details_watchlist_added
            : S.current.asset_details_watchlist_removed,
        isWatchlisted.value
            ? S.current.asset_details_watchlist_added_msg(symbol)
            : S.current.asset_details_watchlist_removed_msg(symbol),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isWatchlisted.value = originalStatus;
      Get.snackbar(
        S.current.error_label,
        S.current.asset_details_watchlist_error,
      );
      // print('Error toggling watchlist: $e');
    }
  }

  // ============ HELPERS ============

  void updateTooltipColor(double price, double prevClose) {
    if (price >= prevClose) {
      currentTooltipColor.value = AppColors.primary;
    } else {
      currentTooltipColor.value = Colors.red;
    }
  }

  String formatNumber(double value) {
    if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(2)}B';
    } else if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(2)}M';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(2)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }
}
