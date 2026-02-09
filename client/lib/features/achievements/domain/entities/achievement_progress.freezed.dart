// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AchievementProgress _$AchievementProgressFromJson(Map<String, dynamic> json) {
  return _AchievementProgress.fromJson(json);
}

/// @nodoc
mixin _$AchievementProgress {
  String get achievementId => throw _privateConstructorUsedError;
  int get currentProgress => throw _privateConstructorUsedError;
  int get maxProgress => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this AchievementProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AchievementProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementProgressCopyWith<AchievementProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementProgressCopyWith<$Res> {
  factory $AchievementProgressCopyWith(
          AchievementProgress value, $Res Function(AchievementProgress) then) =
      _$AchievementProgressCopyWithImpl<$Res, AchievementProgress>;
  @useResult
  $Res call(
      {String achievementId,
      int currentProgress,
      int maxProgress,
      bool isCompleted,
      DateTime? completedAt});
}

/// @nodoc
class _$AchievementProgressCopyWithImpl<$Res, $Val extends AchievementProgress>
    implements $AchievementProgressCopyWith<$Res> {
  _$AchievementProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AchievementProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? achievementId = null,
    Object? currentProgress = null,
    Object? maxProgress = null,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      achievementId: null == achievementId
          ? _value.achievementId
          : achievementId // ignore: cast_nullable_to_non_nullable
              as String,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      maxProgress: null == maxProgress
          ? _value.maxProgress
          : maxProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementProgressImplCopyWith<$Res>
    implements $AchievementProgressCopyWith<$Res> {
  factory _$$AchievementProgressImplCopyWith(_$AchievementProgressImpl value,
          $Res Function(_$AchievementProgressImpl) then) =
      __$$AchievementProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String achievementId,
      int currentProgress,
      int maxProgress,
      bool isCompleted,
      DateTime? completedAt});
}

/// @nodoc
class __$$AchievementProgressImplCopyWithImpl<$Res>
    extends _$AchievementProgressCopyWithImpl<$Res, _$AchievementProgressImpl>
    implements _$$AchievementProgressImplCopyWith<$Res> {
  __$$AchievementProgressImplCopyWithImpl(_$AchievementProgressImpl _value,
      $Res Function(_$AchievementProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of AchievementProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? achievementId = null,
    Object? currentProgress = null,
    Object? maxProgress = null,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$AchievementProgressImpl(
      achievementId: null == achievementId
          ? _value.achievementId
          : achievementId // ignore: cast_nullable_to_non_nullable
              as String,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      maxProgress: null == maxProgress
          ? _value.maxProgress
          : maxProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementProgressImpl implements _AchievementProgress {
  const _$AchievementProgressImpl(
      {required this.achievementId,
      required this.currentProgress,
      required this.maxProgress,
      required this.isCompleted,
      this.completedAt});

  factory _$AchievementProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementProgressImplFromJson(json);

  @override
  final String achievementId;
  @override
  final int currentProgress;
  @override
  final int maxProgress;
  @override
  final bool isCompleted;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'AchievementProgress(achievementId: $achievementId, currentProgress: $currentProgress, maxProgress: $maxProgress, isCompleted: $isCompleted, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementProgressImpl &&
            (identical(other.achievementId, achievementId) ||
                other.achievementId == achievementId) &&
            (identical(other.currentProgress, currentProgress) ||
                other.currentProgress == currentProgress) &&
            (identical(other.maxProgress, maxProgress) ||
                other.maxProgress == maxProgress) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, achievementId, currentProgress,
      maxProgress, isCompleted, completedAt);

  /// Create a copy of AchievementProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementProgressImplCopyWith<_$AchievementProgressImpl> get copyWith =>
      __$$AchievementProgressImplCopyWithImpl<_$AchievementProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementProgressImplToJson(
      this,
    );
  }
}

abstract class _AchievementProgress implements AchievementProgress {
  const factory _AchievementProgress(
      {required final String achievementId,
      required final int currentProgress,
      required final int maxProgress,
      required final bool isCompleted,
      final DateTime? completedAt}) = _$AchievementProgressImpl;

  factory _AchievementProgress.fromJson(Map<String, dynamic> json) =
      _$AchievementProgressImpl.fromJson;

  @override
  String get achievementId;
  @override
  int get currentProgress;
  @override
  int get maxProgress;
  @override
  bool get isCompleted;
  @override
  DateTime? get completedAt;

  /// Create a copy of AchievementProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementProgressImplCopyWith<_$AchievementProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
