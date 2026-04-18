import 'package:egx/features/assets/domain/repositories/asset_repository.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';

class GetCurrencyHistoryUseCase {
  final AssetRepository repository;

  GetCurrencyHistoryUseCase(this.repository);

  Future<List<CandleEntity>> call(String symbol, int days) async {
    return await repository.getCurrencyHistory(symbol, days);
  }
}
