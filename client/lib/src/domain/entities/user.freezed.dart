// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get email; String get name; String? get avatarUrl; String? get phoneNumber; String? get bio; String? get location; DateTime? get birthDate; String? get gender; String? get occupation; String? get company; String? get website; bool? get isVerified; bool? get isPremium; String? get subscriptionStatus; DateTime? get joinedAt; DateTime? get lastActiveAt; Map<String, dynamic>? get preferences; List<String>? get interests; String? get profileVisibility; String? get notificationSettings; String? get privacySettings; String? get socialLinks; String? get referralCode; int? get points; String? get level; String? get status;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.location, location) || other.location == location)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.company, company) || other.company == company)&&(identical(other.website, website) || other.website == website)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&const DeepCollectionEquality().equals(other.preferences, preferences)&&const DeepCollectionEquality().equals(other.interests, interests)&&(identical(other.profileVisibility, profileVisibility) || other.profileVisibility == profileVisibility)&&(identical(other.notificationSettings, notificationSettings) || other.notificationSettings == notificationSettings)&&(identical(other.privacySettings, privacySettings) || other.privacySettings == privacySettings)&&(identical(other.socialLinks, socialLinks) || other.socialLinks == socialLinks)&&(identical(other.referralCode, referralCode) || other.referralCode == referralCode)&&(identical(other.points, points) || other.points == points)&&(identical(other.level, level) || other.level == level)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,email,name,avatarUrl,phoneNumber,bio,location,birthDate,gender,occupation,company,website,isVerified,isPremium,subscriptionStatus,joinedAt,lastActiveAt,const DeepCollectionEquality().hash(preferences),const DeepCollectionEquality().hash(interests),profileVisibility,notificationSettings,privacySettings,socialLinks,referralCode,points,level,status]);

