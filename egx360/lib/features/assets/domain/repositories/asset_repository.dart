import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/home/domain/entities/material_price_entity.dart';
import 'package:egx/features/assets/domain/entities/asset_type.dart';

abstract class AssetRepository {
  /// Fetch candle data for any asset type
  Future<List<CandleEntity>> getAssetCandles({
    required String symbol,
    required AssetType assetType,
    required String interval,
    int limit = 100,
    String? tableName,
    DateTime? startTime,
  });

  /// Fetch 24hr ticker data (primarily for crypto)
  Future<Map<String, dynamic>> getAsset24hrTicker(String symbol);

  /// Fetch news for an asset
  Future<List<NewsEntity>> getAssetNews({
    required String stockId,
    int limit = 10,
    int offset = 0,
  });

  /// Fetch material prices (Gold/Silver)
  Future<MaterialPriceEntity> getMaterialPrice();
}
