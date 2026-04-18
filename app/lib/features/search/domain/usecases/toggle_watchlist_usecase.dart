import 'package:egx/features/search/domain/repositories/search_repository.dart';

class ToggleWatchlistUseCase {
  final SearchRepository repository;

  ToggleWatchlistUseCase(this.repository);

  Future<void> call(String userId, String symbol, bool isAdding) async {
    if (isAdding) {
      await repository.addToWatchlist(userId, symbol);
    } else {
      await repository.removeFromWatchlist(userId, symbol);
    }
  }
}
