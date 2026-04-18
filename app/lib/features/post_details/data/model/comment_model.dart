import 'package:egx/features/post_details/domain/entity/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    super.parentId,
    required super.content,
    required super.createdAt,
    required super.userId,
    super.userName,
    super.userAvatar,
    required super.likesCount,
    required super.dislikesCount,
    super.userVoteType,
    super.parentUserName,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as int,
      postId: map['post_id'] as int,
      parentId: map['parent_id'] as int?,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at']),
      userId: map['user_id'] as String,
      userName: map['user_name'] as String?,
      userAvatar: map['user_avatar'] as String?,
      likesCount: map['likes_count'] ?? 0,
      dislikesCount: map['dislikes_count'] ?? 0,
      userVoteType: map['user_vote_type'] as int?,

      parentUserName: map['parent_username'] as String?,
    );
  }
}
