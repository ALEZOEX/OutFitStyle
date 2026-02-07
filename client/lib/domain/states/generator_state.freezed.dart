// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GeneratorState {
  String get occasion;
  Set<String> get dismissed;
  bool get isGenerating;
  String? get error;

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GeneratorStateCopyWith<GeneratorState> get copyWith =>
      _$GeneratorStateCopyWithImpl<GeneratorState>(
          this as GeneratorState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GeneratorState &&
            (identical(other.occasion, occasion) ||
                other.occasion == occasion) &&
            const DeepCollectionEquality().equals(other.dismissed, dismissed) &&
            (identical(other.isGenerating, isGenerating) ||
                other.isGenerating == isGenerating) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, occasion,
      const DeepCollectionEquality().hash(dismissed), isGenerating, error);

  @override
  String toString() {
    return 'GeneratorState(occasion: $occasion, dismissed: $dismissed, isGenerating: $isGenerating, error: $error)';
  }
}

/// @nodoc
abstract mixin class $GeneratorStateCopyWith<$Res> {
  factory $GeneratorStateCopyWith(
          GeneratorState value, $Res Function(GeneratorState) _then) =
      _$GeneratorStateCopyWithImpl;
  @useResult
  $Res call(
      {String occasion,
      Set<String> dismissed,
      bool isGenerating,
      String? error});
}

/// @nodoc
class _$GeneratorStateCopyWithImpl<$Res>
    implements $GeneratorStateCopyWith<$Res> {
  _$GeneratorStateCopyWithImpl(this._self, this._then);

  final GeneratorState _self;
  final $Res Function(GeneratorState) _then;

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? occasion = null,
    Object? dismissed = null,
    Object? isGenerating = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      occasion: null == occasion
          ? _self.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String,
      dismissed: null == dismissed
          ? _self.dismissed
          : dismissed // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isGenerating: null == isGenerating
          ? _self.isGenerating
          : isGenerating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [GeneratorState].
extension GeneratorStatePatterns on GeneratorState {
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
    TResult Function(_GeneratorState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GeneratorState() when $default != null:
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
    TResult Function(_GeneratorState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeneratorState():
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
    TResult? Function(_GeneratorState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeneratorState() when $default != null:
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
    TResult Function(String occasion, Set<String> dismissed, bool isGenerating,
            String? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GeneratorState() when $default != null:
        return $default(
            _that.occasion, _that.dismissed, _that.isGenerating, _that.error);
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
    TResult Function(String occasion, Set<String> dismissed, bool isGenerating,
            String? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeneratorState():
        return $default(
            _that.occasion, _that.dismissed, _that.isGenerating, _that.error);
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
    TResult? Function(String occasion, Set<String> dismissed, bool isGenerating,
            String? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeneratorState() when $default != null:
        return $default(
            _that.occasion, _that.dismissed, _that.isGenerating, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GeneratorState extends GeneratorState {
  const _GeneratorState(
      {this.occasion = 'casual',
      final Set<String> dismissed = const <String>{},
      this.isGenerating = false,
      this.error})
      : _dismissed = dismissed,
        super._();

  @override
  @JsonKey()
  final String occasion;
  final Set<String> _dismissed;
  @override
  @JsonKey()
  Set<String> get dismissed {
    if (_dismissed is EqualUnmodifiableSetView) return _dismissed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_dismissed);
  }

  @override
  @JsonKey()
  final bool isGenerating;
  @override
  final String? error;

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GeneratorStateCopyWith<_GeneratorState> get copyWith =>
      __$GeneratorStateCopyWithImpl<_GeneratorState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GeneratorState &&
            (identical(other.occasion, occasion) ||
                other.occasion == occasion) &&
            const DeepCollectionEquality()
                .equals(other._dismissed, _dismissed) &&
            (identical(other.isGenerating, isGenerating) ||
                other.isGenerating == isGenerating) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, occasion,
      const DeepCollectionEquality().hash(_dismissed), isGenerating, error);

  @override
  String toString() {
    return 'GeneratorState(occasion: $occasion, dismissed: $dismissed, isGenerating: $isGenerating, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$GeneratorStateCopyWith<$Res>
    implements $GeneratorStateCopyWith<$Res> {
  factory _$GeneratorStateCopyWith(
          _GeneratorState value, $Res Function(_GeneratorState) _then) =
      __$GeneratorStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String occasion,
      Set<String> dismissed,
      bool isGenerating,
      String? error});
}

/// @nodoc
class __$GeneratorStateCopyWithImpl<$Res>
    implements _$GeneratorStateCopyWith<$Res> {
  __$GeneratorStateCopyWithImpl(this._self, this._then);

  final _GeneratorState _self;
  final $Res Function(_GeneratorState) _then;

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? occasion = null,
    Object? dismissed = null,
    Object? isGenerating = null,
    Object? error = freezed,
  }) {
    return _then(_GeneratorState(
      occasion: null == occasion
          ? _self.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String,
      dismissed: null == dismissed
          ? _self._dismissed
          : dismissed // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isGenerating: null == isGenerating
          ? _self.isGenerating
          : isGenerating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
