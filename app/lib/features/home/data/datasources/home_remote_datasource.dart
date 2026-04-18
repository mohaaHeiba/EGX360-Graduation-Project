import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/data/models/news_model.dart';
import 'package:egx/features/home/data/models/material_price_model.dart';
import 'package:egx/features/home/data/models/market_history_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeRemoteDataSource {
  Future<List<StockModel>> getTrendingStocks({int limit = 10});
  Future<List<StockModel>> getMarketIndices();
  Future<List<NewsModel>> getLatestNews({int limit = 5});
  Future<Map<String, dynamic>> getMarketOverview();
  Future<List<StockModel>> getWatchlist(
    String userId, {
    int limit = 5,
    int offset = 0,
  });
  Future<List<String>> getWatchlistSymbols(String userId);
  Future<List<StockModel>> getStocksBySymbols(List<String> symbols);
  Future<MaterialPriceModel?> getLatestMaterialPrice();
  Future<MarketHistoryModel?> getLatestMarketHistory();
  Future<void> removeFromWatchlist(String userId, String symbol);
  Future<StockModel> getStockDetails(String symbol);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabase;

  HomeRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<StockModel>> getTrendingStocks({int limit = 10}) async {
    // Call the new RPC function
    final response = await supabase.rpc(
      'get_trending_stocks',
      params: {'row_limit': limit},
    );

    return (response as List).map((e) {
      // Map the new RPC response keys to StockModel keys
      final Map<String, dynamic> data = {
        'id': e['id'],
        'symbol': e['symbol'],
        'company_name_en': e['name_en'],
        'current_price': e['price'],
        'change_percent': e['change_pct'],
        'logo_url': e['logo'],
        'sector': 'Stock', // Default sector as it's filtered in SQL
      };

      // Handle sparkline data parsing
      if (e['spark'] != null) {
        final sparkList = e['spark'] as List;
        if (sparkList.isNotEmpty) {
          // Check if it's a list of objects ({"close": 10}) or numbers
          if (sparkList.first is Map) {
            data['sparkline_data'] = sparkList
                .map((item) => (item['close'] as num).toDouble())
                .toList();
          } else {
            data['sparkline_data'] = sparkList;
          }
        } else {
          data['sparkline_data'] = <double>[];
        }
      }

      return StockModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<StockModel>> getMarketIndices() async {
    // Use custom RPC for indices to avoid loop
    final response = await supabase.rpc('get_indices_with_sparklines');

    return (response as List).map((e) => StockModel.fromJson(e)).toList();
  }

  @override
  Future<List<NewsModel>> getLatestNews({int limit = 5}) async {
    final response = await supabase
        .from('stock_news')
        .select('*, stocks(id, symbol, logo_url)')
        .order('published_at', ascending: false)
        .limit(limit);

    return (response as List).map((e) => NewsModel.fromJson(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> getMarketOverview() async {
    // Get market indices data
    final indices = await getMarketIndices();

    // Get top gainer and loser
    final stocks = await getTrendingStocks(limit: 20);

    return {
      'indices': indices,
      'topGainer': stocks.isNotEmpty ? stocks.first : null,
      'topLoser': stocks.length > 1 ? stocks.last : null,
    };
  }

  @override
  Future<List<StockModel>> getWatchlist(
    String userId, {
    int limit = 5,
    int offset = 0,
  }) async {
    try {
      // Use custom RPC for watchlist to get sparklines
      // Note: RPC might not support limit/offset yet, so we fetch all and let Repository handle filtering if needed.
      // Or if RPC supports it, we should update this. For now, reverting to fetch all to be safe.
      final response = await supabase.rpc(
        'get_watchlist_with_sparklines',
        params: {'viewer_id': userId},
      );

      return (response as List).map((e) => StockModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch watchlist: $e');
    }
  }

  @override
  Future<List<String>> getWatchlistSymbols(String userId) async {
    try {
      final response = await supabase
          .from('user_watchlist')
          .select('stock_symbol')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => e['stock_symbol'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch watchlist symbols: $e');
    }
  }

  @override
  Future<List<StockModel>> getStocksBySymbols(List<String> symbols) async {
    if (symbols.isEmpty) return [];
    try {
      final response = await supabase
          .from('stocks')
          .select()
          .inFilter('symbol', symbols);

      return (response as List).map((e) => StockModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch stocks by symbols: $e');
    }
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
  Future<MarketHistoryModel?> getLatestMarketHistory() async {
    final response = await supabase
        .from('market_history')
        .select()
        .order('trade_date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return MarketHistoryModel.fromJson(response);
  }

  @override
  Future<void> removeFromWatchlist(String userId, String symbol) async {
    try {
      await supabase.from('user_watchlist').delete().match({
        'user_id': userId,
        'stock_symbol': symbol,
      });
    } catch (e) {
      throw Exception('Failed to remove from watchlist: $e');
    }
  }

  @override
  Future<StockModel> getStockDetails(String symbol) async {
    try {
      final response = await supabase
          .from('stocks')
          .select()
          .eq('symbol', symbol)
          .single();

      return StockModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch stock details: $e');
    }
  }
}
