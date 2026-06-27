import 'package:egx/features/assets/data/repositories/us_stocks_repository.dart';

class GetUsStockQuoteUseCase {
  final UsStocksRepository repository;

  GetUsStockQuoteUseCase(this.repository);

  /// Fetch real-time quote from Finnhub.
  /// Returns map with: c (current), d (change), dp (change%),
  /// h (high), l (low), o (open), pc (prevClose), t (timestamp)
  Future<Map<String, dynamic>> call(String symbol) async {
    return await repository.fetchQuote(symbol);
  }
}
