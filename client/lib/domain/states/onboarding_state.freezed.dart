// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OnboardingState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(int step) inProgress,
    required TResult Function() complete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(int step)? inProgress,
    TResult? Function()? complete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(int step)? inProgress,
    TResult Function()? complete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnboardingInitial value) initial,
    required TResult Function(OnboardingInProgress value) inProgress,
    required TResult Function(OnboardingComplete value) complete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitial value)? initial,
    TResult? Function(OnboardingInProgress value)? inProgress,
    TResult? Function(OnboardingComplete value)? complete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitial value)? initial,
    TResult Function(OnboardingInProgress value)? inProgress,
    TResult Function(OnboardingComplete value)? complete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
          OnboardingState value, $Res Function(OnboardingState) then) =
      _$OnboardingStateCopyWithImpl<$Res, OnboardingState>;
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res, $Val extends OnboardingState>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$OnboardingInitialImplCopyWith<$Res> {
  factory _$$OnboardingInitialImplCopyWith(_$OnboardingInitialImpl value,
          $Res Function(_$OnboardingInitialImpl) then) =
      __$$OnboardingInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$OnboardingInitialImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingInitialImpl>
    implements _$$OnboardingInitialImplCopyWith<$Res> {
  __$$OnboardingInitialImplCopyWithImpl(_$OnboardingInitialImpl _value,
      $Res Function(_$OnboardingInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$OnboardingInitialImpl implements OnboardingInitial {
  const _$OnboardingInitialImpl();

  @override
  String toString() {
    return 'OnboardingState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$OnboardingInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(int step) inProgress,
    required TResult Function() complete,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(int step)? inProgress,
    TResult? Function()? complete,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(int step)? inProgress,
    TResult Function()? complete,
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
    required TResult Function(OnboardingInitial value) initial,
    required TResult Function(OnboardingInProgress value) inProgress,
    required TResult Function(OnboardingComplete value) complete,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitial value)? initial,
    TResult? Function(OnboardingInProgress value)? inProgress,
    TResult? Function(OnboardingComplete value)? complete,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitial value)? initial,
    TResult Function(OnboardingInProgress value)? inProgress,
    TResult Function(OnboardingComplete value)? complete,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class OnboardingInitial implements OnboardingState {
  const factory OnboardingInitial() = _$OnboardingInitialImpl;
}

/// @nodoc
abstract class _$$OnboardingInProgressImplCopyWith<$Res> {
  factory _$$OnboardingInProgressImplCopyWith(_$OnboardingInProgressImpl value,
          $Res Function(_$OnboardingInProgressImpl) then) =
      __$$OnboardingInProgressImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int step});
}

/// @nodoc
class __$$OnboardingInProgressImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingInProgressImpl>
    implements _$$OnboardingInProgressImplCopyWith<$Res> {
  __$$OnboardingInProgressImplCopyWithImpl(_$OnboardingInProgressImpl _value,
      $Res Function(_$OnboardingInProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
  }) {
    return _then(_$OnboardingInProgressImpl(
      step: null == step
          ? _value.step
          : step // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$OnboardingInProgressImpl implements OnboardingInProgress {
  const _$OnboardingInProgressImpl({required this.step});

  @override
  final int step;

  @override
  String toString() {
    return 'OnboardingState.inProgress(step: $step)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingInProgressImpl &&
            (identical(other.step, step) || other.step == step));
  }

  @override
  int get hashCode => Object.hash(runtimeType, step);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingInProgressImplCopyWith<_$OnboardingInProgressImpl>
      get copyWith =>
          __$$OnboardingInProgressImplCopyWithImpl<_$OnboardingInProgressImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(int step) inProgress,
    required TResult Function() complete,
  }) {
    return inProgress(step);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(int step)? inProgress,
    TResult? Function()? complete,
  }) {
    return inProgress?.call(step);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(int step)? inProgress,
    TResult Function()? complete,
    required TResult orElse(),
  }) {
    if (inProgress != null) {
      return inProgress(step);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnboardingInitial value) initial,
    required TResult Function(OnboardingInProgress value) inProgress,
    required TResult Function(OnboardingComplete value) complete,
  }) {
    return inProgress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitial value)? initial,
    TResult? Function(OnboardingInProgress value)? inProgress,
    TResult? Function(OnboardingComplete value)? complete,
  }) {
    return inProgress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitial value)? initial,
    TResult Function(OnboardingInProgress value)? inProgress,
    TResult Function(OnboardingComplete value)? complete,
    required TResult orElse(),
  }) {
    if (inProgress != null) {
      return inProgress(this);
    }
    return orElse();
  }
}

abstract class OnboardingInProgress implements OnboardingState {
  const factory OnboardingInProgress({required final int step}) =
      _$OnboardingInProgressImpl;

  int get step;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingInProgressImplCopyWith<_$OnboardingInProgressImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OnboardingCompleteImplCopyWith<$Res> {
  factory _$$OnboardingCompleteImplCopyWith(_$OnboardingCompleteImpl value,
          $Res Function(_$OnboardingCompleteImpl) then) =
      __$$OnboardingCompleteImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$OnboardingCompleteImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingCompleteImpl>
    implements _$$OnboardingCompleteImplCopyWith<$Res> {
  __$$OnboardingCompleteImplCopyWithImpl(_$OnboardingCompleteImpl _value,
      $Res Function(_$OnboardingCompleteImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$OnboardingCompleteImpl implements OnboardingComplete {
  const _$OnboardingCompleteImpl();

  @override
  String toString() {
    return 'OnboardingState.complete()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$OnboardingCompleteImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(int step) inProgress,
    required TResult Function() complete,
  }) {
    return complete();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(int step)? inProgress,
    TResult? Function()? complete,
  }) {
    return complete?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(int step)? inProgress,
    TResult Function()? complete,
    required TResult orElse(),
  }) {
    if (complete != null) {
      return complete();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnboardingInitial value) initial,
    required TResult Function(OnboardingInProgress value) inProgress,
    required TResult Function(OnboardingComplete value) complete,
  }) {
    return complete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitial value)? initial,
    TResult? Function(OnboardingInProgress value)? inProgress,
    TResult? Function(OnboardingComplete value)? complete,
  }) {
    return complete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitial value)? initial,
    TResult Function(OnboardingInProgress value)? inProgress,
    TResult Function(OnboardingComplete value)? complete,
    required TResult orElse(),
  }) {
    if (complete != null) {
      return complete(this);
    }
    return orElse();
  }
}

abstract class OnboardingComplete implements OnboardingState {
  const factory OnboardingComplete() = _$OnboardingCompleteImpl;
}
