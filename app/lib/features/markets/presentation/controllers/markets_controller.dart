import 'dart:async';
import 'package:egx/core/utils/candle_aggregator.dart';
import 'package:egx/features/search/data/datasources/search_remote_datasource.dart';
import 'package:egx/features/search/data/repositories/search_repository_impl.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';
import 'package:egx/features/markets/domain/entities/ai_prediction.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class MarketsController extends GetxController with WidgetsBindingObserver {
  late final SearchRepository searchRepository;

  final TextEditingController searchController = TextEditingController();
  var searchResults = <StockEntity>[].obs;
  var popularAssets = <StockEntity>[].obs; // Renamed from popularCryptos
  var selectedStock = Rxn<StockEntity>();
  var candles = <CandleEntity>[].obs;
  var dailyCandle = Rxn<CandleEntity>(); // Daily session data (static)

  // Reactive selected interval
  var selectedInterval = '1m'.obs;

  var isLoading = false.obs;
  var isSearching = false.obs;
  var isLoadingCandles = false.obs;

  var connectionStatus = 'Disconnected'.obs;
  var nextCloseTime = Rxn<DateTime>();

  // AI Prediction
  final aiPrediction = Rxn<AiPrediction>();

  bool get isSocketConnected => connectionStatus.value == 'Connected';
  bool get isReconnecting => connectionStatus.value == 'Connecting';
  bool get isEgxStock {
    return selectedStock.value != null &&
        selectedStock.value!.candleTableName != 'API' &&
        selectedStock.value!.sector != 'Crypto' &&
        selectedStock.value!.symbol != 'GOLD' &&
        selectedStock.value!.symbol != 'SILVER';
  }

  bool get isGoldOrSilver {
    return selectedStock.value?.symbol == 'GOLD' ||
        selectedStock.value?.symbol == 'SILVER';
  }

  String get binanceSymbol {
    if (selectedStock.value?.symbol == 'GOLD') return 'PAXGUSDT';
    if (selectedStock.value?.symbol == 'SILVER') return 'LTCUSDT';
    return '';
  } // Market Hours Logic

  bool get isMarketOpen {
    final now = DateTime.now().toUtc().add(
      const Duration(hours: 2),
    ); // Cairo Time (UTC+2)
    // Weekend check (Friday & Saturday)
    if (now.weekday == DateTime.friday || now.weekday == DateTime.saturday) {
      return false;
    }

    // Time check (10:00 AM - 2:45 PM)
    final start = DateTime.utc(now.year, now.month, now.day, 10, 0);
    final end = DateTime.utc(now.year, now.month, now.day, 14, 45);

    return now.isAfter(start) && now.isBefore(end);
  }

  void toggleSearch() => isSearching.toggle();

  Timer? _debounce;
  Timer? _pollingTimer; // For Supabase 20-second polling
  StreamSubscription? _channelSubscription;
  WebSocketChannel? _channel; // For crypto
  WebSocketChannel? _binanceChannel; // For Gold/Silver
  WebSocketChannel? _watchlistChannel; // For Watchlist Updates

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Initialize dependencies
    final supabase = Supabase.instance.client;
    final remoteDataSource = SearchRemoteDataSourceImpl(supabase);
    searchRepository = SearchRepositoryImpl(remoteDataSource);

    // Load default stock: BTC with 1m interval
    _loadDefaultStock();
    // Load popular assets (crypto + EGX stocks)
    _loadPopularAssets();
  }

  Future<void> _loadDefaultStock() async {
    // Create a default BTC stock entity
    final btcStock = StockEntity(
      id: 'btc_default',
      symbol: 'BTC',
      companyNameEn: 'Bitcoin',
      companyNameAr: 'بيتكوين',
      sector: 'Crypto',
      candleTableName: 'API',
      logoUrl: 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
    );
    selectedStock.value = btcStock;
    fetchCandles(btcStock);
    fetchDailyCandle(btcStock);
    fetchAiPrediction(btcStock.symbol);
  }

  Future<void> _loadPopularAssets() async {
    try {
      // Fetch from Supabase
      final cryptos = await searchRepository.searchStocks(
        '',
        category: 'Crypto',
      );
      final stocks = await searchRepository.searchStocks(
        '',
        category: 'Stocks',
      );

      popularAssets.value = [...cryptos, ...stocks];
      _connectPopularCryptoSocket();
    } catch (e) {
      print('Error loading popular assets: $e');
      // Keep empty or use fallback
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchStocks(query);
    });
  }

  Future<void> searchStocks(String query) async {
    isLoading.value = true;
    try {
      // Search across all categories (crypto + stocks)
      final results = await searchRepository.searchStocks(query);
      searchResults.value = results;
    } catch (e) {
      print('Search Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectStock(StockEntity stock) {
    selectedStock.value = stock;
    candles.clear(); // Clear old data immediately
    searchController.clear();
    isSearching.value = false;
    searchResults.clear();
    fetchCandles(stock, interval: selectedInterval.value);
    fetchDailyCandle(stock); // Fetch daily session data
    fetchAiPrediction(stock.symbol);
  }

  Future<void> fetchCandles(StockEntity stock, {String interval = '1m'}) async {
    isLoadingCandles.value = true;
    _closeWebSocket();
    _stopPolling();
    connectionStatus.value = 'Connecting';

    // Fixed Buffer Strategy Limits
    int limit = _getLimitForInterval(interval);

    try {
      // Check if it's Gold/Silver
      // Route 1m-4H, 1D, 1W to Binance. Only 1M+ goes to Supabase (Historical)
      if (isGoldOrSilver && !['1M', '6M', '1Y'].contains(interval)) {
        await _fetchBinanceCandles(stock, interval, limit);
      } else if (stock.candleTableName == 'API' || stock.sector == 'Crypto') {
        // Crypto: use Binance API
        await _fetchCryptoCandles(stock, interval, limit);
      } else {
        // EGX Stock or Gold/Silver historical: use Supabase
        await _fetchSupabaseCandles(stock, interval, limit);
      }

      // Fetch Previous Close for Crypto/Gold/Silver (Binance Ticker)
      if (isGoldOrSilver ||
          stock.sector == 'Crypto' ||
          stock.candleTableName == 'API') {
        _fetchBinanceTicker(stock);
      }
    } catch (e) {
      print('Fetch Candles Error: $e');
      connectionStatus.value = 'Error';
    } finally {
      isLoadingCandles.value = false;
    }
  }

  Future<void> fetchAiPrediction(String symbol) async {
    try {
      final prediction = await searchRepository.getLatestAiPrediction(symbol);
      aiPrediction.value = prediction;
      print('AI Prediction for $symbol: ${prediction?.probability}');
    } catch (e) {
      print('Error fetching AI prediction: $e');
      aiPrediction.value = null;
    }
  }

  /// Fetch daily candle data (independent of chart timeframe)
  Future<void> fetchDailyCandle(StockEntity stock) async {
    try {
      // Always fetch from daily resolution
      if (isGoldOrSilver ||
          stock.candleTableName == 'API' ||
          stock.sector == 'Crypto') {
        // For crypto/gold/silver: fetch from Binance
        final symbol = isGoldOrSilver
            ? binanceSymbol
            : '${stock.symbol.toUpperCase()}USDT';
        final urlString =
            'https://api.binance.com/api/v3/klines?symbol=$symbol&interval=1d&limit=1';

        final response = await http.get(Uri.parse(urlString));

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (data.isNotEmpty) {
            final item = data.first;
            dailyCandle.value = CandleEntity(
              candleTime: DateTime.fromMillisecondsSinceEpoch(item[0]),
              open: double.parse(item[1]),
              high: double.parse(item[2]),
              low: double.parse(item[3]),
              close: double.parse(item[4]),
              volume: double.parse(item[5]).toInt(),
              timeframe: '1d',
            );
          }
        }
      } else {
        // For EGX stocks: fetch from Supabase
        final data = await searchRepository.getStockCandles(
          stock.symbol,
          candleTableName: stock.candleTableName,
          limit: 1,
          resolution: '1d',
        );

        if (data.isNotEmpty) {
          dailyCandle.value = data.first;
        }
      }
    } catch (e) {
      print('Error fetching daily candle: $e');
      dailyCandle.value = null;
    }
  }

  // Gold/Silver: Binance API + WebSocket (Intraday)
  Future<void> _fetchBinanceCandles(
    StockEntity stock,
    String interval,
    int limit,
  ) async {
    final symbol = binanceSymbol;
    final resolution = _mapToBinanceInterval(interval);
    // Binance max limit is 1000
    final fetchLimit = limit > 1000 ? 1000 : limit;

    // Fetch from Binance
    final urlString =
        'https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$resolution&limit=$fetchLimit';

    try {
      final response = await http.get(Uri.parse(urlString));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<CandleEntity> loadedCandles = data.map((item) {
          return CandleEntity(
            candleTime: DateTime.fromMillisecondsSinceEpoch(item[0]),
            open: double.parse(item[1]),
            high: double.parse(item[2]),
            low: double.parse(item[3]),
            close: double.parse(item[4]),
            volume: double.parse(item[5]).toInt(),
            timeframe: resolution,
          );
        }).toList();

        candles.value = loadedCandles;
        connectionStatus.value = 'Connected';

        // Connect WebSocket for real-time updates
        _connectBinanceWebSocket(symbol, resolution);
      } else {
        print('Binance API Error: ${response.statusCode}');
        connectionStatus.value = 'Error';
      }
    } catch (e) {
      print('Binance Fetch Error: $e');
      connectionStatus.value = 'Error';
    }
  }

  void _connectBinanceWebSocket(String symbol, String interval) {
    _binanceChannel?.sink.close();

    final wsUrl = Uri.parse(
      'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@kline_$interval',
    );

    print('Connecting to Binance WS: $wsUrl');

    try {
      _binanceChannel = WebSocketChannel.connect(wsUrl);

      _binanceChannel!.stream.listen(
        (message) {
          final data = json.decode(message);
          final kline = data['k'];

          final newCandle = CandleEntity(
            candleTime: DateTime.fromMillisecondsSinceEpoch(kline['t']),
            open: double.parse(kline['o']),
            high: double.parse(kline['h']),
            low: double.parse(kline['l']),
            close: double.parse(kline['c']),
            volume: double.parse(kline['v']).toInt(),
            timeframe: interval,
          );

          // Update last candle or add new one
          final currentCandles = List<CandleEntity>.from(candles);
          if (currentCandles.isNotEmpty &&
              currentCandles.last.candleTime == newCandle.candleTime) {
            currentCandles[currentCandles.length - 1] = newCandle;
          } else {
            currentCandles.add(newCandle);
          }
          candles.value = currentCandles;
        },
        onError: (error) {
          print('Binance WS Error: $error');
        },
      );
    } catch (e) {
      print('Binance WS Connection Error: $e');
    }
  }

  // Crypto: Binance API + WebSocket
  Future<void> _fetchCryptoCandles(
    StockEntity stock,
    String interval,
    int limit,
  ) async {
    final symbol = stock.symbol.toUpperCase();
    final binanceInterval = _mapToBinanceInterval(interval);

    String urlString =
        'https://api.binance.com/api/v3/klines?symbol=${symbol}USDT&interval=$binanceInterval&limit=$limit';

    final response = await http.get(Uri.parse(urlString));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<CandleEntity> loadedCandles = data.map((item) {
        return CandleEntity(
          candleTime: DateTime.fromMillisecondsSinceEpoch(item[0]),
          open: double.parse(item[1]),
          high: double.parse(item[2]),
          low: double.parse(item[3]),
          close: double.parse(item[4]),
          volume: double.parse(item[5]).toInt(),
        );
      }).toList();

      candles.value = loadedCandles;
      _connectToBinanceStream(symbol, binanceInterval);
    } else {
      connectionStatus.value = 'Disconnected';
    }
  }

  Future<void> _fetchBinanceTicker(StockEntity stock) async {
    try {
      String symbol;
      if (stock.symbol == 'GOLD') {
        symbol = 'PAXGUSDT';
      } else if (stock.symbol == 'SILVER') {
        symbol = 'LTCUSDT';
      } else {
        symbol = '${stock.symbol.toUpperCase()}USDT';
      }

      final url = Uri.parse(
        'https://api.binance.com/api/v3/ticker/24hr?symbol=$symbol',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prevClose = double.tryParse(data['prevClosePrice'].toString());

        if (prevClose != null) {
          selectedStock.value = selectedStock.value?.copyWith(
            prevClose: prevClose,
          );
          print('✅ Fetched Prev Close for ${stock.symbol}: $prevClose');
        }
      }
    } catch (e) {
      print('Error fetching Binance ticker for ${stock.symbol}: $e');
    }
  }

  // EGX Stock: Supabase + 20-second polling
  Future<void> _fetchSupabaseCandles(
    StockEntity stock,
    String interval,
    int limit,
  ) async {
    // Hybrid data source strategy:
    // - Intraday (1m-4H): fetch from 1m resolution
    // - Daily (1D): fetch from 1d resolution
    // - Long-term (1W, 1M): fetch from 1d resolution, aggregate

    String fetchResolution;
    int fetchLimit = limit;
    int? aggregateInterval; // in minutes (null = no aggregation)

    if (['1m', '5m', '15m', '30m', '1H', '4H'].contains(interval)) {
      // Intraday: use 1m data (max 2 weeks available)
      fetchResolution = '1m';
      aggregateInterval = _getAggregateMinutes(interval);
    } else if (interval == '1D') {
      // Daily: use 1d data, no aggregation
      fetchResolution = '1d';
      aggregateInterval = null;
    } else {
      // Long-term (1W, 1M): use 1d data, aggregate by days
      fetchResolution = '1d';
      aggregateInterval = _getAggregateDaysAsMinutes(interval);
    }

    print(
      '🔍 Fetching candles for ${stock.symbol} from table ${stock.candleTableName}',
    );
    print(
      '   Requested: $limit rows, Resolution: $fetchResolution, Actual fetchLimit: $fetchLimit',
    );

    List<CandleEntity> data;
    try {
      data = await searchRepository.getStockCandles(
        stock.symbol,
        candleTableName: stock.candleTableName,
        limit: fetchLimit,
        resolution: fetchResolution,
      );
      print('✅ Received ${data.length} rows from Supabase');

      if (data.isEmpty) {
        print('⚠️ WARNING: No data returned from Supabase!');
        print('   Table: ${stock.candleTableName}');
        print('   Resolution: $fetchResolution');
        print('   Limit: $fetchLimit');
        connectionStatus.value = 'Error: No Data';
        candles.value = [];
        return;
      }

      // Log date range of received data
      if (data.isNotEmpty) {
        data.sort((a, b) => a.candleTime.compareTo(b.candleTime));
        print(
          '   Data range: ${data.first.candleTime} to ${data.last.candleTime}',
        );
      }
    } catch (e, stackTrace) {
      print('❌ ERROR fetching candles: $e');
      print('   Stack trace: $stackTrace');
      connectionStatus.value = 'Error';
      candles.value = [];
      return;
    }

    List<CandleEntity> processedData = data;

    // Aggregate if needed
    if (aggregateInterval != null &&
        aggregateInterval > 1 &&
        processedData.isNotEmpty) {
      // Sort before aggregation (aggregator expects sorted data)
      processedData.sort((a, b) => a.candleTime.compareTo(b.candleTime));
      processedData = CandleAggregator.aggregate(
        processedData,
        aggregateInterval,
      );

      // For aggregated intervals, align timestamps to interval boundaries for proper display
      // This ensures 5m candles appear at 10:00, 10:05, 10:10, etc. instead of 10:01, 10:06, etc.
      if (interval != '1m') {
        processedData = _alignCandlesToInterval(processedData, interval);
      }

      // Remove duplicates - keep only one candle per timestamp (keep the first one encountered)
      final Map<String, CandleEntity> uniqueCandles = {};
      for (var candle in processedData) {
        // Use ISO8601 string for precise timestamp matching
        final key = candle.candleTime.toIso8601String();
        if (!uniqueCandles.containsKey(key)) {
          uniqueCandles[key] = candle;
        }
      }
      processedData = uniqueCandles.values.toList();
      processedData.sort((a, b) => a.candleTime.compareTo(b.candleTime));

      print(
        '   ✅ After aggregation: ${processedData.length} candles (no gap filling)',
      );
    } else if (interval == '1m' && processedData.isNotEmpty) {
      // For 1m interval, normalize timestamps and remove duplicates early
      // This handles cases where Supabase returns timestamps with different precision
      processedData.sort((a, b) => a.candleTime.compareTo(b.candleTime));

      final Map<String, CandleEntity> normalizedCandles = {};
      for (var candle in processedData) {
        // Normalize to exact minute (remove seconds/milliseconds)
        final normalized = DateTime(
          candle.candleTime.year,
          candle.candleTime.month,
          candle.candleTime.day,
          candle.candleTime.hour,
          candle.candleTime.minute,
        );
        final key = normalized.toIso8601String();

        // Keep the latest candle if duplicates exist at same minute
        if (!normalizedCandles.containsKey(key) ||
            candle.candleTime.isAfter(normalizedCandles[key]!.candleTime)) {
          normalizedCandles[key] = CandleEntity(
            id: candle.id,
            candleTime: normalized,
            open: candle.open,
            high: candle.high,
            low: candle.low,
            close: candle.close,
            volume: candle.volume,
            timeframe: candle.timeframe,
          );
        }
      }

      processedData = normalizedCandles.values.toList();
      processedData.sort((a, b) => a.candleTime.compareTo(b.candleTime));
      print('   ✅ After 1m normalization: ${processedData.length} candles');
    }

    // For EGX stocks: Display raw data only - NO GAP FILLING
    // Just show what exists in the database, based on timestamps
    if (processedData.isNotEmpty) {
      // For intraday intervals, only show the MOST RECENT trading day
      // to avoid showing multiple days of data which causes confusion
      final isMinuteBased = [
        '1m',
        '5m',
        '15m',
        '30m',
        '1H',
        '4H',
      ].contains(interval);
      List<CandleEntity> finalData = processedData;

      if (isMinuteBased) {
        if (interval == '1m') {
          // For 1m, strictly show ONLY the most recent trading day
          finalData = _getMostRecentTradingDay(processedData);
          print(
            '   📊 Filtered 1m to most recent day: ${finalData.length} candles',
          );
        } else {
          // For others (5m, 1H, etc), keep full history
          finalData = processedData;
          print('   📊 Using all fetched data: ${finalData.length} candles');
        }
      }

      // Sort data chronologically by timestamp
      finalData.sort((a, b) => a.candleTime.compareTo(b.candleTime));

      // Remove any duplicate timestamps (1m is already normalized in previous step)
      final Map<String, CandleEntity> uniqueCandles = {};
      for (var candle in finalData) {
        // Use ISO8601 string for timestamp matching
        final key = candle.candleTime.toIso8601String();

        // Keep only the first candle if duplicates exist at the same timestamp
        if (!uniqueCandles.containsKey(key)) {
          uniqueCandles[key] = candle;
        }
      }

      finalData = uniqueCandles.values.toList();
      finalData.sort((a, b) => a.candleTime.compareTo(b.candleTime));

      print('✅ Final candle count (raw data, no gaps): ${finalData.length}');
      if (finalData.isNotEmpty) {
        print(
          '   Final range: ${finalData.first.candleTime} to ${finalData.last.candleTime}',
        );

        // For 1m, check for potential duplicate timestamps
        if (interval == '1m') {
          final timestampSet = <String>{};
          int duplicateCount = 0;
          for (var candle in finalData) {
            final key = candle.candleTime.toIso8601String();
            if (timestampSet.contains(key)) {
              duplicateCount++;
              print('   ⚠️ Duplicate timestamp found: ${candle.candleTime}');
            } else {
              timestampSet.add(key);
            }
          }
          if (duplicateCount > 0) {
            print(
              '   ⚠️ Found $duplicateCount duplicate timestamps in 1m data',
            );
          } else {
            print('   ✅ No duplicate timestamps in 1m data');
          }
        }
      }

      candles.value = finalData;
    } else {
      // No data
      candles.value = [];
    }

    connectionStatus.value = 'Polling';

    // Start 20-second polling for live updates
    _startPolling(stock, interval, limit);
  }

  /// Get candles from the most recent trading day only
  List<CandleEntity> _getMostRecentTradingDay(List<CandleEntity> candles) {
    if (candles.isEmpty) return [];
    candles.sort((a, b) => b.candleTime.compareTo(a.candleTime));
    final mostRecentDay = DateTime(
      candles.first.candleTime.year,
      candles.first.candleTime.month,
      candles.first.candleTime.day,
    );
    return candles.where((candle) {
      final candleDay = DateTime(
        candle.candleTime.year,
        candle.candleTime.month,
        candle.candleTime.day,
      );
      return candleDay.year == mostRecentDay.year &&
          candleDay.month == mostRecentDay.month &&
          candleDay.day == mostRecentDay.day;
    }).toList();
  }

  /// Align candles to proper interval boundaries (e.g., 10:00, 10:05, 10:10 for 5m)
  List<CandleEntity> _alignCandlesToInterval(
    List<CandleEntity> candles,
    String interval,
  ) {
    return candles.map((candle) {
      final dt = candle.candleTime;
      DateTime alignedTime;

      switch (interval) {
        case '5m':
          // Align to 5-minute boundaries (10:00, 10:05, 10:10, etc.)
          final alignedMinute = (dt.minute ~/ 5) * 5;
          alignedTime = DateTime(
            dt.year,
            dt.month,
            dt.day,
            dt.hour,
            alignedMinute,
          );
          break;
        case '15m':
          // Align to 15-minute boundaries (10:00, 10:15, 10:30, etc.)
          final alignedMinute = (dt.minute ~/ 15) * 15;
          alignedTime = DateTime(
            dt.year,
            dt.month,
            dt.day,
            dt.hour,
            alignedMinute,
          );
          break;
        case '30m':
          // Align to 30-minute boundaries (10:00, 10:30, 11:00, etc.)
          final alignedMinute = (dt.minute ~/ 30) * 30;
          alignedTime = DateTime(
            dt.year,
            dt.month,
            dt.day,
            dt.hour,
            alignedMinute,
          );
          break;
        case '1H':
          // Align to hour boundaries (10:00, 11:00, 12:00, etc.)
          alignedTime = DateTime(dt.year, dt.month, dt.day, dt.hour, 0);
          break;
        default:
          // For 1m, no alignment needed
          alignedTime = dt;
      }

      return CandleEntity(
        id: candle.id,
        candleTime: alignedTime,
        open: candle.open,
        high: candle.high,
        low: candle.low,
        close: candle.close,
        volume: candle.volume,
        timeframe: candle.timeframe,
      );
    }).toList();
  }

  void _startPolling(StockEntity stock, String interval, int limit) {
    _pollingTimer?.cancel();

    // Only poll if market is open
    if (!isMarketOpen) {
      print('Market is closed. Polling disabled.');
      return;
    }

    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      // Double check market hours inside timer
      if (!isMarketOpen) {
        print('Market closed. Stopping polling.');
        timer.cancel();
        return;
      }

      if (selectedStock.value?.symbol != stock.symbol) {
        timer.cancel();
        return;
      }

      try {
        // For intraday intervals, fetch 1m data and process it (NO GAP FILLING)
        if (['1m', '5m', '15m', '30m', '1H'].contains(interval)) {
          final fetchLimit = limit;
          final data = await searchRepository.getStockCandles(
            stock.symbol,
            candleTableName: stock.candleTableName,
            limit: fetchLimit,
            resolution: '1m',
          );

          if (data.isEmpty || selectedStock.value?.symbol != stock.symbol) {
            return;
          }

          List<CandleEntity> processedData = data;

          // Aggregate if needed
          final aggregateInterval = _getAggregateMinutes(interval);
          if (aggregateInterval > 1 && processedData.isNotEmpty) {
            processedData.sort((a, b) => a.candleTime.compareTo(b.candleTime));
            processedData = CandleAggregator.aggregate(
              processedData,
              aggregateInterval,
            );

            // Align aggregated candles to interval boundaries
            if (interval != '1m') {
              processedData = _alignCandlesToInterval(processedData, interval);
            }
          }

          // Filter to most recent trading day only -> REMOVED to allow history
          // final mostRecentDayData = _getMostRecentTradingDay(processedData);
          final mostRecentDayData = processedData; // Keep all data
          if (mostRecentDayData.isEmpty) {
            return;
          }

          // Remove duplicates and sort
          final Map<String, CandleEntity> uniqueCandles = {};
          for (var candle in mostRecentDayData) {
            final key = candle.candleTime.toIso8601String();
            if (!uniqueCandles.containsKey(key)) {
              uniqueCandles[key] = candle;
            }
          }
          final finalData = uniqueCandles.values.toList();
          finalData.sort((a, b) => a.candleTime.compareTo(b.candleTime));

          if (selectedStock.value?.symbol == stock.symbol) {
            candles.value = finalData;
            candles.refresh();
          }
        } else {
          // For other intervals, use direct timeframe query
          final timeframe = _mapToSupabaseTimeframe(interval);
          final data = await searchRepository.getStockCandles(
            stock.symbol,
            candleTableName: stock.candleTableName,
            limit: limit,
            resolution: timeframe,
          );

          // Update candles if we're still on the same stock
          if (selectedStock.value?.symbol == stock.symbol) {
            data.sort((a, b) => a.candleTime.compareTo(b.candleTime));
            candles.value = data;
            candles.refresh();
          }
        }
      } catch (e) {
        print('Polling Error: $e');
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  String _mapToSupabaseTimeframe(String uiInterval) {
    // Map UI intervals to Supabase timeframe values
    switch (uiInterval) {
      case '1m':
        return '1m';
      case '5m':
        return '5m';
      case '15m':
        return '15m';
      case '30m':
        return '30m';
      case '1H':
        return '1h';
      case '4H':
        return '4h';
      case '1D':
        return '1d';
      case '1W':
        return '1w';
      default:
        return '1d';
    }
  }

  String _mapToBinanceInterval(String uiInterval) {
    switch (uiInterval) {
      case '1m':
        return '1m';
      case '5m':
        return '5m';
      case '15m':
        return '15m';
      case '30m':
        return '30m';
      case '1H':
        return '1h';
      case '4H':
        return '4h';
      case '1D':
        return '1d';
      case '1W':
        return '1w';
      case '1M':
        return '1M';
      default:
        return '1d';
    }
  }

  void _connectToBinanceStream(String symbol, String interval) {
    final wsUrl = Uri.parse(
      'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}usdt@kline_$interval',
    );
    _channel = WebSocketChannel.connect(wsUrl);
    connectionStatus.value = 'Connected';

    _channelSubscription = _channel!.stream.listen(
      (message) {
        final data = json.decode(message);
        final k = data['k'];
        final candle = CandleEntity(
          candleTime: DateTime.fromMillisecondsSinceEpoch(k['t']),
          open: double.parse(k['o']),
          high: double.parse(k['h']),
          low: double.parse(k['l']),
          close: double.parse(k['c']),
          volume: double.parse(k['v']).toInt(),
        );

        // Update next close time
        nextCloseTime.value = DateTime.fromMillisecondsSinceEpoch(k['T']);

        // Update the last candle or add a new one
        if (candles.isNotEmpty &&
            candles.last.candleTime.millisecondsSinceEpoch ==
                candle.candleTime.millisecondsSinceEpoch) {
          candles[candles.length - 1] = candle;
        } else {
          candles.add(candle);
        }
        candles.refresh(); // Trigger UI update
      },
      onError: (error) {
        print('WebSocket Error: $error');
        connectionStatus.value = 'Error';
      },
      onDone: () {
        print('WebSocket connection closed.');
        connectionStatus.value = 'Disconnected';
      },
    );
  }

  void _closeWebSocket() {
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _binanceChannel?.sink.close();
    _channelSubscription = null;
    _channel = null;
    _binanceChannel = null;
    connectionStatus.value = 'Disconnected';
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    searchController.dispose();
    _debounce?.cancel();
    _stopPolling();
    _closeWebSocket();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (selectedStock.value != null && isEgxStock) {
        // Resume polling if market is open
        _startPolling(
          selectedStock.value!,
          selectedInterval.value,
          _getLimitForInterval(selectedInterval.value),
        );
      }
    } else if (state == AppLifecycleState.paused) {
      _stopPolling();
    }
  }

  int _getLimitForInterval(String interval) {
    // Limits based on Source Rows (1m candles) needed to cover the duration.
    // EGX ~270 mins/day. Crypto ~1440 mins/day.

    final isEgx = isEgxStock;
    final minsPerDay = isEgx ? 270 : 1440;

    switch (interval) {
      case '1m':
        // Target: 1 day
        return 1 * minsPerDay;
      case '5m':
        // Target: 7 days
        return 7 * minsPerDay;
      case '15m':
        // Target: 14 days
        return 14 * minsPerDay;
      case '30m':
        // Target: 30 days
        return 30 * minsPerDay;
      case '1H':
        // Target: 60 days
        // Note: Capped at 15000 to prevent excessive payload size
        return (60 * minsPerDay).clamp(0, 15000);
      case '4H':
        // Target: 90 days
        // Note: Capped at 20000
        return (90 * minsPerDay).clamp(0, 20000);
      case '1D':
        // Historical table (1 row = 1 day)
        return 730; // 2 years
      case '1W':
        // Target: 5 years (260 weeks). Source: 1d.
        return 260 * 7;
      case '1M':
        // Target: 10 years (120 months). Source: 1d.
        return 120 * 200;
      default:
        return 300;
    }
  }

  int _getAggregateMinutes(String interval) {
    switch (interval) {
      case '1m':
        return 1;
      case '5m':
        return 5;
      case '15m':
        return 15;
      case '30m':
        return 30;
      case '1H':
        return 60;
      case '4H':
        return 240;
      default:
        return 1;
    }
  }

  int _getAggregateDaysAsMinutes(String interval) {
    if (isGoldOrSilver) {
      return interval == '1W' ? 7 * 1440 : 30 * 1440;
    }
    switch (interval) {
      case '1W':
        return 5 * 1440; // 5 trading days in minutes
      case '1M':
        return 22 * 1440; // 22 trading days in minutes
      default:
        return 1440;
    }
  }

  void _connectPopularCryptoSocket() {
    _watchlistChannel?.sink.close();

    // 1. Filter Crypto Assets
    final cryptoSymbols = popularAssets
        .where((stock) => stock.sector == 'Crypto')
        .map((stock) => '${stock.symbol.toLowerCase()}usdt@miniTicker')
        .toList();

    if (cryptoSymbols.isEmpty) return;

    // 2. Construct Stream URL
    // Binance stream format: /stream?streams=<stream1>/<stream2>/...
    final streamParams = cryptoSymbols.join('/');
    final wsUrl = Uri.parse(
      'wss://stream.binance.com:9443/stream?streams=$streamParams',
    );

    print('📡 Connecting Watchlist Socket: $wsUrl');

    try {
      _watchlistChannel = WebSocketChannel.connect(wsUrl);

      _watchlistChannel!.stream.listen(
        (message) {
          final data = json.decode(message);
          // Format: {"stream":"<streamName>", "data":{...}}
          final ticker = data['data'];
          if (ticker != null) {
            _updateAssetFromTicker(ticker);
          }
        },
        onError: (error) {
          print('❌ Watchlist Socket Error: $error');
        },
        onDone: () {
          print('⚠️ Watchlist Socket Closed');
        },
      );
    } catch (e) {
      print('❌ Watchlist Connection Failed: $e');
    }
  }

  void _updateAssetFromTicker(Map<String, dynamic> ticker) {
    // Ticker fields: s (Symbol), c (Close/Current), o (Open/Prev)
    final symbol = ticker['s'].toString().replaceAll('USDT', ''); // Remove USDT
    final currentPrice = double.tryParse(ticker['c'].toString()) ?? 0.0;
    final prevClose =
        double.tryParse(ticker['o'].toString()) ??
        0.0; // using open as proxy for day start

    // Find in popularAssets
    final index = popularAssets.indexWhere((stock) => stock.symbol == symbol);
    if (index != -1) {
      final stock = popularAssets[index];

      // Update only if changed to avoid unnecessary renders
      if (stock.currentPrice != currentPrice || stock.prevClose != prevClose) {
        // Create new copy with updated values
        final updatedStock = stock.copyWith(
          currentPrice: currentPrice,
          prevClose: prevClose,
        );
        popularAssets[index] = updatedStock;
        // popularAssets.refresh(); // Trigger Obx updates - implicit with list assignment?
        // GetX List updates might trigger automatically on index operator if observable.
        // But to be safe with deeply nested objects in List:
        popularAssets.refresh();
      }
    }
  }
}
