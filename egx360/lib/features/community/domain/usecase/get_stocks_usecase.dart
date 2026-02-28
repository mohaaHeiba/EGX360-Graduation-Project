import 'package:egx/features/community/domain/entity/stock_entity.dart';
import 'package:egx/features/community/domain/repositories/community_repository.dart';

class GetStocksUseCase {
  final CommunityRepository repository;
  GetStocksUseCase(this.repository);

  Future<List<StockEntity>> call() async {
    return await repository.getStocks();
  }
}
