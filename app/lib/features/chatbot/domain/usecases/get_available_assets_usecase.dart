import 'package:egx/features/chatbot/domain/repositories/chatbot_repository.dart';

class GetAvailableAssetsUseCase {
  final ChatbotRepository repository;

  GetAvailableAssetsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.fetchSupportedAssets();
  }
}
