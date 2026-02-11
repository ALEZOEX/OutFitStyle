import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? bio,
    @Default(0) int followers,
    @Default(0) int following,
    @Default(false) bool isPrivate,
    @Default(false) bool isVerified,
    @Default([]) List<String> interests,
    @Default([]) List<String> stylePreferences,
    @Default([]) List<String> bodyMeasurements,
    @Default([]) List<String> sizePreferences,
    @Default([]) List<String> colorPreferences,
    @Default([]) List<String> brandPreferences,
    @Default([]) List<String> occasionPreferences,
    @Default([]) List<String> weatherPreferences,
    @Default([]) List<String> seasonalPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;
}
