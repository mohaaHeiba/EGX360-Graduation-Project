import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatbotRemoteDataSource {
  final SupabaseClient _supabase;
  final http.Client _client;

  ChatbotRemoteDataSource({SupabaseClient? supabase, http.Client? client})
      : _supabase = supabase ?? Supabase.instance.client,
        _client = client ?? http.Client();

  // ─── Market Asset Dictionary & News ───────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchSupportedAssets() async {
    try {
      final data = await _supabase.from('stocks').select(
          'symbol, company_name_ar, company_name_en, sector, candle_table_name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('❌ [Chatbot] Failed to fetch supported assets: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchLatestNews([String? symbol]) async {
    try {
      List<dynamic> data = [];
      if (symbol != null && symbol.isNotEmpty) {
        data = await _supabase
            .from('stock_news')
            .select('title, published_at, content, sentiment_label')
            .eq('symbol', symbol)
            .order('published_at', ascending: false)
            .limit(20);
      } else {
        data = await _supabase
            .from('stock_news')
            .select('title, published_at, content, sentiment_label')
            .order('published_at', ascending: false)
            .limit(10);
      }
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  // ─── Analytics & Prediction ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchAiPredictions() async {
    try {
      final data = await _supabase
          .from('ai_predictions')
          .select('symbol, probability, close_price')
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchAssetAnalytics(String symbol) async {
    try {
      final data = await _supabase
          .rpc('compute_asset_analytics', params: {'p_symbol': symbol});
      if (data != null && data is Map<String, dynamic>) {
        return data;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchLatestAiPrediction(String symbol) async {
    try {
      final data = await _supabase
          .rpc('get_latest_ai_prediction', params: {'p_symbol': symbol});
      if (data != null && data is List && data.isNotEmpty) {
        return data.first as Map<String, dynamic>;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<double?> fetchUsdPrice() async {
    try {
      const url = 'https://script.google.com/macros/s/AKfycbzPwlV6491xdBv6LzO2iLsXdff999n99vRFlFNVp8CbsquyztaXLbUf1DwqeUowbiMFEg/exec?type=live';
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return (data['USD/EGP'] as num?)?.toDouble();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── Trends ────────────────────────────────────────────────────────────

  Future<List<dynamic>> fetchMarketPrices() async {
    try {
      final data = await _supabase.rpc(
        'get_stocks_with_sparklines',
        params: {'row_limit': 50},
      );
      return data as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchTrendingStocks() async {
    try {
      final data = await _supabase.rpc('get_trending_stocks',
          params: {'row_limit': 10});
      return List<Map<String, dynamic>>.from(data as List);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchTrendingCrypto() async {
    try {
      final baseUrl =
          dotenv.env['BINANCE_BASE_URL'] ?? 'https://api.binance.com/api/v3';
      final url = Uri.parse('$baseUrl/ticker/24hr');
      final response = await http.Client().get(url);
      if (response.statusCode != 200) return [];

      final List<dynamic> allTickers = json.decode(response.body);

      final usdtPairs = allTickers
          .where((t) => t['symbol']?.toString().endsWith('USDT') == true)
          .toList();
      usdtPairs.sort((a, b) {
        final volA = double.tryParse(a['quoteVolume']?.toString() ?? '0') ?? 0;
        final volB = double.tryParse(b['quoteVolume']?.toString() ?? '0') ?? 0;
        return volB.compareTo(volA);
      });

      return usdtPairs.take(10).map((t) {
        final sym = t['symbol']?.toString().replaceAll('USDT', '') ?? '';
        return <String, dynamic>{
          'symbol': sym,
          'price': double.tryParse(t['lastPrice']?.toString() ?? '0') ?? 0,
          'change_pct':
              double.tryParse(t['priceChangePercent']?.toString() ?? '0') ?? 0,
          'volume': double.tryParse(t['quoteVolume']?.toString() ?? '0') ?? 0,
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── User Context Data ────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchWallet(String userId) async {
    try {
      final data = await _supabase
          .from('user_wallets')
          .select('balance, initial_balance')
          .eq('user_id', userId)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchHoldings(String userId) async {
    try {
      final data = await _supabase
          .from('user_holdings')
          .select('symbol, quantity, average_price')
          .eq('user_id', userId)
          .gt('quantity', 0);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchTransactions(String userId) async {
    try {
      final data = await _supabase
          .from('user_transactions')
          .select('symbol, type, quantity, price, total_value, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchWatchlist(String userId) async {
    try {
      final data = await _supabase
          .from('user_watchlist')
          .select('stock_symbol')
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProtectionRules(String userId) async {
    try {
      final data = await _supabase
          .from('user_protection_rules')
          .select(
            'symbol, alert_percentage, liquidation_percentage, is_alert_enabled, is_sell_enabled',
          )
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommunityPulse() async {
    try {
      final data = await _supabase
          .from('posts')
          .select('content, sentiment, created_at, profiles(name)')
          .order('created_at', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }
}
