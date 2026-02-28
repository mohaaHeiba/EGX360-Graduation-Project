import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:egx/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';
import 'package:egx/features/profile/domain/usecase/get_user_profile_usecase.dart';
import 'package:egx/features/stock_chat/data/datasources/stock_chat_remote_datasource.dart';
import 'package:egx/features/stock_chat/data/repositories/stock_chat_repository_impl.dart';
import 'package:egx/features/stock_chat/domian/repositories/stock_chat_repository.dart';
import 'package:egx/features/stock_chat/domian/usecases/get_chat_stream_usecase.dart';
import 'package:egx/features/stock_chat/presentation/controllers/stock_chat_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockChatBinding extends Bindings {
  @override
  void dependencies() {
    final String stockId = Get.arguments['stock_id'].toString();

    // --- Profile Dependencies (for user info) ---
    if (!Get.isRegistered<ProfileRemoteDataSource>()) {
      Get.lazyPut<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(Supabase.instance.client),
      );
    }

    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut<ProfileRepository>(
        () => ProfileRepositoryImpl(
          remoteDataSource: Get.find<ProfileRemoteDataSource>(),
          localData: Get.find<InitLocalData>(),
        ),
      );
    }

    if (!Get.isRegistered<GetUserProfileUseCase>()) {
      Get.lazyPut(() => GetUserProfileUseCase(Get.find<ProfileRepository>()));
    }

    // 2. Data Source
    Get.lazyPut<StockChatRemoteDataSource>(
      () => StockChatRemoteDataSourceImpl(Supabase.instance.client),
    );

    // 3. Repository
    Get.lazyPut<StockChatRepository>(() => StockChatRepositoryImpl(Get.find()));

    // 4. UseCases
    Get.lazyPut(() => GetChatStreamUseCase(Get.find()));
    Get.lazyPut(() => SendMessageUseCase(Get.find()));

    // 5. Controller
    Get.put(
      StockChatController(
        getChatStreamUseCase: Get.find(),
        sendMessageUseCase: Get.find(),
        getUserProfileUseCase: Get.find(),
        stockId: stockId,
      ),
    );
  }
}
