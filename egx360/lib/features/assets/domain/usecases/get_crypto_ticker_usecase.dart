import 'package:egx/features/assets/data/repositories/crypto_repository.dart';

class GetCryptoTickerUseCase {
  final CryptoRepository repository;

  GetCryptoTickerUseCase(this.repository);

  Future<Map<String, dynamic>> call(String symbol) async {
    return await repository.fetch24hrTicker(symbol);
  }
}
