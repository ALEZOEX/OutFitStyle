// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HomeState {
  AsyncValue<List<RecommendationRow>> get todayRecommendations =>
      throw _privateConstructorUsedError;
  AsyncValue<List<WardrobeItem>> get wardrobeStats =>
      throw _privateConstructorUsedError;
  AsyncValue<WeatherEntity?> get currentWeather =>
      throw _privateConstructorUsedError;
  AsyncValue<OutfitEntity?> get currentOutfit =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call(
      {AsyncValue<List<RecommendationRow>> todayRecommendations,
      AsyncValue<List<WardrobeItem>> wardrobeStats,
      AsyncValue<WeatherEntity?> currentWeather,
      AsyncValue<OutfitEntity?> currentOutfit,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayRecommendations = null,
    Object? wardrobeStats = null,
    Object? currentWeather = null,
    Object? currentOutfit = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      todayRecommendations: null == todayRecommendations
          ? _value.todayRecommendations
          : todayRecommendations // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<RecommendationRow>>,
      wardrobeStats: null == wardrobeStats
          ? _value.wardrobeStats
          : wardrobeStats // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<WardrobeItem>>,
      currentWeather: null == currentWeather
          ? _value.currentWeather
          : currentWeather // ignore: cast_nullable_to_non_nullable
              as AsyncValue<WeatherEntity?>,
      currentOutfit: null == currentOutfit
          ? _value.currentOutfit
          : currentOutfit // ignore: cast_nullable_to_non_nullable
              as AsyncValue<OutfitEntity?>,
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
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
          _$HomeStateImpl value, $Res Function(_$HomeStateImpl) then) =
      __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AsyncValue<List<RecommendationRow>> todayRecommendations,
      AsyncValue<List<WardrobeItem>> wardrobeStats,
      AsyncValue<WeatherEntity?> currentWeather,
      AsyncValue<OutfitEntity?> currentOutfit,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
      _$HomeStateImpl _value, $Res Function(_$HomeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayRecommendations = null,
    Object? wardrobeStats = null,
    Object? currentWeather = null,
    Object? currentOutfit = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$HomeStateImpl(
      todayRecommendations: null == todayRecommendations
          ? _value.todayRecommendations
          : todayRecommendations // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<RecommendationRow>>,
      wardrobeStats: null == wardrobeStats
          ? _value.wardrobeStats
          : wardrobeStats // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<WardrobeItem>>,
      currentWeather: null == currentWeather
          ? _value.currentWeather
          : currentWeather // ignore: cast_nullable_to_non_nullable
              as AsyncValue<WeatherEntity?>,
      currentOutfit: null == currentOutfit
          ? _value.currentOutfit
          : currentOutfit // ignore: cast_nullable_to_non_nullable
              as AsyncValue<OutfitEntity?>,
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

class _$HomeStateImpl extends _HomeState {
  const _$HomeStateImpl(
      {this.todayRecommendations = const AsyncValue.loading(),
      this.wardrobeStats = const AsyncValue.loading(),
      this.currentWeather = const AsyncValue.data(null),
      this.currentOutfit = const AsyncValue.data(null),
      this.isLoading = false,
      this.error})
      : super._();

  @override
  @JsonKey()
  final AsyncValue<List<RecommendationRow>> todayRecommendations;
  @override
  @JsonKey()
  final AsyncValue<List<WardrobeItem>> wardrobeStats;
  @override
  @JsonKey()
  final AsyncValue<WeatherEntity?> currentWeather;
  @override
  @JsonKey()
  final AsyncValue<OutfitEntity?> currentOutfit;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'HomeState(todayRecommendations: $todayRecommendations, wardrobeStats: $wardrobeStats, currentWeather: $currentWeather, currentOutfit: $currentOutfit, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.todayRecommendations, todayRecommendations) ||
                other.todayRecommendations == todayRecommendations) &&
            (identical(other.wardrobeStats, wardrobeStats) ||
                other.wardrobeStats == wardrobeStats) &&
            (identical(other.currentWeather, currentWeather) ||
                other.currentWeather == currentWeather) &&
            (identical(other.currentOutfit, currentOutfit) ||
                other.currentOutfit == currentOutfit) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, todayRecommendations,
      wardrobeStats, currentWeather, currentOutfit, isLoading, error);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState extends HomeState {
  const factory _HomeState(
      {final AsyncValue<List<RecommendationRow>> todayRecommendations,
      final AsyncValue<List<WardrobeItem>> wardrobeStats,
      final AsyncValue<WeatherEntity?> currentWeather,
      final AsyncValue<OutfitEntity?> currentOutfit,
      final bool isLoading,
      final String? error}) = _$HomeStateImpl;
  const _HomeState._() : super._();

  @override
  AsyncValue<List<RecommendationRow>> get todayRecommendations;
  @override
  AsyncValue<List<WardrobeItem>> get wardrobeStats;
  @override
  AsyncValue<WeatherEntity?> get currentWeather;
  @override
  AsyncValue<OutfitEntity?> get currentOutfit;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
