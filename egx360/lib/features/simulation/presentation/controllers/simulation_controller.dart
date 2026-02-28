import 'dart:async';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';
import 'package:egx/features/simulation/domain/entities/holding_entity.dart';
import 'package:egx/features/simulation/domain/entities/transaction_entity.dart';
import 'package:egx/features/simulation/domain/entities/wallet_entity.dart';
import 'package:egx/features/simulation/domain/entities/protection_rule_entity.dart';
import 'package:egx/features/simulation/domain/usecases/execute_trade_usecase.dart';
import 'package:egx/features/simulation/domain/usecases/get_holdings_usecase.dart';
import 'package:egx/features/simulation/domain/usecases/get_transactions_usecase.dart';
import 'package:egx/features/simulation/domain/usecases/get_wallet_usecase.dart';
import 'package:egx/features/simulation/domain/repositories/simulation_repository.dart';
import 'package:egx/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SimulationController extends GetxController {
  final GetWalletUseCase getWalletUseCase;
  final GetHoldingsUseCase getHoldingsUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final ExecuteTradeUseCase executeTradeUseCase;
  final SimulationRepository repository;

  final SearchRepository searchRepository;

  SimulationController({
    required this.getWalletUseCase,
    required this.getHoldingsUseCase,
    required this.getTransactionsUseCase,
    required this.executeTradeUseCase,
    required this.repository,
    required this.searchRepository,
  });

  // Observables
  final Rx<WalletEntity?> wallet = Rx<WalletEntity?>(null);
  final RxList<HoldingEntity> holdings = <HoldingEntity>[].obs;
  final RxList<TransactionEntity> transactions = <TransactionEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isExecutingTrade = false.obs;
  final RxString errorMessage = ''.obs;

  // Protection Rules (symbol → rule)
  final RxMap<String, ProtectionRuleEntity> protectionRules =
      <String, ProtectionRuleEntity>{}.obs;

  // For holdings with current prices (map of symbol -> current price)
  final RxMap<String, double> currentPrices = <String, double>{}.obs;

  // Cache for StockEntities to know candle table names etc.
  final Map<String, StockEntity> _stockCache = {};
  Timer? _priceUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    fetchSimulationData();
  }

  @override
  void onClose() {
    _priceUpdateTimer?.cancel();
    super.onClose();
  }

  String? get userId => Supabase.instance.client.auth.currentUser?.id;

  // Portfolio Statistics
  double get totalPortfolioValue {
    final cashBalance = wallet.value?.balance ?? 0.0;
    final holdingsValue = holdings.fold<double>(0.0, (sum, holding) {
      final currentPrice =
          currentPrices[holding.symbol] ?? holding.averagePrice;
      return sum + (holding.quantity * currentPrice);
    });
    return cashBalance + holdingsValue;
  }

  double get totalProfitLoss {
    return holdings.fold<double>(0.0, (sum, holding) {
      final currentPrice =
          currentPrices[holding.symbol] ?? holding.averagePrice;
      final currentValue = holding.quantity * currentPrice;
      final costBasis = holding.quantity * holding.averagePrice;
      return sum + (currentValue - costBasis);
    });
  }

  double get totalProfitLossPercent {
    final initialBalance = wallet.value?.initialBalance ?? 100000.0;
    if (initialBalance == 0) return 0.0;
    return (totalProfitLoss / initialBalance) * 100;
  }

  int get positionsCount => holdings.length;

  // Fetch all simulation data
  Future<void> fetchSimulationData() async {
    if (userId == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await Future.wait([
        fetchWallet(),
        fetchHoldings(),
        fetchProtectionRules(),
      ]);

      // After fetching holdings, start updating prices
      _updateStockCache();
      _startPriceUpdates();
    } catch (e) {
      errorMessage.value = '${S.current.sim_failed_to_load}: $e';
      print('Error fetching simulation data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWallet() async {
    if (userId == null) return;
    try {
      final result = await getWalletUseCase(userId!);
      wallet.value = result;
    } catch (e) {
      throw Exception('${S.current.sim_failed_to_fetch_wallet}: $e');
    }
  }

  Future<void> fetchHoldings() async {
    if (userId == null) return;
    try {
      final result = await getHoldingsUseCase(userId!);
      holdings.assignAll(result);
    } catch (e) {
      throw Exception('${S.current.sim_failed_to_fetch_holdings}: $e');
    }
  }

  Future<void> fetchTransactions({int limit = 50, int offset = 0}) async {
    if (userId == null) return;
    try {
      final result = await getTransactionsUseCase(
        userId!,
        limit: limit,
        offset: offset,
      );
      if (offset == 0) {
        transactions.assignAll(result);
      } else {
        transactions.addAll(result);
      }
    } catch (e) {
      throw Exception('${S.current.sim_failed_to_fetch_transactions}: $e');
    }
  }

  // Execute a trade (buy or sell)
  Future<void> executeTrade({
    required String symbol,
    required String type,
    required double quantity,
    required double price,
  }) async {
    if (userId == null) {
      throw Exception(S.current.sim_user_not_auth);
    }

    try {
      isExecutingTrade.value = true;
      errorMessage.value = '';

      await executeTradeUseCase(
        userId: userId!,
        symbol: symbol,
        type: type,
        quantity: quantity,
        price: price,
      );

      // Refresh data after successful trade
      await Future.wait([fetchWallet(), fetchHoldings()]);

      // Update cache and prices for new holdings
      _updateStockCache();
      _fetchLatestPrices(); // Immediate update
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isExecutingTrade.value = false;
    }
  }

  // Update current price for a symbol (called from Markets/Stocks page)
  void updateCurrentPrice(String symbol, double price) {
    currentPrices[symbol] = price;
  }

  // Calculate P&L for a specific holding
  double getHoldingProfitLoss(HoldingEntity holding) {
    final currentPrice = currentPrices[holding.symbol] ?? holding.averagePrice;
    final currentValue = holding.quantity * currentPrice;
    final costBasis = holding.quantity * holding.averagePrice;
    return currentValue - costBasis;
  }

  double getHoldingProfitLossPercent(HoldingEntity holding) {
    final costBasis = holding.quantity * holding.averagePrice;
    if (costBasis == 0) return 0.0;
    final pl = getHoldingProfitLoss(holding);
    return (pl / costBasis) * 100;
  }

  // Refresh all data (pull to refresh)
  Future<void> refresh() async {
    await fetchSimulationData();
  }

  // ── Protection Rules ──

  ProtectionRuleEntity? getProtectionRule(String symbol) {
    return protectionRules[symbol];
  }

  bool hasProtectionRule(String symbol) {
    return protectionRules.containsKey(symbol);
  }

  Future<void> fetchProtectionRules() async {
    if (userId == null) return;
    try {
      final rules = await repository.getProtectionRules(userId!);
      protectionRules.clear();
      for (final rule in rules) {
        protectionRules[rule.symbol] = rule;
      }
    } catch (e) {
      print('Error fetching protection rules: $e');
    }
  }

  Future<void> saveProtectionRule({
    required String symbol,
    required double alertPercentage,
    required double liquidationPercentage,
    required bool isAlertEnabled,
    required bool isSellEnabled,
  }) async {
    if (userId == null) return;
    try {
      await repository.upsertProtectionRule(
        userId: userId!,
        symbol: symbol,
        alertPercentage: alertPercentage,
        liquidationPercentage: liquidationPercentage,
        isAlertEnabled: isAlertEnabled,
        isSellEnabled: isSellEnabled,
      );
      // Refresh rules
      await fetchProtectionRules();
    } catch (e) {
      print('Error saving protection rule: $e');
      rethrow;
    }
  }

  Future<void> deleteProtectionRule(String symbol) async {
    if (userId == null) return;
    try {
      await repository.deleteProtectionRule(userId!, symbol);
      protectionRules.remove(symbol);
    } catch (e) {
      print('Error deleting protection rule: $e');
      rethrow;
    }
  }

  // --- Real-time Price Updates Logic ---

  Future<void> _updateStockCache() async {
    for (final holding in holdings) {
      if (!_stockCache.containsKey(holding.symbol)) {
        try {
          final results = await searchRepository.searchStocks(holding.symbol);
          if (results.isNotEmpty) {
            // Find exact match or first result
            // ignore: unnecessary_cast
            final match = (results as List<StockEntity>).firstWhere(
              (s) => s.symbol == holding.symbol,
              orElse: () => results.first,
            );
            _stockCache[holding.symbol] = match;
          }
        } catch (e) {
          print('Error caching stock info for ${holding.symbol}: $e');
        }
      }
    }
  }

  void _startPriceUpdates() {
    _priceUpdateTimer?.cancel();
    // Initial fetch
    _fetchLatestPrices();

    // Poll every 15 seconds
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchLatestPrices();
    });
  }

  Future<void> _fetchLatestPrices() async {
    if (holdings.isEmpty) return;

    for (final holding in holdings) {
      try {
        final stock = await searchRepository.getStockBySymbol(holding.symbol);

        // precise current price logic
        if (stock.currentPrice != null) {
          updateCurrentPrice(holding.symbol, stock.currentPrice!);
        }

        // Update cache
        _stockCache[holding.symbol] = stock;
      } catch (e) {
        print('Error updating price for ${holding.symbol}: $e');
      }
    }
  }
}
