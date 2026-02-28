import 'package:egx/features/currency/domain/repositories/currency_repository.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';

class GetCurrencyHistoryUseCase {
  final CurrencyRepository repository;

  GetCurrencyHistoryUseCase(this.repository);

  Future<List<CandleEntity>> call(String symbol, int days) async {
    return await repository.getHistory(symbol, days);
  }
}
