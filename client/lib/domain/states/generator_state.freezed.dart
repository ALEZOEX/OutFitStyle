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
  String get occasion => throw _privateConstructorUsedError;
  Set<String> get dismissed => throw _privateConstructorUsedError;
  bool get isGenerating => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeneratorStateCopyWith<GeneratorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeneratorStateCopyWith<$Res> {
  factory $GeneratorStateCopyWith(
          GeneratorState value, $Res Function(GeneratorState) then) =
      _$GeneratorStateCopyWithImpl<$Res, GeneratorState>;
  @useResult
  $Res call(
      {String occasion,
      Set<String> dismissed,
      bool isGenerating,
      String? error});
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
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? occasion = null,
    Object? dismissed = null,
    Object? isGenerating = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      occasion: null == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String,
      dismissed: null == dismissed
          ? _value.dismissed
          : dismissed // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isGenerating: null == isGenerating
          ? _value.isGenerating
          : isGenerating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GeneratorStateImplCopyWith<$Res>
    implements $GeneratorStateCopyWith<$Res> {
  factory _$$GeneratorStateImplCopyWith(_$GeneratorStateImpl value,
          $Res Function(_$GeneratorStateImpl) then) =
      __$$GeneratorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String occasion,
      Set<String> dismissed,
      bool isGenerating,
      String? error});
}

/// @nodoc
class __$$GeneratorStateImplCopyWithImpl<$Res>
    extends _$GeneratorStateCopyWithImpl<$Res, _$GeneratorStateImpl>
    implements _$$GeneratorStateImplCopyWith<$Res> {
  __$$GeneratorStateImplCopyWithImpl(
      _$GeneratorStateImpl _value, $Res Function(_$GeneratorStateImpl) _then)
      : super(_value, _then);

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
    return _then(_$GeneratorStateImpl(
      occasion: null == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String,
      dismissed: null == dismissed
          ? _value._dismissed
          : dismissed // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isGenerating: null == isGenerating
          ? _value.isGenerating
          : isGenerating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$GeneratorStateImpl extends _GeneratorState {
  const _$GeneratorStateImpl(
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

  @override
  String toString() {
    return 'GeneratorState(occasion: $occasion, dismissed: $dismissed, isGenerating: $isGenerating, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneratorStateImpl &&
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

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneratorStateImplCopyWith<_$GeneratorStateImpl> get copyWith =>
      __$$GeneratorStateImplCopyWithImpl<_$GeneratorStateImpl>(
          this, _$identity);
}

abstract class _GeneratorState extends GeneratorState {
  const factory _GeneratorState(
      {final String occasion,
      final Set<String> dismissed,
      final bool isGenerating,
      final String? error}) = _$GeneratorStateImpl;
  const _GeneratorState._() : super._();

  @override
  String get occasion;
  @override
  Set<String> get dismissed;
  @override
  bool get isGenerating;
  @override
  String? get error;

  /// Create a copy of GeneratorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeneratorStateImplCopyWith<_$GeneratorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
