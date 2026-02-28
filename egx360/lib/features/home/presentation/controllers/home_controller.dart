import 'dart:async';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/home/domain/entities/market_history_entity.dart';
import 'package:egx/features/home/domain/usecases/get_trending_stocks.dart';
import 'package:egx/features/home/domain/usecases/get_market_overview.dart';
import 'package:egx/features/home/domain/usecases/get_watchlist.dart';
import 'package:egx/features/home/domain/usecases/get_material_price_usecase.dart';
import 'package:egx/features/home/domain/usecases/get_market_history.dart';
import 'package:egx/features/currency/domain/usecases/get_live_currency_prices_usecase.dart';
import 'package:egx/features/home/domain/usecases/remove_from_watchlist.dart';
import 'package:egx/features/home/domain/usecases/get_stock_details.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final GetTrendingStocks getTrendingStocks;
  final GetMarketOverview getMarketOverview;
  final GetWatchlist getWatchlist;
  final GetMaterialPriceUseCase getMaterialPrice;
  final GetMarketHistory getMarketHistory;
  final GetLiveCurrencyPricesUseCase getLiveCurrencyPrices;
  final RemoveFromWatchlistUseCase removeFromWatchlistUseCase;
  final GetStockDetailsUseCase getStockDetailsUseCase;

  final RxList<StockModel> watchlist = <StockModel>[].obs;

  HomeController({
    required this.getTrendingStocks,
    required this.getMarketOverview,
    required this.getWatchlist,
    required this.getMaterialPrice,
    required this.getMarketHistory,
    required this.getLiveCurrencyPrices,
    required this.removeFromWatchlistUseCase,
    required this.getStockDetailsUseCase,
  });

  // Helper for localization
  final s = Get.context!.s;

  // Observables
  final RxList<StockModel> trendingStocks = <StockModel>[].obs;
  final RxList<StockModel> marketIndices = <StockModel>[].obs;
  final Rx<MaterialPriceEntity?> materialPrice = Rx<MaterialPriceEntity?>(null);
  final Rx<MarketHistoryEntity?> marketHistory = Rx<MarketHistoryEntity?>(null);
  final RxMap<String, double> currencyPrices = <String, double>{}.obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchHomeData();
    startPolling();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    stopPolling();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startPolling();
    } else if (state == AppLifecycleState.paused) {
      stopPolling();
    }
  }

  bool get isMarketOpen {
    final now = DateTime.now().toUtc().add(
      const Duration(hours: 2),
    ); // Cairo Time
    // Weekend check (Friday & Saturday)
    if (now.weekday == DateTime.friday || now.weekday == DateTime.saturday) {
      return false;
    }
    // Time check (10:00 AM - 2:30 PM)
    // Time check (10:00 AM - 2:30 PM)
    final start = DateTime.utc(now.year, now.month, now.day, 10, 0);
    final end = DateTime.utc(now.year, now.month, now.day, 14, 50);
    return now.isAfter(start) && now.isBefore(end);
  }

  void startPolling() {
    stopPolling();
    int tickCount = 0;
    // Poll every 20 seconds to update charts and prices
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      tickCount++;
      // Refresh currency every 15 minutes (45 * 20s = 900s)
      final shouldRefreshCurrency = tickCount % 45 == 0;
      // Refresh always to support Crypto/Gold/Silver 24/7
      refreshData(silent: true, includeCurrency: shouldRefreshCurrency);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch all data concurrently
      await Future.wait([
        _fetchTrendingStocks(),
        _fetchMarketOverview(),
        _fetchWatchlist(),
        _fetchMaterialPrice(),
        _fetchMarketHistory(),
        _fetchCurrencyPrices(),
      ]);
    } catch (e) {
      errorMessage.value = '${s.failed_to_load_data}: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData({
    bool silent = false,
    bool includeCurrency = true,
  }) async {
    try {
      if (!silent) isRefreshing.value = true;
      errorMessage.value = '';

      final futures = <Future>[
        _fetchTrendingStocks(),
        _fetchMarketOverview(),
        _fetchWatchlist(),
        _fetchMaterialPrice(),
        _fetchMarketHistory(),
      ];

      if (includeCurrency) {
        futures.add(_fetchCurrencyPrices());
      }

      await Future.wait(futures);
    } catch (e) {
      if (!silent)
        errorMessage.value = '${s.failed_to_refresh_data}: ${e.toString()}';
      print('Error refreshing home data: $e');
    } finally {
      if (!silent) isRefreshing.value = false;
    }
  }

  Future<void> _fetchTrendingStocks() async {
    // Limit to 8 for Home Page
    final stocks = await getTrendingStocks(limit: 8);
    trendingStocks.assignAll(stocks);
  }

  Future<void> fetchFullTrendingStocks() async {
    try {
      isLoading.value = true;
      // Fetch more (e.g., 50)
      final stocks = await getTrendingStocks(limit: 50);
      trendingStocks.assignAll(stocks);
    } catch (e) {
      print('Error fetching full trending stocks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchMarketOverview() async {
    final overview = await getMarketOverview();
    final indices = overview['indices'] as List<StockModel>?;
    if (indices != null) {
      marketIndices.assignAll(indices);
    }
  }

  Future<void> _fetchWatchlist() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        // Initial fetch: limit 5
        final stocks = await getWatchlist(userId, limit: 5);
        watchlist.assignAll(stocks);
      }
    } catch (e) {
      print('Error fetching watchlist: $e');
    }
  }

  Future<void> fetchFullWatchlist() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        isLoading.value = true;
        // Fetch all (or a large number)
        final stocks = await getWatchlist(userId, limit: 100);
        watchlist.assignAll(stocks);
      }
    } catch (e) {
      print('Error fetching full watchlist: $e');
      errorMessage.value = s.failed_to_load_watchlist;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchMaterialPrice() async {
    try {
      final price = await getMaterialPrice();
      materialPrice.value = price;
    } catch (e) {
      print('Error fetching material price: $e');
    }
  }

  Future<void> _fetchMarketHistory() async {
    try {
      final history = await getMarketHistory();
      marketHistory.value = history;
    } catch (e) {
      print('Error fetching market history: $e');
    }
  }

  Future<void> _fetchCurrencyPrices() async {
    try {
      final prices = await getLiveCurrencyPrices();
      print('DEBUG: Fetched currency prices: ${prices.keys.toList()}');
      currencyPrices.assignAll(prices);
    } catch (e) {
      print('Error fetching currency prices: $e');
    }
  }

  Future<void> removeFromWatchlist(String symbol) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // Optimistic update
    final stockToRemove = watchlist.firstWhereOrNull((s) => s.symbol == symbol);
    if (stockToRemove != null) {
      watchlist.remove(stockToRemove);
    }

    try {
      await removeFromWatchlistUseCase(userId, symbol);
      customSnackbar(
        title: s.success_label,
        message: s.removed_from_watchlist_msg(symbol),
        color: Colors.green,
      );
    } catch (e) {
      // Revert if failed
      if (stockToRemove != null) {
        watchlist.add(stockToRemove);
      }
      customSnackbar(
        title: s.error_label,
        message: s.failed_to_remove_from_watchlist_msg(symbol, e.toString()),
        color: Colors.red,
      );
    }
  }

  Future<void> openStockDetails(StockModel partialStock) async {
    // If it's an index, we might not need full details or it's handled differently.
    if (partialStock.sector == 'Indices') {
      Get.toNamed(
        AppPages.stockDetailsPage,
        arguments: {
          ...partialStock.toJson(),
          'stock_name': partialStock.symbol,
          'asset_type': 'index',
        },
      );
      return;
    }

    // If it's Crypto, navigate to CryptoDetailsPage
    if (partialStock.sector == 'Crypto' ||
        partialStock.candleTableName == 'API') {
      Get.toNamed(
        AppPages.cryptoDetailsPage,
        arguments: {
          ...partialStock.toJson(),
          'stock_name': partialStock.symbol,
          'asset_type': 'crypto',
        },
      );
      return;
    }

    try {
      final fullStock = await getStockDetailsUseCase(partialStock.symbol);

      // Merge data: keep sparkline/prices from partial if they are more recent (usually they are from Home polling)
      // Actually, Home polling gives latest price. The fetch gives static details.
      // So we use fullStock for details and partialStock for price/sparkline if needed.
      // But StockModel.fromJson handles nulls.
      // Let's just pass the fullStock, but ensure currentPrice/changePercent are preserved if missing in fullStock (unlikely if DB is updated, but good for safety).

      // Let's just pass the fullStock, but ensure currentPrice/changePercent are preserved if missing in fullStock (unlikely if DB is updated, but good for safety).
      // If we wanted to be super safe about real-time data:
      // mergedStock.currentPrice = partialStock.currentPrice ?? fullStock.currentPrice;
      // But StockModel fields are final.
      // We can just pass the map.

      final stockMap = fullStock.toJson();
      // Ensure we have the latest price/sparkline from the home screen which is live
      if (partialStock.currentPrice != null) {
        stockMap['current_price'] = partialStock.currentPrice;
      }
      if (partialStock.changePercent != null) {
        stockMap['change_percent'] = partialStock.changePercent;
      }
      if (partialStock.sparklineData != null) {
        stockMap['sparkline_data'] = partialStock.sparklineData;
      }

      Get.toNamed(
        AppPages.stockDetailsPage,
        arguments: {
          ...stockMap,
          'stock_name': fullStock.symbol,
          'asset_type': 'stock',
        },
      );
    } catch (e) {
      // Close dialog if open
      if (Get.isDialogOpen == true) Get.back();

      print('Error fetching stock details: $e');
      // Fallback to partial data navigation
    }
  }

  Future<void> openGoldDetails() async {
    final goldStock = StockModel(
      id: 'GOLD',
      symbol: 'GOLD',
      companyNameEn: s.gold_21k_title,
      sector: 'Materials',
      description: s.gold_21k_desc,
    );
    await openStockDetails(goldStock);
  }

  Future<void> openSilverDetails() async {
    final silverStock = StockModel(
      id: 'SILVER',
      symbol: 'SILVER',
      companyNameEn: s.silver_999_title,
      sector: 'Materials',
      description: s.silver_999_desc,
    );
    await openStockDetails(silverStock);
  }
}
