import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/assets/data/datasources/crypto_remote_data_source.dart';
import 'package:egx/features/assets/data/datasources/stock_remote_data_source.dart';
import 'package:egx/features/assets/data/datasources/currency_remote_data_source.dart';
import 'package:egx/features/assets/domain/repositories/asset_repository.dart';
import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/assets/domain/entities/asset_type.dart';

class AssetRepositoryImpl implements AssetRepository {
  final CryptoRemoteDataSource cryptoRemoteDataSource;
  final StockRemoteDataSource stockRemoteDataSource;
  final CurrencyRemoteDataSource currencyRemoteDataSource;

  AssetRepositoryImpl({
    required this.cryptoRemoteDataSource,
    required this.stockRemoteDataSource,
    required this.currencyRemoteDataSource,
  });

  @override
  Future<List<CandleEntity>> getAssetCandles({
    required String symbol,
    required AssetType assetType,
    required String interval,
    int limit = 100,
    String? tableName,
    DateTime? startTime,
  }) async {
    switch (assetType) {
      case AssetType.crypto:
        return await cryptoRemoteDataSource.fetchHistoricalData(
          symbol: symbol,
          interval: interval,
          limit: limit,
        );

      case AssetType.stock:
      case AssetType.marketIndex:
      case AssetType.material:
      case AssetType.currency:
        // Currency candle data is fetched via getCurrencyHistory directly
        return await stockRemoteDataSource.fetchStockCandles(
          tableName: tableName ?? 'egx30_candles',
          interval: interval,
          limit: limit,
          startTime: startTime,
        );
    }
  }

  @override
  Future<Map<String, dynamic>> getAsset24hrTicker(String symbol) async {
    return await cryptoRemoteDataSource.fetch24hrTicker(symbol);
  }

  @override
  Future<List<NewsEntity>> getAssetNews({
    required String stockId,
    int limit = 10,
    int offset = 0,
  }) async {
    return await stockRemoteDataSource.fetchStockNews(
      stockId: stockId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<MaterialPriceEntity> getMaterialPrice() async {
    return await stockRemoteDataSource.fetchMaterialPrice();
  }

  @override
  Future<Map<String, double>> getCurrencyLivePrices() async {
    return await currencyRemoteDataSource.getLivePrices();
  }

  @override
  Future<List<CandleEntity>> getCurrencyHistory(String symbol, int days) async {
    return await currencyRemoteDataSource.getHistory(symbol, days);
  }
}
