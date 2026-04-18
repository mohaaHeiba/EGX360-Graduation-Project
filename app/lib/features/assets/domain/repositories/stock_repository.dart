import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';

import 'package:egx/features/home/domain/entities/material_price_entity.dart';

abstract class StockRepository {
  Future<List<CandleEntity>> getStockCandles({
    required String symbol,
    required String tableName,
    required String interval,
    int limit = 100,
    DateTime? startTime,
  });

  Future<List<NewsEntity>> getStockNews({
    required String stockId,
    int limit = 10,
    int offset = 0,
  });

  Future<MaterialPriceEntity> getMaterialPrice();
}
