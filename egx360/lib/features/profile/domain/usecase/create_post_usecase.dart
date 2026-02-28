import 'dart:io';
import 'package:egx/features/profile/domain/repositories/profile_repository.dart';

class CreatePostUseCase {
  final ProfileRepository repository;
  CreatePostUseCase(this.repository);

  Future<int> call({
    required String userId,
    String? content,
    File? imageFile,
    String? sentiment,
    List<String>? cashtags,
  }) async {
    return await repository.createPost(
      userId: userId,
      content: content,
      imageFile: imageFile,
      sentiment: sentiment,
      cashtags: cashtags,
    );
  }
}
