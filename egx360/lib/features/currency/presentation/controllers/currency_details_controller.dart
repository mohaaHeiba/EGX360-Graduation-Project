import 'package:egx/features/currency/domain/usecases/get_currency_history_usecase.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
// import 'package:egx/features/search/domain/entities/gold_price_entity.dart';
import 'package:get/get.dart';

class CurrencyDetailsController extends GetxController {
  final RxString symbol; // Made observable
  final GetCurrencyHistoryUseCase getCurrencyHistoryUseCase;

  CurrencyDetailsController({
    required String initialSymbol,
    required this.getCurrencyHistoryUseCase,
  }) : symbol = initialSymbol.obs;

  // Observables matching StockDetailsController interface
  var candleData = <CandleEntity>[].obs;
  var isLoadingChart = false.obs;
  var isPositivePerformance = true.obs;
  var selectedTimeRange = '1M'.obs; // Default to 1M for currency
  final List<String> timeRanges = ['1M', '3M', '6M', '1Y', 'ALL'];

  var prevClosePrice = 0.0.obs;
  // var goldPrice = Rx<GoldPriceEntity?>(null); // Placeholder
  var isEgp = true.obs;
  var usdToEgpRate = 1.0;
  var currentRate = 0.0.obs;
  var selectedSpotX = Rx<double?>(null); // For chart interaction

  // Supported Currencies
  final Map<String, String> supportedCurrencies = {
    'USDEGP': 'US Dollar',
    'EUREGP': 'Euro',
    'GBPEGP': 'British Pound',
    'JPYEGP': 'Japanese Yen',
    'CHFEGP': 'Swiss Franc',
    'SAREGP': 'Saudi Riyal',
    'AEDEGP': 'UAE Dirham',
    'KWDEGP': 'Kuwaiti Dinar',
    'QAREGP': 'Qatari Riyal',
    'JODEGP': 'Jordanian Dinar',
  };

  final Map<String, String> currencyFlags = {
    'USDEGP': '🇺🇸',
    'EUREGP': '🇪🇺',
    'GBPEGP': '🇬🇧',
    'JPYEGP': '🇯🇵',
    'CHFEGP': '🇨🇭',
    'SAREGP': '🇸🇦',
    'AEDEGP': '🇦🇪',
    'KWDEGP': '🇰🇼',
    'QAREGP': '🇶🇦',
    'JODEGP': '🇯🇴',
  };

  String get currencyName => supportedCurrencies[symbol.value] ?? symbol.value;
  String get currencyFlag => currencyFlags[symbol.value] ?? '💱';

  @override
  void onInit() {
    super.onInit();
    // Initialize current rate from arguments if available
    if (Get.arguments != null && Get.arguments['current_price'] != null) {
      currentRate.value = (Get.arguments['current_price'] as num).toDouble();
    }
    fetchChartData(selectedTimeRange.value);
  }

  void updateTimeRange(String range) {
    selectedTimeRange.value = range;
    fetchChartData(range);
  }

  void changeCurrency(String newSymbol) {
    if (symbol.value == newSymbol) return;
    symbol.value = newSymbol;
    // Reset data
    candleData.clear();
    currentRate.value = 0.0; // Will be updated by fetch
    fetchChartData(selectedTimeRange.value);
  }

  Future<void> fetchChartData(String range) async {
    isLoadingChart.value = true;
    try {
      int days = 30;
      switch (range) {
        case '1M':
          days = 30;
          break;
        case '3M':
          days = 90;
          break;
        case '6M':
          days = 180;
          break;
        case '1Y':
          days = 365;
          break;
        case 'ALL':
          days = 3650;
          break;
      }

      final candles = await getCurrencyHistoryUseCase(symbol.value, days);

      // Sort by date
      candles.sort((a, b) => a.candleTime.compareTo(b.candleTime));

      // Sample data if range is ALL to avoid too many points (e.g. 5k+)
      // We'll take one point per month
      List<CandleEntity> finalCandles = candles;
      if (range == 'ALL' && candles.length > 100) {
        finalCandles = [];
        String? lastMonth;
        for (var candle in candles) {
          final monthKey =
              '${candle.candleTime.year}-${candle.candleTime.month}';
          if (lastMonth != monthKey) {
            finalCandles.add(candle);
            lastMonth = monthKey;
          }
        }
        // Ensure the very last candle is included (for current price accuracy)
        if (candles.isNotEmpty &&
            finalCandles.isNotEmpty &&
            finalCandles.last.candleTime != candles.last.candleTime) {
          finalCandles.add(candles.last);
        }
      }

      candleData.value = finalCandles;

      if (candles.isNotEmpty) {
        // Update current rate from latest candle if it's more recent or we didn't have one
        if (currentRate.value == 0) {
          currentRate.value = candles.last.close;
        }

        // Set prevClose to the first candle of the period or previous day if available
        isPositivePerformance.value = candles.last.close >= candles.first.close;

        // For the UI "prev close" display
        if (candles.length > 1) {
          prevClosePrice.value = candles[candles.length - 2].close;
        } else {
          prevClosePrice.value = candles.first.close;
        }
      }
    } catch (e) {
      print('Error fetching currency history: $e');
    } finally {
      isLoadingChart.value = false;
    }
  }

  // Placeholder methods to satisfy UI calls if any
  void toggleCurrency() {}
  void toggleWatchlist() {}
  var isWatchlisted = false.obs;
}
