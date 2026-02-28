import 'package:egx/features/search/domain/repositories/search_repository.dart';

class GetWatchlistStatusUseCase {
  final SearchRepository repository;

  GetWatchlistStatusUseCase(this.repository);

  Future<bool> call(String userId, String symbol) async {
    return await repository.isStockInWatchlist(userId, symbol);
  }
}
