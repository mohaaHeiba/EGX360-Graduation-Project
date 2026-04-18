import 'dart:convert';
import 'package:egx/features/markets/presentation/controllers/markets_controller.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SeasonalityDataPoint {
  final DateTime date;
  final double percentageReturn;
  final double closePrice;

  SeasonalityDataPoint({
    required this.date,
    required this.percentageReturn,
    required this.closePrice,
  });
}

class SeasonalitySeries {
  final int year;
  final List<SeasonalityDataPoint> dataPoints;
  final Color color;

  SeasonalitySeries({
    required this.year,
    required this.dataPoints,
    required this.color,
  });
}

class SeasonalsController extends GetxController {
  final MarketsController marketsController = Get.find<MarketsController>();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var seasonalsSeries = <SeasonalitySeries>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to stock changes
    ever(marketsController.selectedStock, (StockEntity? stock) {
      if (stock != null) {
        fetchSeasonalityData(stock);
      }
    });

    // Fetch initial if already set
    if (marketsController.selectedStock.value != null) {
      fetchSeasonalityData(marketsController.selectedStock.value!);
    }
  }

  Future<void> fetchSeasonalityData(StockEntity stock) async {
    isLoading.value = true;
    errorMessage.value = '';
    seasonalsSeries.clear();

    try {
      List<CandleEntity> allDailyCandles = [];

      // Fetch 3 years of daily data (roughly 1000 candles)
      if (marketsController.isGoldOrSilver || stock.candleTableName == 'API' || stock.sector == 'Crypto') {
        allDailyCandles = await _fetchFromBinance(stock, 1000);
      } else {
        allDailyCandles = await _fetchFromSupabase(stock, 1000);
      }

      if (allDailyCandles.isEmpty) {
        errorMessage.value = 'No historical data available';
        isLoading.value = false;
        return;
      }

      // Group by year
      final Map<int, List<CandleEntity>> groupedByYear = {};
      for (var candle in allDailyCandles) {
        final year = candle.candleTime.year;
        if (!groupedByYear.containsKey(year)) {
          groupedByYear[year] = [];
        }
        groupedByYear[year]!.add(candle);
      }

      // Generate Series
      final colors = [
        Colors.blueAccent,
        Colors.greenAccent,
        Colors.orangeAccent,
        Colors.purpleAccent,
      ];
      int colorIndex = 0;

      final List<SeasonalitySeries> generatedSeries = [];
      
      // Sort years descending (e.g. 2026, 2025, 2024)
      final sortedYears = groupedByYear.keys.toList()..sort((a, b) => b.compareTo(a));
      // Take only the last 3 full/partial years
      final yearsToProcess = sortedYears.take(3).toList();

      for (var year in yearsToProcess) {
        final yearCandles = groupedByYear[year]!;
        yearCandles.sort((a, b) => a.candleTime.compareTo(b.candleTime));

        if (yearCandles.isEmpty) continue;

        final firstClose = yearCandles.first.close;
        final List<SeasonalityDataPoint> dataPoints = [];

        for (var candle in yearCandles) {
          // Calculate YTD return
          final ytdReturn = firstClose > 0 ? ((candle.close - firstClose) / firstClose) * 100 : 0.0;
          
          // Map all dates to a standard leap year (e.g. 2024) so they overlap on the X-axis
          final commonDate = DateTime(2024, candle.candleTime.month, candle.candleTime.day);

          dataPoints.add(
            SeasonalityDataPoint(
              date: commonDate,
              percentageReturn: ytdReturn,
              closePrice: candle.close,
            ),
          );
        }

        generatedSeries.add(
          SeasonalitySeries(
            year: year,
            dataPoints: dataPoints,
            color: colors[colorIndex % colors.length],
          ),
        );
        colorIndex++;
      }

      seasonalsSeries.value = generatedSeries;

    } catch (e) {
      print('Error fetching seasonals: $e');
      errorMessage.value = 'Failed to load seasonality data';
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CandleEntity>> _fetchFromBinance(StockEntity stock, int limit) async {
    String symbol;
    if (marketsController.isGoldOrSilver) {
      symbol = marketsController.binanceSymbol;
    } else {
      symbol = '${stock.symbol.toUpperCase()}USDT';
    }

    final url = Uri.parse('https://api.binance.com/api/v3/klines?symbol=$symbol&interval=1d&limit=$limit');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        return CandleEntity(
          candleTime: DateTime.fromMillisecondsSinceEpoch(item[0]),
          open: double.parse(item[1]),
          high: double.parse(item[2]),
          low: double.parse(item[3]),
          close: double.parse(item[4]),
          volume: double.parse(item[5]).toInt(),
          timeframe: '1d',
        );
      }).toList();
    }
    return [];
  }

  Future<List<CandleEntity>> _fetchFromSupabase(StockEntity stock, int limit) async {
    return await marketsController.searchRepository.getStockCandles(
      stock.symbol,
      candleTableName: stock.candleTableName,
      limit: limit,
      resolution: '1d',
    );
  }
}
