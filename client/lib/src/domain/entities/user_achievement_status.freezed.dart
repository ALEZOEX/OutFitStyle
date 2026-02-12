// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_achievement_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserAchievementStatus {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'achievement_id')
  int? get achievementId => throw _privateConstructorUsedError;
  AchievementStatus? get status => throw _privateConstructorUsedError;
  int? get progress => throw _privateConstructorUsedError;
  @JsonKey(name: 'achieved_at')
  DateTime? get achievedAt => throw _privateConstructorUsedError;

  /// Create a copy of UserAchievementStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserAchievementStatusCopyWith<UserAchievementStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserAchievementStatusCopyWith<$Res> {
  factory $UserAchievementStatusCopyWith(UserAchievementStatus value,
          $Res Function(UserAchievementStatus) then) =
      _$UserAchievementStatusCopyWithImpl<$Res, UserAchievementStatus>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'achievement_id') int? achievementId,
      AchievementStatus? status,
      int? progress,
      @JsonKey(name: 'achieved_at') DateTime? achievedAt});
}

/// @nodoc
class _$UserAchievementStatusCopyWithImpl<$Res,
        $Val extends UserAchievementStatus>
    implements $UserAchievementStatusCopyWith<$Res> {
  _$UserAchievementStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserAchievementStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? achievementId = freezed,
    Object? status = freezed,
    Object? progress = freezed,
    Object? achievedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      achievementId: freezed == achievementId
          ? _value.achievementId
          : achievementId // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AchievementStatus?,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int?,
      achievedAt: freezed == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserAchievementStatusImplCopyWith<$Res>
    implements $UserAchievementStatusCopyWith<$Res> {
  factory _$$UserAchievementStatusImplCopyWith(
          _$UserAchievementStatusImpl value,
          $Res Function(_$UserAchievementStatusImpl) then) =
      __$$UserAchievementStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'achievement_id') int? achievementId,
      AchievementStatus? status,
      int? progress,
      @JsonKey(name: 'achieved_at') DateTime? achievedAt});
}

/// @nodoc
class __$$UserAchievementStatusImplCopyWithImpl<$Res>
    extends _$UserAchievementStatusCopyWithImpl<$Res,
        _$UserAchievementStatusImpl>
    implements _$$UserAchievementStatusImplCopyWith<$Res> {
  __$$UserAchievementStatusImplCopyWithImpl(_$UserAchievementStatusImpl _value,
      $Res Function(_$UserAchievementStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserAchievementStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? achievementId = freezed,
    Object? status = freezed,
    Object? progress = freezed,
    Object? achievedAt = freezed,
  }) {
    return _then(_$UserAchievementStatusImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      achievementId: freezed == achievementId
          ? _value.achievementId
          : achievementId // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AchievementStatus?,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int?,
      achievedAt: freezed == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$UserAchievementStatusImpl implements _UserAchievementStatus {
  const _$UserAchievementStatusImpl(
      {this.id,
      @JsonKey(name: 'user_id') this.userId,
      @JsonKey(name: 'achievement_id') this.achievementId,
      this.status,
      this.progress,
      @JsonKey(name: 'achieved_at') this.achievedAt});

  @override
  final int? id;
  @override
  @JsonKey(name: 'user_id')
  final int? userId;
  @override
  @JsonKey(name: 'achievement_id')
  final int? achievementId;
  @override
  final AchievementStatus? status;
  @override
  final int? progress;
  @override
  @JsonKey(name: 'achieved_at')
  final DateTime? achievedAt;

  @override
  String toString() {
    return 'UserAchievementStatus(id: $id, userId: $userId, achievementId: $achievementId, status: $status, progress: $progress, achievedAt: $achievedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserAchievementStatusImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.achievementId, achievementId) ||
                other.achievementId == achievementId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.achievedAt, achievedAt) ||
                other.achievedAt == achievedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, achievementId, status, progress, achievedAt);

  /// Create a copy of UserAchievementStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserAchievementStatusImplCopyWith<_$UserAchievementStatusImpl>
      get copyWith => __$$UserAchievementStatusImplCopyWithImpl<
          _$UserAchievementStatusImpl>(this, _$identity);
}

abstract class _UserAchievementStatus implements UserAchievementStatus {
  const factory _UserAchievementStatus(
          {final int? id,
          @JsonKey(name: 'user_id') final int? userId,
          @JsonKey(name: 'achievement_id') final int? achievementId,
          final AchievementStatus? status,
          final int? progress,
          @JsonKey(name: 'achieved_at') final DateTime? achievedAt}) =
      _$UserAchievementStatusImpl;

  @override
  int? get id;
  @override
  @JsonKey(name: 'user_id')
  int? get userId;
  @override
  @JsonKey(name: 'achievement_id')
  int? get achievementId;
  @override
  AchievementStatus? get status;
  @override
  int? get progress;
  @override
  @JsonKey(name: 'achieved_at')
  DateTime? get achievedAt;

  /// Create a copy of UserAchievementStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserAchievementStatusImplCopyWith<_$UserAchievementStatusImpl>
      get copyWith => throw _privateConstructorUsedError;
}
