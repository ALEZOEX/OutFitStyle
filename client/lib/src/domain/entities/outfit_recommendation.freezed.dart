// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OutfitRecommendation {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get weatherCondition => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  List<String> get clothingItems => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  double get confidenceScore => throw _privateConstructorUsedError;
  String? get feedback => throw _privateConstructorUsedError;
  bool? get isLiked => throw _privateConstructorUsedError;
  bool? get isSaved => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Create a copy of OutfitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutfitRecommendationCopyWith<OutfitRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitRecommendationCopyWith<$Res> {
  factory $OutfitRecommendationCopyWith(OutfitRecommendation value,
          $Res Function(OutfitRecommendation) then) =
      _$OutfitRecommendationCopyWithImpl<$Res, OutfitRecommendation>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String weatherCondition,
      double temperature,
      List<String> clothingItems,
      DateTime createdAt,
      double confidenceScore,
      String? feedback,
      bool? isLiked,
      bool? isSaved,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$OutfitRecommendationCopyWithImpl<$Res,
        $Val extends OutfitRecommendation>
    implements $OutfitRecommendationCopyWith<$Res> {
  _$OutfitRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OutfitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? weatherCondition = null,
    Object? temperature = null,
    Object? clothingItems = null,
    Object? createdAt = null,
    Object? confidenceScore = null,
    Object? feedback = freezed,
    Object? isLiked = freezed,
    Object? isSaved = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      weatherCondition: null == weatherCondition
          ? _value.weatherCondition
          : weatherCondition // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      clothingItems: null == clothingItems
          ? _value.clothingItems
          : clothingItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
      feedback: freezed == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String?,
      isLiked: freezed == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool?,
      isSaved: freezed == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutfitRecommendationImplCopyWith<$Res>
    implements $OutfitRecommendationCopyWith<$Res> {
  factory _$$OutfitRecommendationImplCopyWith(_$OutfitRecommendationImpl value,
          $Res Function(_$OutfitRecommendationImpl) then) =
      __$$OutfitRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String weatherCondition,
      double temperature,
      List<String> clothingItems,
      DateTime createdAt,
      double confidenceScore,
      String? feedback,
      bool? isLiked,
      bool? isSaved,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$OutfitRecommendationImplCopyWithImpl<$Res>
    extends _$OutfitRecommendationCopyWithImpl<$Res, _$OutfitRecommendationImpl>
    implements _$$OutfitRecommendationImplCopyWith<$Res> {
  __$$OutfitRecommendationImplCopyWithImpl(_$OutfitRecommendationImpl _value,
      $Res Function(_$OutfitRecommendationImpl) _then)
      : super(_value, _then);

  /// Create a copy of OutfitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? weatherCondition = null,
    Object? temperature = null,
    Object? clothingItems = null,
    Object? createdAt = null,
    Object? confidenceScore = null,
    Object? feedback = freezed,
    Object? isLiked = freezed,
    Object? isSaved = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$OutfitRecommendationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      weatherCondition: null == weatherCondition
          ? _value.weatherCondition
          : weatherCondition // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      clothingItems: null == clothingItems
          ? _value._clothingItems
          : clothingItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
      feedback: freezed == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String?,
      isLiked: freezed == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool?,
      isSaved: freezed == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$OutfitRecommendationImpl implements _OutfitRecommendation {
  const _$OutfitRecommendationImpl(
      {required this.id,
      required this.userId,
      required this.weatherCondition,
      required this.temperature,
      required final List<String> clothingItems,
      required this.createdAt,
      required this.confidenceScore,
      this.feedback,
      this.isLiked,
      this.isSaved,
      final Map<String, dynamic>? metadata})
      : _clothingItems = clothingItems,
        _metadata = metadata;

  @override
  final String id;
  @override
  final String userId;
  @override
  final String weatherCondition;
  @override
  final double temperature;
  final List<String> _clothingItems;
  @override
  List<String> get clothingItems {
    if (_clothingItems is EqualUnmodifiableListView) return _clothingItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_clothingItems);
  }

  @override
  final DateTime createdAt;
  @override
  final double confidenceScore;
  @override
  final String? feedback;
  @override
  final bool? isLiked;
  @override
  final bool? isSaved;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'OutfitRecommendation(id: $id, userId: $userId, weatherCondition: $weatherCondition, temperature: $temperature, clothingItems: $clothingItems, createdAt: $createdAt, confidenceScore: $confidenceScore, feedback: $feedback, isLiked: $isLiked, isSaved: $isSaved, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitRecommendationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.weatherCondition, weatherCondition) ||
                other.weatherCondition == weatherCondition) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            const DeepCollectionEquality()
                .equals(other._clothingItems, _clothingItems) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      weatherCondition,
      temperature,
      const DeepCollectionEquality().hash(_clothingItems),
      createdAt,
      confidenceScore,
      feedback,
      isLiked,
      isSaved,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of OutfitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitRecommendationImplCopyWith<_$OutfitRecommendationImpl>
      get copyWith =>
          __$$OutfitRecommendationImplCopyWithImpl<_$OutfitRecommendationImpl>(
              this, _$identity);
}

abstract class _OutfitRecommendation implements OutfitRecommendation {
  const factory _OutfitRecommendation(
      {required final String id,
      required final String userId,
      required final String weatherCondition,
      required final double temperature,
      required final List<String> clothingItems,
      required final DateTime createdAt,
      required final double confidenceScore,
      final String? feedback,
      final bool? isLiked,
      final bool? isSaved,
      final Map<String, dynamic>? metadata}) = _$OutfitRecommendationImpl;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get weatherCondition;
  @override
  double get temperature;
  @override
  List<String> get clothingItems;
  @override
  DateTime get createdAt;
  @override
  double get confidenceScore;
  @override
  String? get feedback;
  @override
  bool? get isLiked;
  @override
  bool? get isSaved;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of OutfitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutfitRecommendationImplCopyWith<_$OutfitRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
