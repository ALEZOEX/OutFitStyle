// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GeneratorState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(OutfitRecommendation recommendation) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OutfitRecommendation recommendation)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OutfitRecommendation recommendation)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GeneratorInitial value) initial,
    required TResult Function(GeneratorLoading value) loading,
    required TResult Function(GeneratorSuccess value) success,
    required TResult Function(GeneratorError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GeneratorInitial value)? initial,
    TResult? Function(GeneratorLoading value)? loading,
    TResult? Function(GeneratorSuccess value)? success,
    TResult? Function(GeneratorError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GeneratorInitial value)? initial,
    TResult Function(GeneratorLoading value)? loading,
    TResult Function(GeneratorSuccess value)? success,
    TResult Function(GeneratorError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeneratorStateCopyWith<$Res> {
  factory $GeneratorStateCopyWith(
          GeneratorState value, $Res Function(GeneratorState) then) =
      _$GeneratorStateCopyWithImpl<$Res, GeneratorState>;
}

/// @nodoc
class _$GeneratorStateCopyWithImpl<$Res, $Val extends GeneratorState>
    implements $GeneratorStateCopyWith<$Res> {
  _$GeneratorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GeneratorInitialImplCopyWith<$Res> {
  factory _$$GeneratorInitialImplCopyWith(_$GeneratorInitialImpl value,
          $Res Function(_$GeneratorInitialImpl) then) =
      __$$GeneratorInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GeneratorInitialImplCopyWithImpl<$Res>
    extends _$GeneratorStateCopyWithImpl<$Res, _$GeneratorInitialImpl>
    implements _$$GeneratorInitialImplCopyWith<$Res> {
  __$$GeneratorInitialImplCopyWithImpl(_$GeneratorInitialImpl _value,
      $Res Function(_$GeneratorInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GeneratorInitialImpl implements GeneratorInitial {
  const _$GeneratorInitialImpl();

  @override
  String toString() {
    return 'GeneratorState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GeneratorInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(OutfitRecommendation recommendation) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OutfitRecommendation recommendation)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OutfitRecommendation recommendation)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GeneratorInitial value) initial,
    required TResult Function(GeneratorLoading value) loading,
    required TResult Function(GeneratorSuccess value) success,
    required TResult Function(GeneratorError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GeneratorInitial value)? initial,
    TResult? Function(GeneratorLoading value)? loading,
    TResult? Function(GeneratorSuccess value)? success,
    TResult? Function(GeneratorError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GeneratorInitial value)? initial,
    TResult Function(GeneratorLoading value)? loading,
    TResult Function(GeneratorSuccess value)? success,
    TResult Function(GeneratorError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class GeneratorInitial implements GeneratorState {
  const factory GeneratorInitial() = _$GeneratorInitialImpl;
}

/// @nodoc
abstract class _$$GeneratorLoadingImplCopyWith<$Res> {
  factory _$$GeneratorLoadingImplCopyWith(_$GeneratorLoadingImpl value,
          $Res Function(_$GeneratorLoadingImpl) then) =
      __$$GeneratorLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GeneratorLoadingImplCopyWithImpl<$Res>
    extends _$GeneratorStateCopyWithImpl<$Res, _$GeneratorLoadingImpl>
    implements _$$GeneratorLoadingImplCopyWith<$Res> {
  __$$GeneratorLoadingImplCopyWithImpl(_$GeneratorLoadingImpl _value,
      $Res Function(_$GeneratorLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GeneratorLoadingImpl implements GeneratorLoading {
  const _$GeneratorLoadingImpl();

  @override
  String toString() {
    return 'GeneratorState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GeneratorLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(OutfitRecommendation recommendation) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OutfitRecommendation recommendation)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OutfitRecommendation recommendation)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GeneratorInitial value) initial,
    required TResult Function(GeneratorLoading value) loading,
    required TResult Function(GeneratorSuccess value) success,
    required TResult Function(GeneratorError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GeneratorInitial value)? initial,
    TResult? Function(GeneratorLoading value)? loading,
    TResult? Function(GeneratorSuccess value)? success,
    TResult? Function(GeneratorError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GeneratorInitial value)? initial,
    TResult Function(GeneratorLoading value)? loading,
    TResult Function(GeneratorSuccess value)? success,
    TResult Function(GeneratorError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class GeneratorLoading implements GeneratorState {
  const factory GeneratorLoading() = _$GeneratorLoadingImpl;
}

/// @nodoc
abstract class _$$GeneratorSuccessImplCopyWith<$Res> {
  factory _$$GeneratorSuccessImplCopyWith(_$GeneratorSuccessImpl value,
          $Res Function(_$GeneratorSuccessImpl) then) =
      __$$GeneratorSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({OutfitRecommendation recommendation});
}

/// @nodoc
class __$$GeneratorSuccessImplCopyWithImpl<$Res>
    extends _$GeneratorStateCopyWithImpl<$Res, _$GeneratorSuccessImpl>
    implements _$$GeneratorSuccessImplCopyWith<$Res> {
  __$$GeneratorSuccessImplCopyWithImpl(_$GeneratorSuccessImpl _value,
      $Res Function(_$GeneratorSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recommendation = null,
  }) {
    return _then(_$GeneratorSuccessImpl(
      null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as OutfitRecommendation,
    ));
  }
}

/// @nodoc

class _$GeneratorSuccessImpl implements GeneratorSuccess {
  const _$GeneratorSuccessImpl(this.recommendation);

  @override
  final OutfitRecommendation recommendation;

  @override
  String toString() {
    return 'GeneratorState.success(recommendation: $recommendation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneratorSuccessImpl &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation));
  }

  @override
  int get hashCode => Object.hash(runtimeType, recommendation);

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneratorSuccessImplCopyWith<_$GeneratorSuccessImpl> get copyWith =>
      __$$GeneratorSuccessImplCopyWithImpl<_$GeneratorSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(OutfitRecommendation recommendation) success,
    required TResult Function(String error) error,
  }) {
    return success(recommendation);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OutfitRecommendation recommendation)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(recommendation);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OutfitRecommendation recommendation)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(recommendation);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GeneratorInitial value) initial,
    required TResult Function(GeneratorLoading value) loading,
    required TResult Function(GeneratorSuccess value) success,
    required TResult Function(GeneratorError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GeneratorInitial value)? initial,
    TResult? Function(GeneratorLoading value)? loading,
    TResult? Function(GeneratorSuccess value)? success,
    TResult? Function(GeneratorError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GeneratorInitial value)? initial,
    TResult Function(GeneratorLoading value)? loading,
    TResult Function(GeneratorSuccess value)? success,
    TResult Function(GeneratorError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class GeneratorSuccess implements GeneratorState {
  const factory GeneratorSuccess(final OutfitRecommendation recommendation) =
      _$GeneratorSuccessImpl;

  OutfitRecommendation get recommendation;

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeneratorSuccessImplCopyWith<_$GeneratorSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GeneratorErrorImplCopyWith<$Res> {
  factory _$$GeneratorErrorImplCopyWith(_$GeneratorErrorImpl value,
          $Res Function(_$GeneratorErrorImpl) then) =
      __$$GeneratorErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$GeneratorErrorImplCopyWithImpl<$Res>
    extends _$GeneratorStateCopyWithImpl<$Res, _$GeneratorErrorImpl>
    implements _$$GeneratorErrorImplCopyWith<$Res> {
  __$$GeneratorErrorImplCopyWithImpl(
      _$GeneratorErrorImpl _value, $Res Function(_$GeneratorErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$GeneratorErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GeneratorErrorImpl implements GeneratorError {
  const _$GeneratorErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'GeneratorState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneratorErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneratorErrorImplCopyWith<_$GeneratorErrorImpl> get copyWith =>
      __$$GeneratorErrorImplCopyWithImpl<_$GeneratorErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(OutfitRecommendation recommendation) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OutfitRecommendation recommendation)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OutfitRecommendation recommendation)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GeneratorInitial value) initial,
    required TResult Function(GeneratorLoading value) loading,
    required TResult Function(GeneratorSuccess value) success,
    required TResult Function(GeneratorError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GeneratorInitial value)? initial,
    TResult? Function(GeneratorLoading value)? loading,
    TResult? Function(GeneratorSuccess value)? success,
    TResult? Function(GeneratorError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GeneratorInitial value)? initial,
    TResult Function(GeneratorLoading value)? loading,
    TResult Function(GeneratorSuccess value)? success,
    TResult Function(GeneratorError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class GeneratorError implements GeneratorState {
  const factory GeneratorError(final String error) = _$GeneratorErrorImpl;

  String get error;

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeneratorErrorImplCopyWith<_$GeneratorErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
