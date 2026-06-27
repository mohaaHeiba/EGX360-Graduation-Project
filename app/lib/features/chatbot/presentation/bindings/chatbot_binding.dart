import 'package:egx/core/services/cerebras_ai_service.dart';
import 'package:egx/features/chatbot/data/datasources/chatbot_remote_datasource.dart';
import 'package:egx/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:egx/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:egx/features/chatbot/domain/usecases/generate_chat_response_usecase.dart';
import 'package:egx/features/chatbot/domain/usecases/get_contextual_data_usecase.dart';
import 'package:egx/features/chatbot/domain/usecases/route_intent_usecase.dart';
import 'package:egx/features/chatbot/presentation/controllers/chatbot_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Dependencies from other features
import 'package:egx/features/simulation/domain/repositories/simulation_repository.dart';
import 'package:egx/features/home/domain/repositories/home_repository.dart';
import 'package:egx/features/search/domain/repositories/search_repository.dart';
import 'package:egx/features/community/domain/repositories/community_repository.dart';
import 'package:egx/features/assets/domain/repositories/asset_repository.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core Services & Data Sources
    if (!Get.isRegistered<http.Client>()) {
      Get.lazyPut(() => http.Client());
    }
    
    Get.lazyPut(() => CerebrasAiService(client: Get.find<http.Client>()));
    Get.lazyPut(() => ChatbotRemoteDataSource());

    // 2. Repository Implementation (Cross-Feature Injection)
    Get.lazyPut<ChatbotRepository>(
      () => ChatbotRepositoryImpl(
        remoteDataSource: Get.find<ChatbotRemoteDataSource>(),
        aiService: Get.find<CerebrasAiService>(),
        simulationRepository: Get.find<SimulationRepository>(),
        homeRepository: Get.find<HomeRepository>(),
        searchRepository: Get.find<SearchRepository>(),
        communityRepository: Get.find<CommunityRepository>(),
        assetRepository: Get.find<AssetRepository>(),
      ),
    );

    // 3. Use Cases
    Get.lazyPut(() => RouteIntentUseCase(Get.find<ChatbotRepository>()));
    Get.lazyPut(() => GetContextualDataUseCase(Get.find<ChatbotRepository>()));
    Get.lazyPut(() => GenerateChatResponseUseCase(Get.find<ChatbotRepository>()));

    // 4. Controller
    Get.lazyPut(
      () => ChatbotController(
        routeIntentUseCase: Get.find<RouteIntentUseCase>(),
        getContextualDataUseCase: Get.find<GetContextualDataUseCase>(),
        generateChatResponseUseCase: Get.find<GenerateChatResponseUseCase>(),
        repository: Get.find<ChatbotRepository>(),
      ),
    );
  }
}
