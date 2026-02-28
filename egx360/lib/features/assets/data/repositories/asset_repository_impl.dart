import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/assets/data/datasources/crypto_remote_data_source.dart';
import 'package:egx/features/assets/data/datasources/stock_remote_data_source.dart';
import 'package:egx/features/assets/domain/repositories/asset_repository.dart';
import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/assets/domain/entities/asset_type.dart';

class AssetRepositoryImpl implements AssetRepository {
  final CryptoRemoteDataSource cryptoRemoteDataSource;
  final StockRemoteDataSource stockRemoteDataSource;

  AssetRepositoryImpl({
    required this.cryptoRemoteDataSource,
    required this.stockRemoteDataSource,
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
        // Use crypto data source (Binance)
        return await cryptoRemoteDataSource.fetchHistoricalData(
          symbol: symbol,
          interval: interval,
          limit: limit,
        );

      case AssetType.stock:
      case AssetType.marketIndex:
      case AssetType.material:
        // Use stock data source (Supabase or Binance for materials)
        // The stock repository already handles hybrid logic for Gold/Silver
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
    // Only applicable for crypto assets
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
}
