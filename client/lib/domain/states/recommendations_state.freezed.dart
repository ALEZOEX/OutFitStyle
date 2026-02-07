// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendations_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendationsState {
  AsyncValue<List<RecommendationRow>> get recommendations;
  bool get isLoading;
  String? get error;

  /// Create a copy of RecommendationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecommendationsStateCopyWith<RecommendationsState> get copyWith =>
      _$RecommendationsStateCopyWithImpl<RecommendationsState>(
          this as RecommendationsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecommendationsState &&
            (identical(other.recommendations, recommendations) ||
                other.recommendations == recommendations) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, recommendations, isLoading, error);

  @override
  String toString() {
    return 'RecommendationsState(recommendations: $recommendations, isLoading: $isLoading, error: $error)';
  }
}

/// @nodoc
abstract mixin class $RecommendationsStateCopyWith<$Res> {
  factory $RecommendationsStateCopyWith(RecommendationsState value,
          $Res Function(RecommendationsState) _then) =
      _$RecommendationsStateCopyWithImpl;
  @useResult
  $Res call(
      {AsyncValue<List<RecommendationRow>> recommendations,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$RecommendationsStateCopyWithImpl<$Res>
    implements $RecommendationsStateCopyWith<$Res> {
  _$RecommendationsStateCopyWithImpl(this._self, this._then);

  final RecommendationsState _self;
  final $Res Function(RecommendationsState) _then;

  /// Create a copy of RecommendationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recommendations = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      recommendations: null == recommendations
          ? _self.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<RecommendationRow>>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [RecommendationsState].
extension RecommendationsStatePatterns on RecommendationsState {
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
    TResult Function(_RecommendationsState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationsState() when $default != null:
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
    TResult Function(_RecommendationsState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationsState():
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
    TResult? Function(_RecommendationsState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationsState() when $default != null:
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
    TResult Function(AsyncValue<List<RecommendationRow>> recommendations,
            bool isLoading, String? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationsState() when $default != null:
        return $default(_that.recommendations, _that.isLoading, _that.error);
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
    TResult Function(AsyncValue<List<RecommendationRow>> recommendations,
            bool isLoading, String? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationsState():
        return $default(_that.recommendations, _that.isLoading, _that.error);
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
    TResult? Function(AsyncValue<List<RecommendationRow>> recommendations,
            bool isLoading, String? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationsState() when $default != null:
        return $default(_that.recommendations, _that.isLoading, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RecommendationsState extends RecommendationsState {
  const _RecommendationsState(
      {this.recommendations = const AsyncValue.loading(),
      this.isLoading = false,
      this.error})
      : super._();

  @override
  @JsonKey()
  final AsyncValue<List<RecommendationRow>> recommendations;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  /// Create a copy of RecommendationsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecommendationsStateCopyWith<_RecommendationsState> get copyWith =>
      __$RecommendationsStateCopyWithImpl<_RecommendationsState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecommendationsState &&
            (identical(other.recommendations, recommendations) ||
                other.recommendations == recommendations) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, recommendations, isLoading, error);

  @override
  String toString() {
    return 'RecommendationsState(recommendations: $recommendations, isLoading: $isLoading, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$RecommendationsStateCopyWith<$Res>
    implements $RecommendationsStateCopyWith<$Res> {
  factory _$RecommendationsStateCopyWith(_RecommendationsState value,
          $Res Function(_RecommendationsState) _then) =
      __$RecommendationsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {AsyncValue<List<RecommendationRow>> recommendations,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$RecommendationsStateCopyWithImpl<$Res>
    implements _$RecommendationsStateCopyWith<$Res> {
  __$RecommendationsStateCopyWithImpl(this._self, this._then);

  final _RecommendationsState _self;
  final $Res Function(_RecommendationsState) _then;

  /// Create a copy of RecommendationsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? recommendations = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_RecommendationsState(
      recommendations: null == recommendations
          ? _self.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<RecommendationRow>>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
