// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AchievementProgress {
  String get achievementId;
  int get currentProgress;
  int get maxProgress;
  bool get isCompleted;
  DateTime? get completedAt;

  /// Create a copy of AchievementProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AchievementProgressCopyWith<AchievementProgress> get copyWith =>
      _$AchievementProgressCopyWithImpl<AchievementProgress>(
          this as AchievementProgress, _$identity);

  /// Serializes this AchievementProgress to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AchievementProgress &&
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

  @override
  String toString() {
    return 'AchievementProgress(achievementId: $achievementId, currentProgress: $currentProgress, maxProgress: $maxProgress, isCompleted: $isCompleted, completedAt: $completedAt)';
  }
}

/// @nodoc
abstract mixin class $AchievementProgressCopyWith<$Res> {
  factory $AchievementProgressCopyWith(
          AchievementProgress value, $Res Function(AchievementProgress) _then) =
      _$AchievementProgressCopyWithImpl;
  @useResult
  $Res call(
      {String achievementId,
      int currentProgress,
      int maxProgress,
      bool isCompleted,
      DateTime? completedAt});
}

/// @nodoc
class _$AchievementProgressCopyWithImpl<$Res>
    implements $AchievementProgressCopyWith<$Res> {
  _$AchievementProgressCopyWithImpl(this._self, this._then);

  final AchievementProgress _self;
  final $Res Function(AchievementProgress) _then;

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
    return _then(_self.copyWith(
      achievementId: null == achievementId
          ? _self.achievementId
          : achievementId // ignore: cast_nullable_to_non_nullable
              as String,
      currentProgress: null == currentProgress
          ? _self.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      maxProgress: null == maxProgress
          ? _self.maxProgress
          : maxProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AchievementProgress].
extension AchievementProgressPatterns on AchievementProgress {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AchievementProgress value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AchievementProgress() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AchievementProgress value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AchievementProgress():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AchievementProgress value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AchievementProgress() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String achievementId, int currentProgress, int maxProgress,
            bool isCompleted, DateTime? completedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AchievementProgress() when $default != null:
        return $default(_that.achievementId, _that.currentProgress,
            _that.maxProgress, _that.isCompleted, _that.completedAt);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String achievementId, int currentProgress, int maxProgress,
            bool isCompleted, DateTime? completedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AchievementProgress():
        return $default(_that.achievementId, _that.currentProgress,
            _that.maxProgress, _that.isCompleted, _that.completedAt);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String achievementId, int currentProgress,
            int maxProgress, bool isCompleted, DateTime? completedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AchievementProgress() when $default != null:
        return $default(_that.achievementId, _that.currentProgress,
            _that.maxProgress, _that.isCompleted, _that.completedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AchievementProgress implements AchievementProgress {
  const _AchievementProgress(
      {required this.achievementId,
      required this.currentProgress,
      required this.maxProgress,
      required this.isCompleted,
      this.completedAt});
  factory _AchievementProgress.fromJson(Map<String, dynamic> json) =>
      _$AchievementProgressFromJson(json);

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

  /// Create a copy of AchievementProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AchievementProgressCopyWith<_AchievementProgress> get copyWith =>
      __$AchievementProgressCopyWithImpl<_AchievementProgress>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AchievementProgressToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AchievementProgress &&
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

  @override
  String toString() {
    return 'AchievementProgress(achievementId: $achievementId, currentProgress: $currentProgress, maxProgress: $maxProgress, isCompleted: $isCompleted, completedAt: $completedAt)';
  }
}

/// @nodoc
abstract mixin class _$AchievementProgressCopyWith<$Res>
    implements $AchievementProgressCopyWith<$Res> {
  factory _$AchievementProgressCopyWith(_AchievementProgress value,
          $Res Function(_AchievementProgress) _then) =
      __$AchievementProgressCopyWithImpl;
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
class __$AchievementProgressCopyWithImpl<$Res>
    implements _$AchievementProgressCopyWith<$Res> {
  __$AchievementProgressCopyWithImpl(this._self, this._then);

  final _AchievementProgress _self;
  final $Res Function(_AchievementProgress) _then;

  /// Create a copy of AchievementProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? achievementId = null,
    Object? currentProgress = null,
    Object? maxProgress = null,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(_AchievementProgress(
      achievementId: null == achievementId
          ? _self.achievementId
          : achievementId // ignore: cast_nullable_to_non_nullable
              as String,
      currentProgress: null == currentProgress
          ? _self.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      maxProgress: null == maxProgress
          ? _self.maxProgress
          : maxProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
