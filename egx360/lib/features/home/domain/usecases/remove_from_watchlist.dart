import 'package:egx/features/home/domain/repositories/home_repository.dart';

class RemoveFromWatchlistUseCase {
  final HomeRepository repository;

  RemoveFromWatchlistUseCase(this.repository);

  Future<void> call(String userId, String symbol) {
    return repository.removeFromWatchlist(userId, symbol);
  }
}
