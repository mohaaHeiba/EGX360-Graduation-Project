import 'package:egx/features/markets/data/models/ai_prediction_model.dart';
import 'package:egx/features/search/data/models/candle_model.dart';
import 'package:egx/features/search/data/models/news_model.dart';
import 'package:egx/features/search/data/models/stock_model.dart';
import 'package:egx/features/home/data/models/material_price_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class SearchRemoteDataSource {
  Future<List<StockModel>> searchStocks(String query, {String? category});
  Future<List<StockModel>> getInitialStocks({
    String? category,
    int limit = 5,
    int offset = 0,
  });

  Future<List<NewsModel>> getLatestNews({
    String? category,
    int limit = 10,
    int offset = 0,
  });
  Future<List<NewsModel>> getNewsForStock(
    String stockId, {
    int limit = 10,
    int offset = 0,
  });
  Future<List<NewsModel>> getNewsForSymbols(List<String> symbols);
  Future<List<CandleModel>> getStockCandles(
    String symbol, {
    String? candleTableName,
    DateTime? afterTime,
    String? resolution,
    int? limit,
  });
  Future<void> addToWatchlist(String userId, String symbol);
  Future<void> removeFromWatchlist(String userId, String symbol);
  Future<bool> isStockInWatchlist(String userId, String symbol);

  Future<MaterialPriceModel?> getLatestMaterialPrice();
  Future<StockModel> getStockBySymbol(String symbol);
  Future<AiPredictionModel?> getLatestAiPrediction(String symbol);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SupabaseClient supabase;

  SearchRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<StockModel>> searchStocks(
    String query, {
    String? category,
  }) async {
    dynamic dbQuery = supabase.from('stocks').select();

    if (category == 'Materials') {
      dbQuery = dbQuery.eq('sector', 'Materials');
    } else if (category == 'Stocks') {
      dbQuery = dbQuery
          .neq('sector', 'Materials')
          .neq('sector', 'Crypto')
          .neq('sector', 'Currencies');
    } else if (category == 'Crypto') {
      dbQuery = dbQuery.eq('sector', 'Crypto');
    } else if (category == 'Indices') {
      dbQuery = dbQuery.eq('sector', 'Indices');
    } else if (category == 'Currencies') {
      dbQuery = dbQuery.eq('sector', 'Currencies');
    }

    final response = await dbQuery
        .or(
          'symbol.ilike.%$query%,company_name_ar.ilike.%$query%,company_name_en.ilike.%$query%',
        )
        .limit(20);

    final stocks = (response as List)
        .map((e) => StockModel.fromJson(e))
        .toList();

    // Fetch latest price for each stock
    final updatedStocks = await Future.wait(
      stocks.map((stock) async {
        // Currencies use Google Sheets API — skip Binance, price shown in detail page
        if (stock.sector == 'Currencies') return stock;

        if (stock.sector == 'Crypto' || stock.candleTableName == 'API') {
          try {
            final url = Uri.parse(
              'https://api.binance.com/api/v3/ticker/price?symbol=${stock.symbol}USDT',
            );
            final response = await http.get(url);
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              final price = double.parse(data['price']);
              return stock.copyWith(currentPrice: price);
            }
          } catch (e) {
            // Ignore error
          }
        } else if (stock.candleTableName != null) {
          try {
            final candleResponse = await supabase
                .from(stock.candleTableName!)
                .select('close')
                .order('timestamp', ascending: false)
                .limit(1)
                .maybeSingle();

            if (candleResponse != null) {
              final closePrice = (candleResponse['close'] as num).toDouble();
              return stock.copyWith(currentPrice: closePrice);
            }
          } catch (e) {
            // Ignore error if table doesn't exist or fetch fails
          }
        }
        return stock;
      }),
    );

    return updatedStocks;
  }

  @override
  Future<List<StockModel>> getInitialStocks({
    String? category,
    int limit = 5,
    int offset = 0,
  }) async {
    dynamic dbQuery = supabase.from('stocks').select();

    if (category == 'Materials') {
      dbQuery = dbQuery.eq('sector', 'Materials');
    } else if (category == 'Stocks') {
      dbQuery = dbQuery
          .neq('sector', 'Materials')
          .neq('sector', 'Crypto')
          .neq('sector', 'Currencies');
    } else if (category == 'Crypto') {
      dbQuery = dbQuery.eq('sector', 'Crypto');
    } else if (category == 'Indices') {
      dbQuery = dbQuery.eq('sector', 'Indices');
    } else if (category == 'Currencies') {
      dbQuery = dbQuery.eq('sector', 'Currencies');
    }

    dbQuery = dbQuery.range(offset, offset + limit - 1);

    final response = await dbQuery;
    final stocks = (response as List)
        .map((e) => StockModel.fromJson(e))
        .toList();

    // Fetch latest price for each stock
    final updatedStocks = await Future.wait(
      stocks.map((stock) async {
        // Currencies use Google Sheets API — skip Binance, price shown in detail page
        if (stock.sector == 'Currencies') return stock;

        if (stock.sector == 'Crypto' || stock.candleTableName == 'API') {
          try {
            final url = Uri.parse(
              'https://api.binance.com/api/v3/ticker/price?symbol=${stock.symbol}USDT',
            );
            final response = await http.get(url);
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              final price = double.parse(data['price']);
              return stock.copyWith(currentPrice: price);
            }
          } catch (e) {
            // Ignore error
          }
        } else if (stock.candleTableName != null) {
          try {
            final candleResponse = await supabase
                .from(stock.candleTableName!)
                .select('close')
                .order('timestamp', ascending: false)
                .limit(1)
                .maybeSingle();

            if (candleResponse != null) {
              final closePrice = (candleResponse['close'] as num).toDouble();
              return stock.copyWith(currentPrice: closePrice);
            }
          } catch (e) {
            // Ignore error
          }
        }
        return stock;
      }),
    );

    return updatedStocks;
  }

  @override
  Future<List<NewsModel>> getLatestNews({
    String? category,
    int limit = 10,
    int offset = 0,
  }) async {
    dynamic dbQuery = supabase
        .from('stock_news')
        .select(
          '*, stocks!inner(id, symbol, logo_url)',
        ); // Use inner join for filtering

    if (category == 'Materials') {
      dbQuery = dbQuery.eq('stocks.sector', 'Materials');
    } else if (category == 'Stocks' || category == 'Indices') {
      dbQuery = dbQuery
          .neq('stocks.sector', 'Materials')
          .neq('stocks.sector', 'Crypto')
          .neq('stocks.sector', 'Currencies');
    } else if (category == 'Crypto') {
      dbQuery = dbQuery.eq('stocks.sector', 'Crypto');
    } else if (category == 'Currencies') {
      dbQuery = dbQuery.eq('stocks.sector', 'Currencies');
    }

    final response = await dbQuery
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => NewsModel.fromJson(e)).toList();
  }

  @override
  Future<List<NewsModel>> getNewsForStock(
    String stockId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await supabase
        .from('stock_news')
        .select('*, stocks(id, symbol, logo_url)')
        .eq('stock_id', stockId)
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => NewsModel.fromJson(e)).toList();
  }

  @override
  Future<List<NewsModel>> getNewsForSymbols(List<String> symbols) async {
    if (symbols.isEmpty) return [];

    final response = await supabase
        .from('stock_news')
        .select('*, stocks!inner(id, symbol, logo_url)')
        .inFilter('stocks.symbol', symbols)
        .order('published_at', ascending: false);

    return (response as List).map((e) => NewsModel.fromJson(e)).toList();
  }

  @override
  Future<List<CandleModel>> getStockCandles(
    String symbol, {
    String? candleTableName,
    DateTime? afterTime,
    String? resolution,
    int? limit,
  }) async {
    final tableName = candleTableName ?? '${symbol.toLowerCase()}_candles';

    if (afterTime != null) {
      // Smart Update (Live polling)
      final response = await supabase
          .from(tableName)
          .select()
          .gte('timestamp', afterTime.toIso8601String())
          .order('timestamp', ascending: true);
      return (response as List).map((e) => CandleModel.fromJson(e)).toList();
    }

    if (limit != null && resolution != null) {
      // Range Query (Limit based)
      // Fetch latest N candles descending, then reverse
      final response = await supabase
          .from(tableName)
          .select()
          .eq('timeframe', resolution)
          .order('timestamp', ascending: false)
          .limit(limit);

      final candles = (response as List)
          .map((e) => CandleModel.fromJson(e))
          .toList();
      return candles.reversed.toList();
    }

    // Fallback / Initial Load
    if (symbol == 'GOLD') {
      final response = await supabase.rpc(
        'get_gold_chart_data',
        params: {'days_limit': 30},
      );
      return (response as List).map((e) => CandleModel.fromJson(e)).toList();
    }

    // Default fallback
    final response = await supabase.rpc(
      'get_chart_history',
      params: {'target_symbol': symbol, 'limit_count': 100},
    );
    return (response as List).map((e) => CandleModel.fromJson(e)).toList();
  }

  @override
  Future<void> addToWatchlist(String userId, String symbol) async {
    await supabase.from('user_watchlist').insert({
      'user_id': userId,
      'stock_symbol': symbol,
    });
  }

  @override
  Future<void> removeFromWatchlist(String userId, String symbol) async {
    await supabase
        .from('user_watchlist')
        .delete()
        .eq('user_id', userId)
        .eq('stock_symbol', symbol);
  }

  @override
  Future<bool> isStockInWatchlist(String userId, String symbol) async {
    final response = await supabase
        .from('user_watchlist')
        .select()
        .eq('user_id', userId)
        .eq('stock_symbol', symbol)
        .maybeSingle();
    return response != null;
  }

  @override
  Future<StockModel> getStockBySymbol(String symbol) async {
    // 1. Fetch stock details
    final response = await supabase
        .from('stocks')
        .select()
        .eq('symbol', symbol)
        .maybeSingle();

    if (response == null) {
      throw Exception('Stock not found: $symbol');
    }

    StockModel stock = StockModel.fromJson(response);

    // 2. Fetch latest price
    // Currencies use Google Sheets API — skip Binance, price shown in detail page
    if (stock.sector == 'Currencies') {
      return stock;
    } else if (stock.sector == 'Crypto' || stock.candleTableName == 'API') {
      try {
        final url = Uri.parse(
          'https://api.binance.com/api/v3/ticker/price?symbol=${stock.symbol}USDT',
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final price = double.parse(data['price']);
          return stock.copyWith(currentPrice: price);
        }
      } catch (e) {
        // Fallback or ignore
      }
    } else if (stock.candleTableName != null) {
      try {
        final candleResponse = await supabase
            .from(stock.candleTableName!)
            .select('close')
            .order('timestamp', ascending: false)
            .limit(1)
            .maybeSingle();

        if (candleResponse != null) {
          final closePrice = (candleResponse['close'] as num).toDouble();
          return stock.copyWith(currentPrice: closePrice);
        }
      } catch (e) {
        // Fallback or ignore
      }
    } else if (symbol == 'GOLD' || symbol == 'SILVER') {
      // Special handling for Gold/Silver if they don't have candleTableName set correctly yet
      // Try Binance first
      try {
        final binanceSym = symbol == 'GOLD' ? 'PAXG' : 'LTC';
        final url = Uri.parse(
          'https://api.binance.com/api/v3/ticker/price?symbol=${binanceSym}USDT',
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final price = double.parse(data['price']);
          return stock.copyWith(currentPrice: price);
        }
      } catch (e) {
        // Ignore
      }
    }

    return stock;
  }

  @override
  Future<MaterialPriceModel?> getLatestMaterialPrice() async {
    final response = await supabase
        .from('materials_prices')
        .select()
        .order('timestamp', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return MaterialPriceModel.fromJson(response);
  }

  @override
  Future<AiPredictionModel?> getLatestAiPrediction(String symbol) async {
    try {
      final response = await supabase
          .from('ai_predictions')
          .select()
          .eq('symbol', symbol)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return AiPredictionModel.fromMap(response);
    } catch (e) {
      print('Error fetching AI prediction: $e');
      return null;
    }
  }
}
