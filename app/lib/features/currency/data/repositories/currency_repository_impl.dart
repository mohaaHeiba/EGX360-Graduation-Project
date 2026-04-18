import 'package:egx/features/currency/data/datasources/currency_remote_datasource.dart';
import 'package:egx/features/currency/domain/repositories/currency_repository.dart';
import 'package:egx/features/search/domain/entities/candle_entity.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource remoteDataSource;

  CurrencyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, double>> getLivePrices() async {
    return await remoteDataSource.getLivePrices();
  }

  @override
  Future<List<CandleEntity>> getHistory(String symbol, int days) async {
    return await remoteDataSource.getHistory(symbol, days);
  }
}
