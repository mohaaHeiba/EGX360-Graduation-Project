import 'package:egx/features/search/data/datasources/search_remote_datasource.dart';
import 'package:egx/features/search/data/models/stock_model.dart';
import 'package:egx/features/search/data/models/candle_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Handles all remote data operations for Markets feature
abstract class MarketsRemoteDataSource {
  Future<List<StockModel>> searchAssets(String query);

  Future<List<CandleModel>> getCandles({
    required String symbol,
    required String interval,
    int? limit,
  });

  Future<List<CandleModel>> loadMoreCandles({
    required String symbol,
    required String interval,
    required DateTime before,
    int? limit,
  });
}

class MarketsRemoteDataSourceImpl implements MarketsRemoteDataSource {
  final http.Client httpClient;
  final SearchRemoteDataSource searchDataSource;

  MarketsRemoteDataSourceImpl({
    required this.httpClient,
    required this.searchDataSource,
  });

  @override
  Future<List<StockModel>> searchAssets(String query) async {
    // Delegate to search data source for crypto/stock search
    return await searchDataSource.searchStocks(query, category: 'Crypto');
  }

  @override
  Future<List<CandleModel>> getCandles({
    required String symbol,
    required String interval,
    int? limit,
  }) async {
    final binanceInterval = _mapToBinanceInterval(interval);
    final url = Uri.parse(
      '${dotenv.env['BINANCE_BASE_URL']!}/klines?symbol=${symbol}USDT&interval=$binanceInterval&limit=${limit ?? 500}',
    );

    final response = await httpClient.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => CandleModel.fromBinanceList(item as List))
          .toList();
    } else {
      throw Exception('Failed to load candles: ${response.statusCode}');
    }
  }

  @override
  Future<List<CandleModel>> loadMoreCandles({
    required String symbol,
    required String interval,
    required DateTime before,
    int? limit,
  }) async {
    final binanceInterval = _mapToBinanceInterval(interval);
    final endTime = before.millisecondsSinceEpoch - 1;

    // Calculate start time based on interval
    final lookBackDuration = _getLookBackDuration(interval);
    final startTime = before.subtract(lookBackDuration).millisecondsSinceEpoch;

    final url = Uri.parse(
      '${dotenv.env['BINANCE_BASE_URL']!}/klines?symbol=${symbol}USDT&interval=$binanceInterval&startTime=$startTime&endTime=$endTime&limit=${limit ?? 1000}',
    );

    final response = await httpClient.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => CandleModel.fromBinanceList(item as List))
          .toList();
    } else {
      throw Exception('Failed to load more candles: ${response.statusCode}');
    }
  }

  /// Map UI interval to Binance API interval format
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

  /// Get appropriate look-back duration for loading more data
  Duration _getLookBackDuration(String interval) {
    switch (interval) {
      case '1m':
      case '5m':
      case '15m':
        return const Duration(hours: 24);
      case '30m':
      case '1H':
      case '4H':
        return const Duration(days: 7);
      case '1D':
      case '1W':
        return const Duration(days: 30);
      case '1M':
        return const Duration(days: 90);
      default:
        return const Duration(days: 30);
    }
  }
}
