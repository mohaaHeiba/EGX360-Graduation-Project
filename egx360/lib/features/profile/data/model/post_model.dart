import 'package:egx/features/profile/domain/entity/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    super.content,
    super.imageUrl,

    super.sentiment,
    super.cashtags,

    required super.createdAt,
    super.userName,
    super.userAvatar,
    required super.likesCount,
    required super.dislikesCount,
    required super.commentsCount,

    super.isLiked = false,
    super.isBookmarked = false,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      content: map['content'] as String?,
      imageUrl: map['image_url'] as String?,

      sentiment: map['sentiment'] as String?,
      cashtags: map['cashtags'] != null
          ? List<String>.from(map['cashtags'])
          : null,

      createdAt: DateTime.parse(map['created_at']),
      userName: map['user_name'] as String?,
      userAvatar: map['user_avatar'] as String?,
      likesCount: map['likes_count'] ?? 0,
      dislikesCount: map['dislikes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,

      isLiked: map['is_liked'] ?? false,
      isBookmarked: map['is_bookmarked'] ?? false,
    );
  }
}
