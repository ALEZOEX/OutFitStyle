import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    String? phoneNumber,
    String? bio,
    String? location,
    DateTime? birthDate,
    String? gender,
    String? occupation,
    String? company,
    String? website,
    bool? isVerified,
    bool? isPremium,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
    List<String>? interests,
    String? profileVisibility,
    String? notificationSettings,
    String? privacySettings,
    String? socialLinks,
    String? referralCode,
    int? points,
    String? level,
    String? status,
    @JsonKey(name: 'password_hash') String? passwordHash,
    @JsonKey(name: 'oauth_provider') String? oauthProvider,
    @JsonKey(name: 'oauth_id') String? oauthId,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}