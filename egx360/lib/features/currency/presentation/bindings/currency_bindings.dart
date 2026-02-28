import 'package:egx/features/currency/data/datasources/currency_remote_datasource.dart';
import 'package:egx/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:egx/features/currency/domain/usecases/get_currency_history_usecase.dart';
import 'package:egx/features/currency/presentation/controllers/currency_details_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CurrencyBindings extends Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String symbol = args['symbol'] ?? 'USDEGP';

    // Data Sources
    final remoteDataSource = CurrencyRemoteDataSourceImpl(
      client: http.Client(),
    );

    // Repositories
    final repository = CurrencyRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    // Use Cases
    final getCurrencyHistoryUseCase = GetCurrencyHistoryUseCase(repository);

    // Controller
    Get.put(
      CurrencyDetailsController(
        initialSymbol: symbol,
        getCurrencyHistoryUseCase: getCurrencyHistoryUseCase,
      ),
    );
  }
}
