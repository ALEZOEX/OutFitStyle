// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AdminState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Map<String, dynamic> stats) loaded,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Map<String, dynamic> stats)? loaded,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Map<String, dynamic> stats)? loaded,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AdminInitial value) initial,
    required TResult Function(AdminLoading value) loading,
    required TResult Function(AdminLoaded value) loaded,
    required TResult Function(AdminError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AdminInitial value)? initial,
    TResult? Function(AdminLoading value)? loading,
    TResult? Function(AdminLoaded value)? loaded,
    TResult? Function(AdminError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AdminInitial value)? initial,
    TResult Function(AdminLoading value)? loading,
    TResult Function(AdminLoaded value)? loaded,
    TResult Function(AdminError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminStateCopyWith<$Res> {
  factory $AdminStateCopyWith(
          AdminState value, $Res Function(AdminState) then) =
      _$AdminStateCopyWithImpl<$Res, AdminState>;
}

/// @nodoc
class _$AdminStateCopyWithImpl<$Res, $Val extends AdminState>
    implements $AdminStateCopyWith<$Res> {
  _$AdminStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AdminInitialImplCopyWith<$Res> {
  factory _$$AdminInitialImplCopyWith(
          _$AdminInitialImpl value, $Res Function(_$AdminInitialImpl) then) =
      __$$AdminInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AdminInitialImplCopyWithImpl<$Res>
    extends _$AdminStateCopyWithImpl<$Res, _$AdminInitialImpl>
    implements _$$AdminInitialImplCopyWith<$Res> {
  __$$AdminInitialImplCopyWithImpl(
      _$AdminInitialImpl _value, $Res Function(_$AdminInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AdminInitialImpl implements AdminInitial {
  const _$AdminInitialImpl();

  @override
  String toString() {
    return 'AdminState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AdminInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Map<String, dynamic> stats) loaded,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Map<String, dynamic> stats)? loaded,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Map<String, dynamic> stats)? loaded,
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
    required TResult Function(AdminInitial value) initial,
    required TResult Function(AdminLoading value) loading,
    required TResult Function(AdminLoaded value) loaded,
    required TResult Function(AdminError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AdminInitial value)? initial,
    TResult? Function(AdminLoading value)? loading,
    TResult? Function(AdminLoaded value)? loaded,
    TResult? Function(AdminError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AdminInitial value)? initial,
    TResult Function(AdminLoading value)? loading,
    TResult Function(AdminLoaded value)? loaded,
    TResult Function(AdminError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class AdminInitial implements AdminState {
  const factory AdminInitial() = _$AdminInitialImpl;
}

/// @nodoc
abstract class _$$AdminLoadingImplCopyWith<$Res> {
  factory _$$AdminLoadingImplCopyWith(
          _$AdminLoadingImpl value, $Res Function(_$AdminLoadingImpl) then) =
      __$$AdminLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AdminLoadingImplCopyWithImpl<$Res>
    extends _$AdminStateCopyWithImpl<$Res, _$AdminLoadingImpl>
    implements _$$AdminLoadingImplCopyWith<$Res> {
  __$$AdminLoadingImplCopyWithImpl(
      _$AdminLoadingImpl _value, $Res Function(_$AdminLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AdminLoadingImpl implements AdminLoading {
  const _$AdminLoadingImpl();

  @override
  String toString() {
    return 'AdminState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AdminLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Map<String, dynamic> stats) loaded,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Map<String, dynamic> stats)? loaded,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Map<String, dynamic> stats)? loaded,
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
    required TResult Function(AdminInitial value) initial,
    required TResult Function(AdminLoading value) loading,
    required TResult Function(AdminLoaded value) loaded,
    required TResult Function(AdminError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AdminInitial value)? initial,
    TResult? Function(AdminLoading value)? loading,
    TResult? Function(AdminLoaded value)? loaded,
    TResult? Function(AdminError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AdminInitial value)? initial,
    TResult Function(AdminLoading value)? loading,
    TResult Function(AdminLoaded value)? loaded,
    TResult Function(AdminError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class AdminLoading implements AdminState {
  const factory AdminLoading() = _$AdminLoadingImpl;
}

/// @nodoc
abstract class _$$AdminLoadedImplCopyWith<$Res> {
  factory _$$AdminLoadedImplCopyWith(
          _$AdminLoadedImpl value, $Res Function(_$AdminLoadedImpl) then) =
      __$$AdminLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Map<String, dynamic> stats});
}

/// @nodoc
class __$$AdminLoadedImplCopyWithImpl<$Res>
    extends _$AdminStateCopyWithImpl<$Res, _$AdminLoadedImpl>
    implements _$$AdminLoadedImplCopyWith<$Res> {
  __$$AdminLoadedImplCopyWithImpl(
      _$AdminLoadedImpl _value, $Res Function(_$AdminLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stats = null,
  }) {
    return _then(_$AdminLoadedImpl(
      null == stats
          ? _value._stats
          : stats // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$AdminLoadedImpl implements AdminLoaded {
  const _$AdminLoadedImpl(final Map<String, dynamic> stats) : _stats = stats;

  final Map<String, dynamic> _stats;
  @override
  Map<String, dynamic> get stats {
    if (_stats is EqualUnmodifiableMapView) return _stats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stats);
  }

  @override
  String toString() {
    return 'AdminState.loaded(stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminLoadedImpl &&
            const DeepCollectionEquality().equals(other._stats, _stats));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_stats));

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminLoadedImplCopyWith<_$AdminLoadedImpl> get copyWith =>
      __$$AdminLoadedImplCopyWithImpl<_$AdminLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Map<String, dynamic> stats) loaded,
    required TResult Function(String error) error,
  }) {
    return loaded(stats);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Map<String, dynamic> stats)? loaded,
    TResult? Function(String error)? error,
  }) {
    return loaded?.call(stats);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Map<String, dynamic> stats)? loaded,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(stats);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AdminInitial value) initial,
    required TResult Function(AdminLoading value) loading,
    required TResult Function(AdminLoaded value) loaded,
    required TResult Function(AdminError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AdminInitial value)? initial,
    TResult? Function(AdminLoading value)? loading,
    TResult? Function(AdminLoaded value)? loaded,
    TResult? Function(AdminError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AdminInitial value)? initial,
    TResult Function(AdminLoading value)? loading,
    TResult Function(AdminLoaded value)? loaded,
    TResult Function(AdminError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class AdminLoaded implements AdminState {
  const factory AdminLoaded(final Map<String, dynamic> stats) =
      _$AdminLoadedImpl;

  Map<String, dynamic> get stats;

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminLoadedImplCopyWith<_$AdminLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AdminErrorImplCopyWith<$Res> {
  factory _$$AdminErrorImplCopyWith(
          _$AdminErrorImpl value, $Res Function(_$AdminErrorImpl) then) =
      __$$AdminErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$AdminErrorImplCopyWithImpl<$Res>
    extends _$AdminStateCopyWithImpl<$Res, _$AdminErrorImpl>
    implements _$$AdminErrorImplCopyWith<$Res> {
  __$$AdminErrorImplCopyWithImpl(
      _$AdminErrorImpl _value, $Res Function(_$AdminErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$AdminErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AdminErrorImpl implements AdminError {
  const _$AdminErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'AdminState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminErrorImplCopyWith<_$AdminErrorImpl> get copyWith =>
      __$$AdminErrorImplCopyWithImpl<_$AdminErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Map<String, dynamic> stats) loaded,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Map<String, dynamic> stats)? loaded,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Map<String, dynamic> stats)? loaded,
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
    required TResult Function(AdminInitial value) initial,
    required TResult Function(AdminLoading value) loading,
    required TResult Function(AdminLoaded value) loaded,
    required TResult Function(AdminError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AdminInitial value)? initial,
    TResult? Function(AdminLoading value)? loading,
    TResult? Function(AdminLoaded value)? loaded,
    TResult? Function(AdminError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AdminInitial value)? initial,
    TResult Function(AdminLoading value)? loading,
    TResult Function(AdminLoaded value)? loaded,
    TResult Function(AdminError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class AdminError implements AdminState {
  const factory AdminError(final String error) = _$AdminErrorImpl;

  String get error;

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminErrorImplCopyWith<_$AdminErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
