// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wardrobe_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WardrobeState {
  AsyncValue<List<WardrobeEntry>> get wardrobeItems;
  bool get isLoading;
  String? get error;

  /// Create a copy of WardrobeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WardrobeStateCopyWith<WardrobeState> get copyWith =>
      _$WardrobeStateCopyWithImpl<WardrobeState>(
          this as WardrobeState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WardrobeState &&
            (identical(other.wardrobeItems, wardrobeItems) ||
                other.wardrobeItems == wardrobeItems) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wardrobeItems, isLoading, error);

  @override
  String toString() {
    return 'WardrobeState(wardrobeItems: $wardrobeItems, isLoading: $isLoading, error: $error)';
  }
}

/// @nodoc
abstract mixin class $WardrobeStateCopyWith<$Res> {
  factory $WardrobeStateCopyWith(
          WardrobeState value, $Res Function(WardrobeState) _then) =
      _$WardrobeStateCopyWithImpl;
  @useResult
  $Res call(
      {AsyncValue<List<WardrobeEntry>> wardrobeItems,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$WardrobeStateCopyWithImpl<$Res>
    implements $WardrobeStateCopyWith<$Res> {
  _$WardrobeStateCopyWithImpl(this._self, this._then);

  final WardrobeState _self;
  final $Res Function(WardrobeState) _then;

  /// Create a copy of WardrobeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wardrobeItems = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      wardrobeItems: null == wardrobeItems
          ? _self.wardrobeItems
          : wardrobeItems // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<WardrobeEntry>>,
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

/// Adds pattern-matching-related methods to [WardrobeState].
extension WardrobeStatePatterns on WardrobeState {
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
    TResult Function(_WardrobeState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WardrobeState() when $default != null:
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
    TResult Function(_WardrobeState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WardrobeState():
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
    TResult? Function(_WardrobeState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WardrobeState() when $default != null:
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
    TResult Function(AsyncValue<List<WardrobeEntry>> wardrobeItems,
            bool isLoading, String? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WardrobeState() when $default != null:
        return $default(_that.wardrobeItems, _that.isLoading, _that.error);
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
    TResult Function(AsyncValue<List<WardrobeEntry>> wardrobeItems,
            bool isLoading, String? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WardrobeState():
        return $default(_that.wardrobeItems, _that.isLoading, _that.error);
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
    TResult? Function(AsyncValue<List<WardrobeEntry>> wardrobeItems,
            bool isLoading, String? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WardrobeState() when $default != null:
        return $default(_that.wardrobeItems, _that.isLoading, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _WardrobeState extends WardrobeState {
  const _WardrobeState(
      {this.wardrobeItems = const AsyncValue.loading(),
      this.isLoading = false,
      this.error})
      : super._();

  @override
  @JsonKey()
  final AsyncValue<List<WardrobeEntry>> wardrobeItems;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  /// Create a copy of WardrobeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WardrobeStateCopyWith<_WardrobeState> get copyWith =>
      __$WardrobeStateCopyWithImpl<_WardrobeState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WardrobeState &&
            (identical(other.wardrobeItems, wardrobeItems) ||
                other.wardrobeItems == wardrobeItems) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wardrobeItems, isLoading, error);

  @override
  String toString() {
    return 'WardrobeState(wardrobeItems: $wardrobeItems, isLoading: $isLoading, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$WardrobeStateCopyWith<$Res>
    implements $WardrobeStateCopyWith<$Res> {
  factory _$WardrobeStateCopyWith(
          _WardrobeState value, $Res Function(_WardrobeState) _then) =
      __$WardrobeStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {AsyncValue<List<WardrobeEntry>> wardrobeItems,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$WardrobeStateCopyWithImpl<$Res>
    implements _$WardrobeStateCopyWith<$Res> {
  __$WardrobeStateCopyWithImpl(this._self, this._then);

  final _WardrobeState _self;
  final $Res Function(_WardrobeState) _then;

  /// Create a copy of WardrobeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? wardrobeItems = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_WardrobeState(
      wardrobeItems: null == wardrobeItems
          ? _self.wardrobeItems
          : wardrobeItems // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<WardrobeEntry>>,
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
