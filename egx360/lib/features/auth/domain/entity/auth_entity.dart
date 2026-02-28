class AuthEntity {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? lastActiveAt;
  final String? createdAt;
  final String? updatedAt;
  final String? fcmToken;

  const AuthEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.lastActiveAt,
    this.createdAt,
    this.updatedAt,
    this.fcmToken,
  });

  factory AuthEntity.fromJson(Map<String, dynamic> json) {
    return AuthEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      lastActiveAt: json['lastActiveAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      fcmToken: json['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'lastActiveAt': lastActiveAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'fcmToken': fcmToken,
    };
  }
}
