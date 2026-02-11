// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return _Achievement.fromJson(json);
}

/// @nodoc
mixin _$Achievement {
  int? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  AchievementType get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'specific_type')
  SpecificAchievementType? get specificType =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'target_progress')
  int? get targetProgress => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_progress')
  int get currentProgress => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_unlocked')
  bool get isUnlocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_visible')
  bool get isVisible => throw _privateConstructorUsedError;
  @JsonKey(name: 'unlocked_at')
  DateTime? get unlockedAt => throw _privateConstructorUsedError;
  String? get reward => throw _privateConstructorUsedError;

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
          Achievement value, $Res Function(Achievement) then) =
      _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call(
      {int? id,
      String? title,
      String? description,
      String? icon,
      AchievementType type,
      @JsonKey(name: 'specific_type') SpecificAchievementType? specificType,
      @JsonKey(name: 'target_progress') int? targetProgress,
      @JsonKey(name: 'current_progress') int currentProgress,
      @JsonKey(name: 'is_unlocked') bool isUnlocked,
      @JsonKey(name: 'is_visible') bool isVisible,
      @JsonKey(name: 'unlocked_at') DateTime? unlockedAt,
      String? reward});
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? icon = freezed,
    Object? type = null,
    Object? specificType = freezed,
    Object? targetProgress = freezed,
    Object? currentProgress = null,
    Object? isUnlocked = null,
    Object? isVisible = null,
    Object? unlockedAt = freezed,
    Object? reward = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AchievementType,
      specificType: freezed == specificType
          ? _value.specificType
          : specificType // ignore: cast_nullable_to_non_nullable
              as SpecificAchievementType?,
      targetProgress: freezed == targetProgress
          ? _value.targetProgress
          : targetProgress // ignore: cast_nullable_to_non_nullable
              as int?,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reward: freezed == reward
          ? _value.reward
          : reward // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
          _$AchievementImpl value, $Res Function(_$AchievementImpl) then) =
      __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? title,
      String? description,
      String? icon,
      AchievementType type,
      @JsonKey(name: 'specific_type') SpecificAchievementType? specificType,
      @JsonKey(name: 'target_progress') int? targetProgress,
      @JsonKey(name: 'current_progress') int currentProgress,
      @JsonKey(name: 'is_unlocked') bool isUnlocked,
      @JsonKey(name: 'is_visible') bool isVisible,
      @JsonKey(name: 'unlocked_at') DateTime? unlockedAt,
      String? reward});
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
      _$AchievementImpl _value, $Res Function(_$AchievementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? icon = freezed,
    Object? type = null,
    Object? specificType = freezed,
    Object? targetProgress = freezed,
    Object? currentProgress = null,
    Object? isUnlocked = null,
    Object? isVisible = null,
    Object? unlockedAt = freezed,
    Object? reward = freezed,
  }) {
    return _then(_$AchievementImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AchievementType,
      specificType: freezed == specificType
          ? _value.specificType
          : specificType // ignore: cast_nullable_to_non_nullable
              as SpecificAchievementType?,
      targetProgress: freezed == targetProgress
          ? _value.targetProgress
          : targetProgress // ignore: cast_nullable_to_non_nullable
              as int?,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reward: freezed == reward
          ? _value.reward
          : reward // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementImpl implements _Achievement {
  const _$AchievementImpl(
      {this.id,
      this.title,
      this.description,
      this.icon,
      this.type = AchievementType.progress,
      @JsonKey(name: 'specific_type') this.specificType,
      @JsonKey(name: 'target_progress') this.targetProgress,
      @JsonKey(name: 'current_progress') this.currentProgress = 0,
      @JsonKey(name: 'is_unlocked') this.isUnlocked = false,
      @JsonKey(name: 'is_visible') this.isVisible = false,
      @JsonKey(name: 'unlocked_at') this.unlockedAt,
      this.reward});

  factory _$AchievementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementImplFromJson(json);

  @override
  final int? id;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? icon;
  @override
  @JsonKey()
  final AchievementType type;
  @override
  @JsonKey(name: 'specific_type')
  final SpecificAchievementType? specificType;
  @override
  @JsonKey(name: 'target_progress')
  final int? targetProgress;
  @override
  @JsonKey(name: 'current_progress')
  final int currentProgress;
  @override
  @JsonKey(name: 'is_unlocked')
  final bool isUnlocked;
  @override
  @JsonKey(name: 'is_visible')
  final bool isVisible;
  @override
  @JsonKey(name: 'unlocked_at')
  final DateTime? unlockedAt;
  @override
  final String? reward;

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, icon: $icon, type: $type, specificType: $specificType, targetProgress: $targetProgress, currentProgress: $currentProgress, isUnlocked: $isUnlocked, isVisible: $isVisible, unlockedAt: $unlockedAt, reward: $reward)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.specificType, specificType) ||
                other.specificType == specificType) &&
            (identical(other.targetProgress, targetProgress) ||
                other.targetProgress == targetProgress) &&
            (identical(other.currentProgress, currentProgress) ||
                other.currentProgress == currentProgress) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            (identical(other.reward, reward) || other.reward == reward));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      icon,
      type,
      specificType,
      targetProgress,
      currentProgress,
      isUnlocked,
      isVisible,
      unlockedAt,
      reward);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementImplToJson(
      this,
    );
  }
}

abstract class _Achievement implements Achievement {
  const factory _Achievement(
      {final int? id,
      final String? title,
      final String? description,
      final String? icon,
      final AchievementType type,
      @JsonKey(name: 'specific_type')
      final SpecificAchievementType? specificType,
      @JsonKey(name: 'target_progress') final int? targetProgress,
      @JsonKey(name: 'current_progress') final int currentProgress,
      @JsonKey(name: 'is_unlocked') final bool isUnlocked,
      @JsonKey(name: 'is_visible') final bool isVisible,
      @JsonKey(name: 'unlocked_at') final DateTime? unlockedAt,
      final String? reward}) = _$AchievementImpl;

  factory _Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementImpl.fromJson;

  @override
  int? get id;
  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get icon;
  @override
  AchievementType get type;
  @override
  @JsonKey(name: 'specific_type')
  SpecificAchievementType? get specificType;
  @override
  @JsonKey(name: 'target_progress')
  int? get targetProgress;
  @override
  @JsonKey(name: 'current_progress')
  int get currentProgress;
  @override
  @JsonKey(name: 'is_unlocked')
  bool get isUnlocked;
  @override
  @JsonKey(name: 'is_visible')
  bool get isVisible;
  @override
  @JsonKey(name: 'unlocked_at')
  DateTime? get unlockedAt;
  @override
  String? get reward;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
