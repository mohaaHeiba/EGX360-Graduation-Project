import 'package:egx/features/simulation/data/datasources/simulation_remote_datasource.dart';
import 'package:egx/features/simulation/data/repositories/simulation_repository_impl.dart';
import 'package:egx/features/simulation/domain/repositories/simulation_repository.dart';
import 'package:egx/features/simulation/domain/usecases/execute_trade_usecase.dart';
import 'package:egx/features/simulation/domain/usecases/get_holdings_usecase.dart';
import 'package:egx/features/simulation/domain/usecases/get_transactions_usecase.dart';
import 'package:egx/features/simulation/domain/usecases/get_wallet_usecase.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:get/get.dart';
import 'package:egx/features/search/data/datasources/search_remote_datasource.dart';
import 'package:egx/features/search/data/repositories/search_repository_impl.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SimulationBindings extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<SimulationRemoteDataSource>(
      () => SimulationRemoteDataSourceImpl(Supabase.instance.client),
    );

    // Repository
    Get.lazyPut<SimulationRepository>(
      () => SimulationRepositoryImpl(
        remoteDataSource: Get.find<SimulationRemoteDataSource>(),
      ),
    );

    // Use Cases
    Get.lazyPut(() => GetWalletUseCase(Get.find()));
    Get.lazyPut(() => GetHoldingsUseCase(Get.find()));
    Get.lazyPut(() => GetTransactionsUseCase(Get.find()));
    Get.lazyPut(() => ExecuteTradeUseCase(Get.find()));

    // Search Repository (for price updates)
    Get.lazyPut<SearchRepository>(
      () => SearchRepositoryImpl(
        SearchRemoteDataSourceImpl(Supabase.instance.client),
      ),
    );

    // Controller
    Get.lazyPut(
      () => SimulationController(
        getWalletUseCase: Get.find(),
        getHoldingsUseCase: Get.find(),
        getTransactionsUseCase: Get.find(),
        executeTradeUseCase: Get.find(),
        repository: Get.find(),
        searchRepository: Get.find(),
      ),
    );
  }
}
