import 'dart:convert';
import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Hybrid data source for US Stocks & ETFs.
///
/// Uses two providers:
/// - **Massive/Polygon API** for historical End-of-Day candles (1D, 1W, 1M)
/// - **Finnhub API** for real-time quotes and WebSocket trade streams
abstract class UsStocksRemoteDataSource {
  /// Fetch historical EOD candles from Massive/Polygon API.
  /// [timespan] must be one of: 'day', 'week', 'month'
  /// [from] and [to] are date strings in YYYY-MM-DD format.
  Future<List<CandleEntity>> fetchHistoricalData({
    required String symbol,
    required String timespan,
    required String from,
    required String to,
    int multiplier = 1,
  });

  /// Fetch real-time quote from Finnhub.
  /// Returns: { c, d, dp, h, l, o, pc, t }
  Future<Map<String, dynamic>> fetchQuote(String symbol);

  /// Build a synthetic "live candle" from a Finnhub quote response.
  CandleEntity buildLiveCandleFromQuote(Map<String, dynamic> quoteData);
}

class UsStocksRemoteDataSourceImpl implements UsStocksRemoteDataSource {
  final http.Client client;

  UsStocksRemoteDataSourceImpl({required this.client});

  // ── Massive / Polygon: Historical EOD ──────────────────────────────────────

  @override
  Future<List<CandleEntity>> fetchHistoricalData({
    required String symbol,
    required String timespan,
    required String from,
    required String to,
    int multiplier = 1,
  }) async {
    final apiKey = dotenv.env['MASSIVE_API_KEY']!;
    final baseUrl = dotenv.env['MASSIVE_BASE_URL']!;

    final url = Uri.parse(
      '$baseUrl/v2/aggs/ticker/$symbol/range/$multiplier/$timespan/$from/$to'
      '?adjusted=true&sort=asc&apiKey=$apiKey',
    );

    final response = await client.get(url);

    if (response.statusCode == 429) {
      // Rate limited (5 calls/min on free tier) — wait and retry once
      await Future.delayed(const Duration(seconds: 13));
      final retryResponse = await client.get(url);
      return _parseMassiveResponse(retryResponse);
    }

    return _parseMassiveResponse(response);
  }

  List<CandleEntity> _parseMassiveResponse(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final String status = body['status'] ?? '';

      // Polygon free tier returns 'DELAYED', paid returns 'OK'
      if ((status == 'OK' || status == 'DELAYED') && body['results'] != null) {
        final List<dynamic> results = body['results'];
        return results.map((item) {
          return CandleEntity(
            candleTime: DateTime.fromMillisecondsSinceEpoch(
              item['t'] as int,
              isUtc: true,
            ),
            open: (item['o'] as num).toDouble(),
            high: (item['h'] as num).toDouble(),
            low: (item['l'] as num).toDouble(),
            close: (item['c'] as num).toDouble(),
            volume: (item['v'] as num).toInt(),
          );
        }).toList();
      }

      // status == 'OK' but no results (weekend/holiday)
      return [];
    } else {
      throw Exception(
        'Massive API error: ${response.statusCode} — ${response.body}',
      );
    }
  }

  // ── Finnhub: Real-time Quote ───────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> fetchQuote(String symbol) async {
    final apiKey = dotenv.env['FINNHUB_API_KEY']!;
    final baseUrl = dotenv.env['FINNHUB_BASE_URL']!;

    final url = Uri.parse('$baseUrl/quote?symbol=$symbol&token=$apiKey');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Finnhub quote error: ${response.statusCode} — ${response.body}',
      );
    }
  }

  // ── Live Candle Builder ────────────────────────────────────────────────────

  @override
  CandleEntity buildLiveCandleFromQuote(Map<String, dynamic> quoteData) {
    // Finnhub /quote response fields:
    // c = current price, d = change, dp = percent change
    // h = high of day, l = low of day, o = open, pc = previous close
    // t = timestamp (UNIX seconds)
    return CandleEntity(
      candleTime: DateTime.fromMillisecondsSinceEpoch(
        ((quoteData['t'] as num?) ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000)).toInt() * 1000,
        isUtc: true,
      ),
      open: (quoteData['o'] as num).toDouble(),
      high: (quoteData['h'] as num).toDouble(),
      low: (quoteData['l'] as num).toDouble(),
      close: (quoteData['c'] as num).toDouble(),
      volume: 0, // Finnhub quote doesn't include volume
    );
  }
}
