import 'dart:convert';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:http/http.dart' as http;

abstract class CurrencyRemoteDataSource {
  Future<Map<String, double>> getLivePrices();
  Future<List<CandleEntity>> getHistory(String symbol, int days);
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  static const String _baseUrl =
      'https://script.google.com/macros/s/AKfycbzPwlV6491xdBv6LzO2iLsXdff999n99vRFlFNVp8CbsquyztaXLbUf1DwqeUowbiMFEg/exec';

  final http.Client client;

  CurrencyRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, double>> getLivePrices() async {
    final url = Uri.parse('$_baseUrl?type=live');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final Map<String, double> prices = {};
      data.forEach((key, value) {
        if (value is num) prices[key] = value.toDouble();
      });
      return prices;
    } else {
      throw Exception('Failed to load live currency prices');
    }
  }

  @override
  Future<List<CandleEntity>> getHistory(String symbol, int days) async {
    final url = Uri.parse('$_baseUrl?type=history&symbol=$symbol&days=$days');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((item) {
          final date = DateTime.parse(item['date']);
          final price = (item['price'] as num).toDouble();
          return CandleEntity(
            candleTime: date,
            open: price,
            high: price,
            low: price,
            close: price,
            volume: 0,
          );
        }).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load currency history');
    }
  }
}
