import 'package:egx/features/assets/data/repositories/crypto_repository.dart';
import 'package:egx/features/home/data/datasources/home_remote_datasource.dart';
import 'package:egx/features/home/data/models/news_model.dart';
import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/home/domain/entities/market_history_entity.dart';
import 'package:egx/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final CryptoRepository cryptoRepository;

  HomeRepositoryImpl(this.remoteDataSource, {required this.cryptoRepository});

  @override
  Future<List<StockModel>> getTrendingStocks({int limit = 10}) async {
    return await remoteDataSource.getTrendingStocks(limit: limit);
  }

  @override
  Future<List<StockModel>> getMarketIndices() async {
    return await remoteDataSource.getMarketIndices();
  }

  @override
  Future<List<NewsModel>> getLatestNews({int limit = 5}) async {
    return await remoteDataSource.getLatestNews(limit: limit);
  }

  @override
  Future<Map<String, dynamic>> getMarketOverview() async {
    return await remoteDataSource.getMarketOverview();
  }

  @override
  Future<List<StockModel>> getWatchlist(
    String userId, {
    int limit = 5,
    int offset = 0,
  }) async {
    try {
      // 1. Fetch all watchlist symbols to determine the target page
      final allSymbols = await remoteDataSource.getWatchlistSymbols(userId);

      // 2. Apply pagination to symbols
      if (offset >= allSymbols.length) return [];
      final targetSymbols = allSymbols.skip(offset).take(limit).toList();

      if (targetSymbols.isEmpty) return [];

      // 3. Fetch stocks using RPC (it might return some or all of targetSymbols)
      // We pass limit/offset to RPC as well, hoping it aligns with our symbol sort.
      // If RPC sort differs, we might miss some sparklines, but we'll fetch basic data below.
      final rpcStocks = await remoteDataSource.getWatchlist(
        userId,
        limit: limit,
        offset: offset,
      );

      // 4. Identify which of targetSymbols we have from RPC
      final rpcMap = {for (var s in rpcStocks) s.symbol: s};

      // 5. For any target symbol not in RPC, we need to fetch it
      final missingSymbols = targetSymbols
          .where((s) => !rpcMap.containsKey(s))
          .toList();

      List<StockModel> additionalStocks = [];
      if (missingSymbols.isNotEmpty) {
        // Fetch details for missing symbols
        final missingDetails = await remoteDataSource.getStocksBySymbols(
          missingSymbols,
        );

        // Process Crypto items
        final cryptoFutures = missingDetails.map((stock) async {
          if (stock.sector == 'Crypto') {
            try {
              // Fetch 24hr ticker for price and change
              final ticker = await cryptoRepository.get24hrTicker(stock.symbol);
              final currentPrice = double.parse(ticker['lastPrice']);
              final changePercent = double.parse(ticker['priceChangePercent']);

              // Fetch historical data for sparkline
              final candles = await cryptoRepository.getHistoricalData(
                symbol: stock.symbol,
                interval: '1h',
                limit: 24,
              );

              final sparklineData = candles.map((c) => c.close).toList();

              return StockModel(
                id: stock.id,
                symbol: stock.symbol,
                companyNameEn: stock.companyNameEn,
                companyNameAr: stock.companyNameAr,
                logoUrl: stock.logoUrl,
                sector: 'Crypto',
                description: stock.description,
                isinCode: stock.isinCode,
                website: stock.website,
                listingDate: stock.listingDate,
                totalShares: stock.totalShares,
                currentPrice: currentPrice,
                changePercent: changePercent,
                sparklineData: sparklineData,
                candleTableName: 'API',
              );
            } catch (e) {
              print('Error fetching crypto data for ${stock.symbol}: $e');
              return stock;
            }
          }
          return stock;
        });

        additionalStocks = await Future.wait(cryptoFutures);
      }

      // 6. Combine and sort according to targetSymbols order
      final combinedMap = {...rpcMap};
      for (var s in additionalStocks) {
        combinedMap[s.symbol] = s;
      }

      return targetSymbols
          .map((s) => combinedMap[s])
          .whereType<StockModel>()
          .toList();
    } catch (e) {
      print('Error in getWatchlist: $e');
      // Fallback: try to return what we can from RPC
      return await remoteDataSource.getWatchlist(
        userId,
        limit: limit,
        offset: offset,
      );
    }
  }

  @override
  Future<MaterialPriceEntity?> getLatestMaterialPrice() async {
    return await remoteDataSource.getLatestMaterialPrice();
  }

  @override
  Future<MarketHistoryEntity?> getMarketHistory() async {
    return await remoteDataSource.getLatestMarketHistory();
  }

  @override
  Future<void> removeFromWatchlist(String userId, String symbol) async {
    await remoteDataSource.removeFromWatchlist(userId, symbol);
  }

  @override
  Future<StockModel> getStockDetails(String symbol) async {
    return await remoteDataSource.getStockDetails(symbol);
  }
}
