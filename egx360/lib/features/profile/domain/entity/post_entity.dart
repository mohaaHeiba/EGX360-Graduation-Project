class PostEntity {
  final int id;
  final String userId;
  final String? content;
  final String? imageUrl;

  final String? sentiment;
  final List<String>? cashtags;

  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  final int likesCount;
  final int dislikesCount;
  final int commentsCount;

  final bool isLiked;
  final bool isBookmarked;
  const PostEntity({
    required this.id,
    required this.userId,
    this.content,
    this.imageUrl,
    this.sentiment,
    this.cashtags,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  PostEntity copyWith({
    int? id,
    String? userId,
    String? content,
    String? imageUrl,
    String? sentiment,
    List<String>? cashtags,
    DateTime? createdAt,
    String? userName,
    String? userAvatar,
    int? likesCount,
    int? dislikesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      sentiment: sentiment ?? this.sentiment,
      cashtags: cashtags ?? this.cashtags,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  String get headline {
    if (content == null || content!.isEmpty) return "";
    if (content!.contains("---splite---")) {
      return content!.split("---splite---").first;
    }
    return "";
  }

  String get body {
    if (content == null || content!.isEmpty) return "";
    if (content!.contains("---splite---")) {
      return content!.split("---splite---").last;
    }
    return content!;
  }
}
