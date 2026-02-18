// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_achievement_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserAchievementStatus {

 int? get id;@JsonKey(name: 'user_id') int? get userId;@JsonKey(name: 'achievement_id') int? get achievementId; AchievementStatus? get status; int? get progress;@JsonKey(name: 'achieved_at') DateTime? get achievedAt;
/// Create a copy of UserAchievementStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserAchievementStatusCopyWith<UserAchievementStatus> get copyWith => _$UserAchievementStatusCopyWithImpl<UserAchievementStatus>(this as UserAchievementStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserAchievementStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.achievementId, achievementId) || other.achievementId == achievementId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,achievementId,status,progress,achievedAt);

@override
String toString() {
  return 'UserAchievementStatus(id: $id, userId: $userId, achievementId: $achievementId, status: $status, progress: $progress, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class $UserAchievementStatusCopyWith<$Res>  {
  factory $UserAchievementStatusCopyWith(UserAchievementStatus value, $Res Function(UserAchievementStatus) _then) = _$UserAchievementStatusCopyWithImpl;
@useResult
$Res call({
 int? id,@JsonKey(name: 'user_id') int? userId,@JsonKey(name: 'achievement_id') int? achievementId, AchievementStatus? status, int? progress,@JsonKey(name: 'achieved_at') DateTime? achievedAt
});




}
/// @nodoc
class _$UserAchievementStatusCopyWithImpl<$Res>
    implements $UserAchievementStatusCopyWith<$Res> {
  _$UserAchievementStatusCopyWithImpl(this._self, this._then);

  final UserAchievementStatus _self;
  final $Res Function(UserAchievementStatus) _then;

/// Create a copy of UserAchievementStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = freezed,Object? achievementId = freezed,Object? status = freezed,Object? progress = freezed,Object? achievedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,achievementId: freezed == achievementId ? _self.achievementId : achievementId // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AchievementStatus?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserAchievementStatus].
extension UserAchievementStatusPatterns on UserAchievementStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserAchievementStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserAchievementStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserAchievementStatus value)  $default,){
final _that = this;
switch (_that) {
case _UserAchievementStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserAchievementStatus value)?  $default,){
final _that = this;
switch (_that) {
case _UserAchievementStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'achievement_id')  int? achievementId,  AchievementStatus? status,  int? progress, @JsonKey(name: 'achieved_at')  DateTime? achievedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserAchievementStatus() when $default != null:
return $default(_that.id,_that.userId,_that.achievementId,_that.status,_that.progress,_that.achievedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'achievement_id')  int? achievementId,  AchievementStatus? status,  int? progress, @JsonKey(name: 'achieved_at')  DateTime? achievedAt)  $default,) {final _that = this;
switch (_that) {
case _UserAchievementStatus():
return $default(_that.id,_that.userId,_that.achievementId,_that.status,_that.progress,_that.achievedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'achievement_id')  int? achievementId,  AchievementStatus? status,  int? progress, @JsonKey(name: 'achieved_at')  DateTime? achievedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserAchievementStatus() when $default != null:
return $default(_that.id,_that.userId,_that.achievementId,_that.status,_that.progress,_that.achievedAt);case _:
  return null;

}
}

}

/// @nodoc


class _UserAchievementStatus implements UserAchievementStatus {
  const _UserAchievementStatus({this.id, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'achievement_id') this.achievementId, this.status, this.progress, @JsonKey(name: 'achieved_at') this.achievedAt});
  

@override final  int? id;
@override@JsonKey(name: 'user_id') final  int? userId;
@override@JsonKey(name: 'achievement_id') final  int? achievementId;
@override final  AchievementStatus? status;
@override final  int? progress;
@override@JsonKey(name: 'achieved_at') final  DateTime? achievedAt;

/// Create a copy of UserAchievementStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserAchievementStatusCopyWith<_UserAchievementStatus> get copyWith => __$UserAchievementStatusCopyWithImpl<_UserAchievementStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserAchievementStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.achievementId, achievementId) || other.achievementId == achievementId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,achievementId,status,progress,achievedAt);

@override
String toString() {
  return 'UserAchievementStatus(id: $id, userId: $userId, achievementId: $achievementId, status: $status, progress: $progress, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class _$UserAchievementStatusCopyWith<$Res> implements $UserAchievementStatusCopyWith<$Res> {
  factory _$UserAchievementStatusCopyWith(_UserAchievementStatus value, $Res Function(_UserAchievementStatus) _then) = __$UserAchievementStatusCopyWithImpl;
@override @useResult
$Res call({
 int? id,@JsonKey(name: 'user_id') int? userId,@JsonKey(name: 'achievement_id') int? achievementId, AchievementStatus? status, int? progress,@JsonKey(name: 'achieved_at') DateTime? achievedAt
});




}
/// @nodoc
class __$UserAchievementStatusCopyWithImpl<$Res>
    implements _$UserAchievementStatusCopyWith<$Res> {
  __$UserAchievementStatusCopyWithImpl(this._self, this._then);

  final _UserAchievementStatus _self;
  final $Res Function(_UserAchievementStatus) _then;

/// Create a copy of UserAchievementStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = freezed,Object? achievementId = freezed,Object? status = freezed,Object? progress = freezed,Object? achievedAt = freezed,}) {
  return _then(_UserAchievementStatus(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,achievementId: freezed == achievementId ? _self.achievementId : achievementId // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AchievementStatus?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