@override
String toString() {
  return 'User(id: $id, email: $email, name: $name, avatarUrl: $avatarUrl, phoneNumber: $phoneNumber, bio: $bio, location: $location, birthDate: $birthDate, gender: $gender, occupation: $occupation, company: $company, website: $website, isVerified: $isVerified, isPremium: $isPremium, subscriptionStatus: $subscriptionStatus, joinedAt: $joinedAt, lastActiveAt: $lastActiveAt, preferences: $preferences, interests: $interests, profileVisibility: $profileVisibility, notificationSettings: $notificationSettings, privacySettings: $privacySettings, socialLinks: $socialLinks, referralCode: $referralCode, points: $points, level: $level, status: $status)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String name, String? avatarUrl, String? phoneNumber, String? bio, String? location, DateTime? birthDate, String? gender, String? occupation, String? company, String? website, bool? isVerified, bool? isPremium, String? subscriptionStatus, DateTime? joinedAt, DateTime? lastActiveAt, Map<String, dynamic>? preferences, List<String>? interests, String? profileVisibility, String? notificationSettings, String? privacySettings, String? socialLinks, String? referralCode, int? points, String? level, String? status
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? name = null,Object? avatarUrl = freezed,Object? phoneNumber = freezed,Object? bio = freezed,Object? location = freezed,Object? birthDate = freezed,Object? gender = freezed,Object? occupation = freezed,Object? company = freezed,Object? website = freezed,Object? isVerified = freezed,Object? isPremium = freezed,Object? subscriptionStatus = freezed,Object? joinedAt = freezed,Object? lastActiveAt = freezed,Object? preferences = freezed,Object? interests = freezed,Object? profileVisibility = freezed,Object? notificationSettings = freezed,Object? privacySettings = freezed,Object? socialLinks = freezed,Object? referralCode = freezed,Object? points = freezed,Object? level = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,isPremium: freezed == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool?,subscriptionStatus: freezed == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,preferences: freezed == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,interests: freezed == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>?,profileVisibility: freezed == profileVisibility ? _self.profileVisibility : profileVisibility // ignore: cast_nullable_to_non_nullable
as String?,notificationSettings: freezed == notificationSettings ? _self.notificationSettings : notificationSettings // ignore: cast_nullable_to_non_nullable
as String?,privacySettings: freezed == privacySettings ? _self.privacySettings : privacySettings // ignore: cast_nullable_to_non_nullable
as String?,socialLinks: freezed == socialLinks ? _self.socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as String?,referralCode: freezed == referralCode ? _self.referralCode : referralCode // ignore: cast_nullable_to_non_nullable
as String?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String name,  String? avatarUrl,  String? phoneNumber,  String? bio,  String? location,  DateTime? birthDate,  String? gender,  String? occupation,  String? company,  String? website,  bool? isVerified,  bool? isPremium,  String? subscriptionStatus,  DateTime? joinedAt,  DateTime? lastActiveAt,  Map<String, dynamic>? preferences,  List<String>? interests,  String? profileVisibility,  String? notificationSettings,  String? privacySettings,  String? socialLinks,  String? referralCode,  int? points,  String? level,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.avatarUrl,_that.phoneNumber,_that.bio,_that.location,_that.birthDate,_that.gender,_that.occupation,_that.company,_that.website,_that.isVerified,_that.isPremium,_that.subscriptionStatus,_that.joinedAt,_that.lastActiveAt,_that.preferences,_that.interests,_that.profileVisibility,_that.notificationSettings,_that.privacySettings,_that.socialLinks,_that.referralCode,_that.points,_that.level,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String name,  String? avatarUrl,  String? phoneNumber,  String? bio,  String? location,  DateTime? birthDate,  String? gender,  String? occupation,  String? company,  String? website,  bool? isVerified,  bool? isPremium,  String? subscriptionStatus,  DateTime? joinedAt,  DateTime? lastActiveAt,  Map<String, dynamic>? preferences,  List<String>? interests,  String? profileVisibility,  String? notificationSettings,  String? privacySettings,  String? socialLinks,  String? referralCode,  int? points,  String? level,  String? status)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.email,_that.name,_that.avatarUrl,_that.phoneNumber,_that.bio,_that.location,_that.birthDate,_that.gender,_that.occupation,_that.company,_that.website,_that.isVerified,_that.isPremium,_that.subscriptionStatus,_that.joinedAt,_that.lastActiveAt,_that.preferences,_that.interests,_that.profileVisibility,_that.notificationSettings,_that.privacySettings,_that.socialLinks,_that.referralCode,_that.points,_that.level,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String name,  String? avatarUrl,  String? phoneNumber,  String? bio,  String? location,  DateTime? birthDate,  String? gender,  String? occupation,  String? company,  String? website,  bool? isVerified,  bool? isPremium,  String? subscriptionStatus,  DateTime? joinedAt,  DateTime? lastActiveAt,  Map<String, dynamic>? preferences,  List<String>? interests,  String? profileVisibility,  String? notificationSettings,  String? privacySettings,  String? socialLinks,  String? referralCode,  int? points,  String? level,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.avatarUrl,_that.phoneNumber,_that.bio,_that.location,_that.birthDate,_that.gender,_that.occupation,_that.company,_that.website,_that.isVerified,_that.isPremium,_that.subscriptionStatus,_that.joinedAt,_that.lastActiveAt,_that.preferences,_that.interests,_that.profileVisibility,_that.notificationSettings,_that.privacySettings,_that.socialLinks,_that.referralCode,_that.points,_that.level,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.email, required this.name, this.avatarUrl, this.phoneNumber, this.bio, this.location, this.birthDate, this.gender, this.occupation, this.company, this.website, this.isVerified, this.isPremium, this.subscriptionStatus, this.joinedAt, this.lastActiveAt, final  Map<String, dynamic>? preferences, final  List<String>? interests, this.profileVisibility, this.notificationSettings, this.privacySettings, this.socialLinks, this.referralCode, this.points, this.level, this.status}): _preferences = preferences,_interests = interests;
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String email;
@override final  String name;
@override final  String? avatarUrl;
@override final  String? phoneNumber;
@override final  String? bio;
@override final  String? location;
@override final  DateTime? birthDate;
@override final  String? gender;
@override final  String? occupation;
@override final  String? company;
@override final  String? website;
@override final  bool? isVerified;
@override final  bool? isPremium;
@override final  String? subscriptionStatus;
@override final  DateTime? joinedAt;
@override final  DateTime? lastActiveAt;
 final  Map<String, dynamic>? _preferences;
