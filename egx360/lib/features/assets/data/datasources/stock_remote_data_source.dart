import 'package:egx/features/home/data/models/material_price_model.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class StockRemoteDataSource {
  Future<List<CandleEntity>> fetchStockCandles({
    required String tableName,
    required String interval,
    int limit = 100,
    DateTime? startTime,
  });

  Future<List<NewsEntity>> fetchStockNews({
    required String stockId,
    int limit = 10,
    int offset = 0,
  });

  Future<MaterialPriceModel> fetchMaterialPrice();

  Future<List<CandleEntity>> fetchBinanceHistoricalData({
    required String symbol,
    required String interval,
    int limit = 100,
  });
}

class StockRemoteDataSourceImpl implements StockRemoteDataSource {
  final SupabaseClient client;
  final http.Client httpClient;

  StockRemoteDataSourceImpl(this.client, {http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  @override
  Future<List<CandleEntity>> fetchStockCandles({
    required String tableName,
    required String interval,
    int limit = 100,
    DateTime? startTime,
  }) async {
    try {
      var query = client.from(tableName).select();

      if (startTime != null) {
        query = query.gte('timestamp', startTime.toIso8601String());
      }

      final response = await query
          .eq('timeframe', interval)
          .order('timestamp', ascending: false)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((json) {
            return CandleEntity(
              candleTime: DateTime.parse(json['timestamp']),
              open: (json['open'] as num).toDouble(),
              high: (json['high'] as num).toDouble(),
              low: (json['low'] as num).toDouble(),
              close: (json['close'] as num).toDouble(),
              volume: (json['volume'] as num).toInt(),
            );
          })
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch stock candles: $e');
    }
  }

  @override
  Future<List<NewsEntity>> fetchStockNews({
    required String stockId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('stock_news')
          .select()
          .eq('stock_id', stockId)
          .order('published_at', ascending: false)
          .range(offset, offset + limit - 1);

      final List<dynamic> data = response as List<dynamic>;

      return data.map((json) {
        return NewsEntity(
          id: json['id'].toString(),
          title: json['title'] ?? '',
          source: json['source'] ?? '',
          publishedAt: json['published_at'] ?? '',
          content: json['content'] ?? '',
          url: json['url'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch stock news: $e');
    }
  }

  @override
  Future<MaterialPriceModel> fetchMaterialPrice() async {
    try {
      final response = await client
          .from('material_prices')
          .select()
          .order('timestamp', ascending: false)
          .limit(1)
          .single();

      return MaterialPriceModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch material price: $e');
    }
  }

  @override
  Future<List<CandleEntity>> fetchBinanceHistoricalData({
    required String symbol,
    required String interval,
    int limit = 100,
  }) async {
    try {
      // Binance max limit is 1000
      final effectiveLimit = limit > 1000 ? 1000 : limit;

      final url = Uri.parse(
        '${dotenv.env['BINANCE_BASE_URL']}/klines?symbol=$symbol&interval=$interval&limit=$effectiveLimit',
      );

      print('Fetching Binance Data: $url');

      final response = await httpClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Binance Data Fetched: ${data.length} candles');
        return data.map((e) {
          // [timestamp, open, high, low, close, volume, ...]
          return CandleEntity(
            candleTime: DateTime.fromMillisecondsSinceEpoch(e[0], isUtc: true),
            open: double.parse(e[1]),
            high: double.parse(e[2]),
            low: double.parse(e[3]),
            close: double.parse(e[4]),
            volume: double.parse(e[5]).toInt(),
          );
        }).toList();
      } else {
        print('Binance API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load klines: ${response.statusCode}');
      }
    } catch (e) {
      print('Binance Fetch Exception: $e');
      throw Exception('Failed to fetch binance data: $e');
    }
  }
}
