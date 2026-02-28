import 'package:egx/features/auth/domain/repository/auth_repository.dart';

class GetPeerFcmTokenUseCase {
  final AuthRepository repository;

  GetPeerFcmTokenUseCase(this.repository);

  Future<String?> call(String userId) {
    return repository.getUserFcmToken(userId);
  }
}
