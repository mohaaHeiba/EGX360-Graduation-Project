import 'package:egx/features/auth/domain/entity/auth_entity.dart';

class AuthModel extends AuthEntity {
  final DateTime? lastActiveAtDate;
  final DateTime? createdAtDate;
  final DateTime? updatedAtDate;

  AuthModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    super.bio,
    this.lastActiveAtDate,
    this.createdAtDate,
    this.updatedAtDate,
    super.fcmToken,
  }) : super(
         lastActiveAt: lastActiveAtDate?.toIso8601String(),
         createdAt: createdAtDate?.toIso8601String(),
         updatedAt: updatedAtDate?.toIso8601String(),
       );

  factory AuthModel.fromMap(Map<String, dynamic> map) {
    return AuthModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      lastActiveAtDate: map['last_active_at'] == null
          ? null
          : DateTime.parse(map['last_active_at'] as String),
      createdAtDate: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
      updatedAtDate: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
      fcmToken: map['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'last_active_at': lastActiveAtDate?.toIso8601String(),
      'created_at': createdAtDate?.toIso8601String(),
      'updated_at': updatedAtDate?.toIso8601String(),
      'fcm_token': fcmToken,
    };
  }

  AuthModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    DateTime? lastActiveAtDate,
    DateTime? createdAtDate,
    DateTime? updatedAtDate,
    String? fcmToken,
  }) {
    return AuthModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      lastActiveAtDate: lastActiveAtDate ?? this.lastActiveAtDate,
      createdAtDate: createdAtDate ?? this.createdAtDate,
      updatedAtDate: updatedAtDate ?? this.updatedAtDate,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
