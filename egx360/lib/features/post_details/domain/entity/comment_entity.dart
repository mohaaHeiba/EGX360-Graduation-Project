class CommentEntity {
  final int id;
  final int postId;
  final int? parentId;
  final String content;
  final DateTime createdAt;
  final String userId;
  final String? userName;
  final String? userAvatar;

  final int likesCount;
  final int dislikesCount;

  final int? userVoteType;

  final String? parentUserName;

  const CommentEntity({
    required this.id,
    required this.postId,
    this.parentId,
    required this.content,
    required this.createdAt,
    required this.userId,
    this.userName,
    this.userAvatar,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.userVoteType,
    this.parentUserName,
  });

  CommentEntity copyWith({
    int? id,
    int? postId,
    int? parentId,
    String? content,
    DateTime? createdAt,
    String? userId,
    String? userName,
    String? userAvatar,
    int? likesCount,
    int? dislikesCount,
    int? userVoteType,
    String? parentUserName,
    bool resetUserVoteType = false,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      userVoteType: resetUserVoteType
          ? null
          : (userVoteType ?? this.userVoteType),
      parentUserName: parentUserName ?? this.parentUserName,
    );
  }
}
