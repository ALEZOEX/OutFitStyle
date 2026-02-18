// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get id; String get name; String get email; String? get avatarUrl; String? get bio; DateTime? get birthDate; List<String>? get preferredCategories; List<String>? get preferredColors; List<String>? get preferredBrands; Map<String, dynamic>? get preferences; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&const DeepCollectionEquality().equals(other.preferredCategories, preferredCategories)&&const DeepCollectionEquality().equals(other.preferredColors, preferredColors)&&const DeepCollectionEquality().equals(other.preferredBrands, preferredBrands)&&const DeepCollectionEquality().equals(other.preferences, preferences)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,avatarUrl,bio,birthDate,const DeepCollectionEquality().hash(preferredCategories),const DeepCollectionEquality().hash(preferredColors),const DeepCollectionEquality().hash(preferredBrands),const DeepCollectionEquality().hash(preferences),createdAt,updatedAt);

@override
String toString() {
  return 'UserProfile(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, bio: $bio, birthDate: $birthDate, preferredCategories: $preferredCategories, preferredColors: $preferredColors, preferredBrands: $preferredBrands, preferences: $preferences, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String? avatarUrl, String? bio, DateTime? birthDate, List<String>? preferredCategories, List<String>? preferredColors, List<String>? preferredBrands, Map<String, dynamic>? preferences, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? avatarUrl = freezed,Object? bio = freezed,Object? birthDate = freezed,Object? preferredCategories = freezed,Object? preferredColors = freezed,Object? preferredBrands = freezed,Object? preferences = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,preferredCategories: freezed == preferredCategories ? _self.preferredCategories : preferredCategories // ignore: cast_nullable_to_non_nullable
as List<String>?,preferredColors: freezed == preferredColors ? _self.preferredColors : preferredColors // ignore: cast_nullable_to_non_nullable
as List<String>?,preferredBrands: freezed == preferredBrands ? _self.preferredBrands : preferredBrands // ignore: cast_nullable_to_non_nullable
as List<String>?,preferences: freezed == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? avatarUrl,  String? bio,  DateTime? birthDate,  List<String>? preferredCategories,  List<String>? preferredColors,  List<String>? preferredBrands,  Map<String, dynamic>? preferences,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.avatarUrl,_that.bio,_that.birthDate,_that.preferredCategories,_that.preferredColors,_that.preferredBrands,_that.preferences,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? avatarUrl,  String? bio,  DateTime? birthDate,  List<String>? preferredCategories,  List<String>? preferredColors,  List<String>? preferredBrands,  Map<String, dynamic>? preferences,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.name,_that.email,_that.avatarUrl,_that.bio,_that.birthDate,_that.preferredCategories,_that.preferredColors,_that.preferredBrands,_that.preferences,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String? avatarUrl,  String? bio,  DateTime? birthDate,  List<String>? preferredCategories,  List<String>? preferredColors,  List<String>? preferredBrands,  Map<String, dynamic>? preferences,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.avatarUrl,_that.bio,_that.birthDate,_that.preferredCategories,_that.preferredColors,_that.preferredBrands,_that.preferences,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, required this.name, required this.email, this.avatarUrl, this.bio, this.birthDate, final  List<String>? preferredCategories, final  List<String>? preferredColors, final  List<String>? preferredBrands, final  Map<String, dynamic>? preferences, this.createdAt, this.updatedAt}): _preferredCategories = preferredCategories,_preferredColors = preferredColors,_preferredBrands = preferredBrands,_preferences = preferences;
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String? avatarUrl;
@override final  String? bio;
@override final  DateTime? birthDate;
 final  List<String>? _preferredCategories;
@override List<String>? get preferredCategories {
  final value = _preferredCategories;
  if (value == null) return null;
  if (_preferredCategories is EqualUnmodifiableListView) return _preferredCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _preferredColors;
@override List<String>? get preferredColors {
  final value = _preferredColors;
  if (value == null) return null;
  if (_preferredColors is EqualUnmodifiableListView) return _preferredColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _preferredBrands;
@override List<String>? get preferredBrands {
  final value = _preferredBrands;
  if (value == null) return null;
  if (_preferredBrands is EqualUnmodifiableListView) return _preferredBrands;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _preferences;
@override Map<String, dynamic>? get preferences {
  final value = _preferences;
  if (value == null) return null;
  if (_preferences is EqualUnmodifiableMapView) return _preferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&const DeepCollectionEquality().equals(other._preferredCategories, _preferredCategories)&&const DeepCollectionEquality().equals(other._preferredColors, _preferredColors)&&const DeepCollectionEquality().equals(other._preferredBrands, _preferredBrands)&&const DeepCollectionEquality().equals(other._preferences, _preferences)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,avatarUrl,bio,birthDate,const DeepCollectionEquality().hash(_preferredCategories),const DeepCollectionEquality().hash(_preferredColors),const DeepCollectionEquality().hash(_preferredBrands),const DeepCollectionEquality().hash(_preferences),createdAt,updatedAt);

@override
String toString() {
  return 'UserProfile(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, bio: $bio, birthDate: $birthDate, preferredCategories: $preferredCategories, preferredColors: $preferredColors, preferredBrands: $preferredBrands, preferences: $preferences, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String? avatarUrl, String? bio, DateTime? birthDate, List<String>? preferredCategories, List<String>? preferredColors, List<String>? preferredBrands, Map<String, dynamic>? preferences, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? avatarUrl = freezed,Object? bio = freezed,Object? birthDate = freezed,Object? preferredCategories = freezed,Object? preferredColors = freezed,Object? preferredBrands = freezed,Object? preferences = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,preferredCategories: freezed == preferredCategories ? _self._preferredCategories : preferredCategories // ignore: cast_nullable_to_non_nullable
as List<String>?,preferredColors: freezed == preferredColors ? _self._preferredColors : preferredColors // ignore: cast_nullable_to_non_nullable
as List<String>?,preferredBrands: freezed == preferredBrands ? _self._preferredBrands : preferredBrands // ignore: cast_nullable_to_non_nullable
as List<String>?,preferences: freezed == preferences ? _self._preferences : preferences // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
