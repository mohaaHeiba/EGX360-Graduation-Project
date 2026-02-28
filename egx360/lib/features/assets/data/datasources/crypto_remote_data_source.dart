import 'dart:convert';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class CryptoRemoteDataSource {
  Future<List<CandleEntity>> fetchHistoricalData({
    required String symbol,
    required String interval,
    required int limit,
  });

  Future<Map<String, dynamic>> fetch24hrTicker(String symbol);
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  final http.Client client;

  CryptoRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CandleEntity>> fetchHistoricalData({
    required String symbol,
    required String interval,
    required int limit,
  }) async {
    final url = Uri.parse(
      '${dotenv.env['BINANCE_BASE_URL']}/klines?symbol=${symbol}USDT&interval=$interval&limit=$limit',
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
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
      throw Exception('Failed to load klines: ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, dynamic>> fetch24hrTicker(String symbol) async {
    final url = Uri.parse(
      '${dotenv.env['BINANCE_BASE_URL']}/ticker/24hr?symbol=${symbol}USDT',
    );
    final response = await client.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load 24hr ticker: ${response.statusCode}');
    }
  }
}