@override Map<String, dynamic>? get preferences {
  final value = _preferences;
  if (value == null) return null;
  if (_preferences is EqualUnmodifiableMapView) return _preferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _interests;
@override List<String>? get interests {
  final value = _interests;
  if (value == null) return null;
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? profileVisibility;
@override final  String? notificationSettings;
@override final  String? privacySettings;
@override final  String? socialLinks;
@override final  String? referralCode;
@override final  int? points;
@override final  String? level;
@override final  String? status;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.location, location) || other.location == location)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.company, company) || other.company == company)&&(identical(other.website, website) || other.website == website)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&const DeepCollectionEquality().equals(other._preferences, _preferences)&&const DeepCollectionEquality().equals(other._interests, _interests)&&(identical(other.profileVisibility, profileVisibility) || other.profileVisibility == profileVisibility)&&(identical(other.notificationSettings, notificationSettings) || other.notificationSettings == notificationSettings)&&(identical(other.privacySettings, privacySettings) || other.privacySettings == privacySettings)&&(identical(other.socialLinks, socialLinks) || other.socialLinks == socialLinks)&&(identical(other.referralCode, referralCode) || other.referralCode == referralCode)&&(identical(other.points, points) || other.points == points)&&(identical(other.level, level) || other.level == level)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,email,name,avatarUrl,phoneNumber,bio,location,birthDate,gender,occupation,company,website,isVerified,isPremium,subscriptionStatus,joinedAt,lastActiveAt,const DeepCollectionEquality().hash(_preferences),const DeepCollectionEquality().hash(_interests),profileVisibility,notificationSettings,privacySettings,socialLinks,referralCode,points,level,status]);

@override
String toString() {
  return 'User(id: $id, email: $email, name: $name, avatarUrl: $avatarUrl, phoneNumber: $phoneNumber, bio: $bio, location: $location, birthDate: $birthDate, gender: $gender, occupation: $occupation, company: $company, website: $website, isVerified: $isVerified, isPremium: $isPremium, subscriptionStatus: $subscriptionStatus, joinedAt: $joinedAt, lastActiveAt: $lastActiveAt, preferences: $preferences, interests: $interests, profileVisibility: $profileVisibility, notificationSettings: $notificationSettings, privacySettings: $privacySettings, socialLinks: $socialLinks, referralCode: $referralCode, points: $points, level: $level, status: $status)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String name, String? avatarUrl, String? phoneNumber, String? bio, String? location, DateTime? birthDate, String? gender, String? occupation, String? company, String? website, bool? isVerified, bool? isPremium, String? subscriptionStatus, DateTime? joinedAt, DateTime? lastActiveAt, Map<String, dynamic>? preferences, List<String>? interests, String? profileVisibility, String? notificationSettings, String? privacySettings, String? socialLinks, String? referralCode, int? points, String? level, String? status
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? name = null,Object? avatarUrl = freezed,Object? phoneNumber = freezed,Object? bio = freezed,Object? location = freezed,Object? birthDate = freezed,Object? gender = freezed,Object? occupation = freezed,Object? company = freezed,Object? website = freezed,Object? isVerified = freezed,Object? isPremium = freezed,Object? subscriptionStatus = freezed,Object? joinedAt = freezed,Object? lastActiveAt = freezed,Object? preferences = freezed,Object? interests = freezed,Object? profileVisibility = freezed,Object? notificationSettings = freezed,Object? privacySettings = freezed,Object? socialLinks = freezed,Object? referralCode = freezed,Object? points = freezed,Object? level = freezed,Object? status = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,isPremium: freezed == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool?,subscriptionStatus: freezed == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,preferences: freezed == preferences ? _self._preferences : preferences // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,interests: freezed == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>?,profileVisibility: freezed == profileVisibility ? _self.profileVisibility : profileVisibility // ignore: cast_nullable_to_non_nullable
as String?,notificationSettings: freezed == notificationSettings ? _self.notificationSettings : notificationSettings // ignore: cast_nullable_to_non_nullable
as String?,privacySettings: freezed == privacySettings ? _self.privacySettings : privacySettings // ignore: cast_nullable_to_non_nullable
as String?,socialLinks: freezed == socialLinks ? _self.socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as String?,referralCode: freezed == referralCode ? _self.referralCode : referralCode // ignore: cast_nullable_to_non_nullable
as String?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
