import 'package:egx/features/search/domain/entities/candle_entity.dart';
import 'package:egx/features/assets/data/repositories/crypto_repository.dart';

class GetCryptoCandlesUseCase {
  final CryptoRepository repository;

  GetCryptoCandlesUseCase(this.repository);

  Future<List<CandleEntity>> call({
    required String symbol,
    required String interval,
    int limit = 500,
  }) async {
    return await repository.fetchHistoricalData(
      symbol: symbol,
      interval: interval,
      limit: limit,
    );
  }
}
