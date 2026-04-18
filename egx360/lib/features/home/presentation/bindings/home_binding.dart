import 'package:egx/features/home/data/datasources/home_remote_datasource.dart';
import 'package:egx/features/home/data/repositories/home_repository_impl.dart';
import 'package:egx/features/home/domain/usecases/get_trending_stocks.dart';
import 'package:egx/features/home/domain/usecases/get_market_overview.dart';
import 'package:egx/features/home/domain/usecases/get_watchlist.dart';
import 'package:egx/features/home/domain/usecases/get_material_price_usecase.dart';
import 'package:egx/features/home/domain/usecases/get_market_history.dart';
import 'package:egx/features/home/domain/usecases/remove_from_watchlist.dart';
import 'package:egx/features/home/domain/usecases/get_stock_details.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:egx/features/assets/data/datasources/crypto_remote_data_source.dart';
import 'package:egx/features/assets/data/repositories/crypto_repository.dart';
import 'package:egx/features/assets/data/repositories/crypto_repository_impl.dart';
import 'package:egx/features/assets/data/datasources/currency_remote_data_source.dart';
import 'package:egx/features/assets/data/datasources/stock_remote_data_source.dart';
import 'package:egx/features/assets/data/repositories/asset_repository_impl.dart';
import 'package:egx/features/assets/domain/usecases/get_currency_live_prices_usecase.dart';
import 'package:egx/features/notifications/data/datasource/notification_remote_datasource.dart';
import 'package:egx/features/notifications/data/repository/notification_repository_impl.dart';
import 'package:egx/features/notifications/domain/repository/notification_repository.dart';
import 'package:egx/features/notifications/domain/usecase/get_notifications_usecase.dart';
import 'package:egx/features/notifications/domain/usecase/mark_notification_as_read_usecase.dart';
import 'package:egx/features/notifications/presentation/controller/notification_controller.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Data source
    Get.lazyPut<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(Supabase.instance.client),
    );

    // Crypto Dependencies (needed for HomeRepository)
    Get.lazyPut<CryptoRemoteDataSource>(
      () => CryptoRemoteDataSourceImpl(client: http.Client()),
    );
    Get.lazyPut<CryptoRepository>(
      () => CryptoRepositoryImpl(
        remoteDataSource: Get.find<CryptoRemoteDataSource>(),
      ),
    );

    // Repository
    Get.lazyPut<HomeRepositoryImpl>(
      () => HomeRepositoryImpl(
        Get.find<HomeRemoteDataSource>(),
        cryptoRepository: Get.find<CryptoRepository>(),
      ),
    );

    // Use cases
    Get.lazyPut(() => GetTrendingStocks(Get.find<HomeRepositoryImpl>()));
    Get.lazyPut(() => GetMarketOverview(Get.find<HomeRepositoryImpl>()));
    Get.lazyPut(() => GetWatchlist(Get.find<HomeRepositoryImpl>()));
    Get.lazyPut(() => GetMaterialPriceUseCase(Get.find<HomeRepositoryImpl>()));
    Get.lazyPut(() => GetMarketHistory(Get.find<HomeRepositoryImpl>()));
    Get.lazyPut(
      () => RemoveFromWatchlistUseCase(Get.find<HomeRepositoryImpl>()),
    );
    Get.lazyPut(() => GetStockDetailsUseCase(Get.find<HomeRepositoryImpl>()));

    // Currency - uses assets-based datasource and repository
    Get.lazyPut<CurrencyRemoteDataSource>(
      () => CurrencyRemoteDataSourceImpl(client: http.Client()),
    );
    Get.lazyPut<AssetRepositoryImpl>(
      () => AssetRepositoryImpl(
        cryptoRemoteDataSource: Get.find<CryptoRemoteDataSource>(),
        stockRemoteDataSource: StockRemoteDataSourceImpl(
          Supabase.instance.client,
        ),
        currencyRemoteDataSource: Get.find<CurrencyRemoteDataSource>(),
      ),
    );
    Get.lazyPut(
      () => GetCurrencyLivePricesUseCase(Get.find<AssetRepositoryImpl>()),
    );

    // Controller
    Get.lazyPut<HomeController>(
      () => HomeController(
        getTrendingStocks: Get.find(),
        getMarketOverview: Get.find(),
        getWatchlist: Get.find(),
        getMaterialPrice: Get.find(),
        getMarketHistory: Get.find(),
        getLiveCurrencyPrices: Get.find(),
        removeFromWatchlistUseCase: Get.find(),
        getStockDetailsUseCase: Get.find(),
      ),
    );

    // Notification dependencies for badge display
    Get.lazyPut<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(Supabase.instance.client),
    );
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(Get.find()),
    );
    Get.lazyPut(() => GetNotificationsUseCase(Get.find()));
    Get.lazyPut(() => MarkNotificationAsReadUseCase(Get.find()));

    // Initialize NotificationController permanently for badge display in home
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(
        NotificationController(
          getNotificationsUseCase: Get.find(),
          markNotificationAsReadUseCase: Get.find(),
        ),
        permanent: true,
      );
    }
  }
}
