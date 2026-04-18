import 'package:egx/features/search/domain/entities/candle_entity.dart';

abstract class CurrencyRepository {
  Future<Map<String, double>> getLivePrices();
  Future<List<CandleEntity>> getHistory(String symbol, int days);
}
