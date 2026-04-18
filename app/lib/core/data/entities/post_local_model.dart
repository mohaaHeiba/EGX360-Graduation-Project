import 'package:egx/features/profile/domain/entity/post_entity.dart';

class PostLocalModel {
  final int id;
  final String userId;

  final String? content;
  final String? imageUrl;
  final DateTime createdAt;

  // Offline Data
  final String? userName;
  final String? userAvatar;

  final String? sentiment;
  final String? cashtags;

  // Stats
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;

  // 🔥 User Interactions (اللايك والحفظ)
  final bool isLiked;
  final bool isBookmarked;

  PostLocalModel({
    required this.id,
    required this.userId,
    this.content,
    this.imageUrl,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    required this.likesCount,
    required this.dislikesCount,
    required this.commentsCount,
    this.sentiment,
    this.cashtags,
    required this.isLiked,
    required this.isBookmarked,
  });

  factory PostLocalModel.fromEntity(PostEntity entity) {
    return PostLocalModel(
      id: entity.id,
      userId: entity.userId,
      content: entity.content,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      likesCount: entity.likesCount,
      dislikesCount: entity.dislikesCount,
      commentsCount: entity.commentsCount,
      sentiment: entity.sentiment,
      cashtags: entity.cashtags?.join(','),
      isLiked: entity.isLiked,
      isBookmarked: entity.isBookmarked,
    );
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      createdAt: createdAt,
      userName: userName,
      userAvatar: userAvatar,
      likesCount: likesCount,
      dislikesCount: dislikesCount,
      commentsCount: commentsCount,
      sentiment: sentiment,
      cashtags: cashtags?.split(','),
      isLiked: isLiked,
      isBookmarked: isBookmarked,
    );
  }

  factory PostLocalModel.fromJson(Map<String, dynamic> json) {
    return PostLocalModel(
      id: json['id'] as int,
      userId: json['userId'] as String,
      content: json['content'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      likesCount: json['likesCount'] as int,
      dislikesCount: json['dislikesCount'] as int,
      commentsCount: json['commentsCount'] as int,
      sentiment: json['sentiment'] as String?,
      cashtags: json['cashtags'] as String?,
      isLiked: json['isLiked'] as bool,
      isBookmarked: json['isBookmarked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
      'userAvatar': userAvatar,
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'commentsCount': commentsCount,
      'sentiment': sentiment,
      'cashtags': cashtags,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
    };
  }
}
