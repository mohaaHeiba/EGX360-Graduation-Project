import 'package:egx/features/profile/domain/entity/profile_stats.dart';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';

class GetProfileStatsUseCase {
  final ProfileRepository repository;
  GetProfileStatsUseCase(this.repository);

  Future<ProfileStats> call(String userId) async {
    return await repository.getProfileStats(userId);
  }
}
