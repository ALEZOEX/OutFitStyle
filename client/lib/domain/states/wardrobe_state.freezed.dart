// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wardrobe_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WardrobeState {
  AsyncState<List<WardrobeEntry>> get wardrobeItems =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of WardrobeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WardrobeStateCopyWith<WardrobeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WardrobeStateCopyWith<$Res> {
  factory $WardrobeStateCopyWith(
          WardrobeState value, $Res Function(WardrobeState) then) =
      _$WardrobeStateCopyWithImpl<$Res, WardrobeState>;
  @useResult
  $Res call(
      {AsyncState<List<WardrobeEntry>> wardrobeItems,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$WardrobeStateCopyWithImpl<$Res, $Val extends WardrobeState>
    implements $WardrobeStateCopyWith<$Res> {
  _$WardrobeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WardrobeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wardrobeItems = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      wardrobeItems: null == wardrobeItems
          ? _value.wardrobeItems
          : wardrobeItems // ignore: cast_nullable_to_non_nullable
              as AsyncState<List<WardrobeEntry>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WardrobeStateImplCopyWith<$Res>
    implements $WardrobeStateCopyWith<$Res> {
  factory _$$WardrobeStateImplCopyWith(
          _$WardrobeStateImpl value, $Res Function(_$WardrobeStateImpl) then) =
      __$$WardrobeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AsyncState<List<WardrobeEntry>> wardrobeItems,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$WardrobeStateImplCopyWithImpl<$Res>
    extends _$WardrobeStateCopyWithImpl<$Res, _$WardrobeStateImpl>
    implements _$$WardrobeStateImplCopyWith<$Res> {
  __$$WardrobeStateImplCopyWithImpl(
      _$WardrobeStateImpl _value, $Res Function(_$WardrobeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WardrobeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wardrobeItems = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$WardrobeStateImpl(
      wardrobeItems: null == wardrobeItems
          ? _value.wardrobeItems
          : wardrobeItems // ignore: cast_nullable_to_non_nullable
              as AsyncState<List<WardrobeEntry>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$WardrobeStateImpl extends _WardrobeState {
  const _$WardrobeStateImpl(
      {this.wardrobeItems = const AsyncLoading<List<WardrobeEntry>>(),
      this.isLoading = false,
      this.error})
      : super._();

  @override
  @JsonKey()
  final AsyncState<List<WardrobeEntry>> wardrobeItems;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'WardrobeState(wardrobeItems: $wardrobeItems, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WardrobeStateImpl &&
            (identical(other.wardrobeItems, wardrobeItems) ||
                other.wardrobeItems == wardrobeItems) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wardrobeItems, isLoading, error);

  /// Create a copy of WardrobeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WardrobeStateImplCopyWith<_$WardrobeStateImpl> get copyWith =>
      __$$WardrobeStateImplCopyWithImpl<_$WardrobeStateImpl>(this, _$identity);
}

abstract class _WardrobeState extends WardrobeState {
  const factory _WardrobeState(
      {final AsyncState<List<WardrobeEntry>> wardrobeItems,
      final bool isLoading,
      final String? error}) = _$WardrobeStateImpl;
  const _WardrobeState._() : super._();

  @override
  AsyncState<List<WardrobeEntry>> get wardrobeItems;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of WardrobeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WardrobeStateImplCopyWith<_$WardrobeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
