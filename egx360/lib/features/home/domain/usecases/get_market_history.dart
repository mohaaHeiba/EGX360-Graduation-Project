import 'package:egx/features/home/domain/entities/market_history_entity.dart';
import 'package:egx/features/home/domain/repositories/home_repository.dart';

class GetMarketHistory {
  final HomeRepository repository;

  GetMarketHistory(this.repository);

  Future<MarketHistoryEntity?> call() async {
    return await repository.getMarketHistory();
  }
}
