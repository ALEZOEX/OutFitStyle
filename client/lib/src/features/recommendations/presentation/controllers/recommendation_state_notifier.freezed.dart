// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_state_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RecommendationState {
  AsyncValue<List<Recommendation>> get recommendations =>
      throw _privateConstructorUsedError;
  List<Recommendation> get historyRecommendations =>
      throw _privateConstructorUsedError;
  List<Recommendation> get savedRecommendations =>
      throw _privateConstructorUsedError;
  UserPreference get preferences => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationStateCopyWith<RecommendationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationStateCopyWith<$Res> {
  factory $RecommendationStateCopyWith(
          RecommendationState value, $Res Function(RecommendationState) then) =
      _$RecommendationStateCopyWithImpl<$Res, RecommendationState>;
  @useResult
  $Res call(
      {AsyncValue<List<Recommendation>> recommendations,
      List<Recommendation> historyRecommendations,
      List<Recommendation> savedRecommendations,
      UserPreference preferences,
      bool isLoading,
      bool isRefreshing,
      String? error});

  $UserPreferenceCopyWith<$Res> get preferences;
}

/// @nodoc
class _$RecommendationStateCopyWithImpl<$Res, $Val extends RecommendationState>
    implements $RecommendationStateCopyWith<$Res> {
  _$RecommendationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recommendations = null,
    Object? historyRecommendations = null,
    Object? savedRecommendations = null,
    Object? preferences = null,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<Recommendation>>,
      historyRecommendations: null == historyRecommendations
          ? _value.historyRecommendations
          : historyRecommendations // ignore: cast_nullable_to_non_nullable
              as List<Recommendation>,
      savedRecommendations: null == savedRecommendations
          ? _value.savedRecommendations
          : savedRecommendations // ignore: cast_nullable_to_non_nullable
              as List<Recommendation>,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreference,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of RecommendationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferenceCopyWith<$Res> get preferences {
    return $UserPreferenceCopyWith<$Res>(_value.preferences, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecommendationStateImplCopyWith<$Res>
    implements $RecommendationStateCopyWith<$Res> {
  factory _$$RecommendationStateImplCopyWith(_$RecommendationStateImpl value,
          $Res Function(_$RecommendationStateImpl) then) =
      __$$RecommendationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AsyncValue<List<Recommendation>> recommendations,
      List<Recommendation> historyRecommendations,
      List<Recommendation> savedRecommendations,
      UserPreference preferences,
      bool isLoading,
      bool isRefreshing,
      String? error});

  @override
  $UserPreferenceCopyWith<$Res> get preferences;
}

/// @nodoc
class __$$RecommendationStateImplCopyWithImpl<$Res>
    extends _$RecommendationStateCopyWithImpl<$Res, _$RecommendationStateImpl>
    implements _$$RecommendationStateImplCopyWith<$Res> {
  __$$RecommendationStateImplCopyWithImpl(_$RecommendationStateImpl _value,
      $Res Function(_$RecommendationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecommendationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recommendations = null,
    Object? historyRecommendations = null,
    Object? savedRecommendations = null,
    Object? preferences = null,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? error = freezed,
  }) {
    return _then(_$RecommendationStateImpl(
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<Recommendation>>,
      historyRecommendations: null == historyRecommendations
          ? _value._historyRecommendations
          : historyRecommendations // ignore: cast_nullable_to_non_nullable
              as List<Recommendation>,
      savedRecommendations: null == savedRecommendations
          ? _value._savedRecommendations
          : savedRecommendations // ignore: cast_nullable_to_non_nullable
              as List<Recommendation>,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreference,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$RecommendationStateImpl extends _RecommendationState {
  const _$RecommendationStateImpl(
      {this.recommendations = const AsyncValue.loading(),
      final List<Recommendation> historyRecommendations = const [],
      final List<Recommendation> savedRecommendations = const [],
      this.preferences = const UserPreference(),
      this.isLoading = false,
      this.isRefreshing = false,
      this.error})
      : _historyRecommendations = historyRecommendations,
        _savedRecommendations = savedRecommendations,
        super._();

  @override
  @JsonKey()
  final AsyncValue<List<Recommendation>> recommendations;
  final List<Recommendation> _historyRecommendations;
  @override
  @JsonKey()
  List<Recommendation> get historyRecommendations {
    if (_historyRecommendations is EqualUnmodifiableListView)
      return _historyRecommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_historyRecommendations);
  }

  final List<Recommendation> _savedRecommendations;
  @override
  @JsonKey()
  List<Recommendation> get savedRecommendations {
    if (_savedRecommendations is EqualUnmodifiableListView)
      return _savedRecommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_savedRecommendations);
  }

  @override
  @JsonKey()
  final UserPreference preferences;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isRefreshing;
  @override
  final String? error;

  @override
  String toString() {
    return 'RecommendationState(recommendations: $recommendations, historyRecommendations: $historyRecommendations, savedRecommendations: $savedRecommendations, preferences: $preferences, isLoading: $isLoading, isRefreshing: $isRefreshing, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationStateImpl &&
            (identical(other.recommendations, recommendations) ||
                other.recommendations == recommendations) &&
            const DeepCollectionEquality().equals(
                other._historyRecommendations, _historyRecommendations) &&
            const DeepCollectionEquality()
                .equals(other._savedRecommendations, _savedRecommendations) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      recommendations,
      const DeepCollectionEquality().hash(_historyRecommendations),
      const DeepCollectionEquality().hash(_savedRecommendations),
      preferences,
      isLoading,
      isRefreshing,
      error);

  /// Create a copy of RecommendationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationStateImplCopyWith<_$RecommendationStateImpl> get copyWith =>
      __$$RecommendationStateImplCopyWithImpl<_$RecommendationStateImpl>(
          this, _$identity);
}

abstract class _RecommendationState extends RecommendationState {
  const factory _RecommendationState(
      {final AsyncValue<List<Recommendation>> recommendations,
      final List<Recommendation> historyRecommendations,
      final List<Recommendation> savedRecommendations,
      final UserPreference preferences,
      final bool isLoading,
      final bool isRefreshing,
      final String? error}) = _$RecommendationStateImpl;
  const _RecommendationState._() : super._();

  @override
  AsyncValue<List<Recommendation>> get recommendations;
  @override
  List<Recommendation> get historyRecommendations;
  @override
  List<Recommendation> get savedRecommendations;
  @override
  UserPreference get preferences;
  @override
  bool get isLoading;
  @override
  bool get isRefreshing;
  @override
  String? get error;

  /// Create a copy of RecommendationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationStateImplCopyWith<_$RecommendationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
