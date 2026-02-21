// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  bio: json['bio'] as String?,
  location: json['location'] as String?,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  gender: json['gender'] as String?,
  occupation: json['occupation'] as String?,
  company: json['company'] as String?,
  website: json['website'] as String?,
  isVerified: json['isVerified'] as bool?,
  isPremium: json['isPremium'] as bool?,
  joinedAt: json['joinedAt'] == null
      ? null
      : DateTime.parse(json['joinedAt'] as String),
  lastActiveAt: json['lastActiveAt'] == null
      ? null
      : DateTime.parse(json['lastActiveAt'] as String),
  preferences: json['preferences'] as Map<String, dynamic>?,
  interests: (json['interests'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  profileVisibility: json['profileVisibility'] as String?,
  notificationSettings: json['notificationSettings'] as String?,
  privacySettings: json['privacySettings'] as String?,
  socialLinks: json['socialLinks'] as String?,
  referralCode: json['referralCode'] as String?,
  points: (json['points'] as num?)?.toInt(),
  level: json['level'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'phoneNumber': instance.phoneNumber,
  'bio': instance.bio,
  'location': instance.location,
  'birthDate': instance.birthDate?.toIso8601String(),
  'gender': instance.gender,
  'occupation': instance.occupation,
  'company': instance.company,
  'website': instance.website,
  'isVerified': instance.isVerified,
  'isPremium': instance.isPremium,
  'joinedAt': instance.joinedAt?.toIso8601String(),
  'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
  'preferences': instance.preferences,
  'interests': instance.interests,
  'profileVisibility': instance.profileVisibility,
  'notificationSettings': instance.notificationSettings,
  'privacySettings': instance.privacySettings,
  'socialLinks': instance.socialLinks,
  'referralCode': instance.referralCode,
  'points': instance.points,
  'level': instance.level,
  'status': instance.status,
};
