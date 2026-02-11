// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) {
  return _Recommendation.fromJson(json);
}

/// @nodoc
mixin _$Recommendation {
  int? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  RecommendationType? get type => throw _privateConstructorUsedError;
  RecommendationSource? get source => throw _privateConstructorUsedError;
  @JsonKey(name: 'confidence_score')
  double? get confidenceScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // Поля, которые используются в виджетах
  @JsonKey(name: 'outfit')
  @OutfitConverter()
  Outfit? get outfit => throw _privateConstructorUsedError;
  String? get occasion => throw _privateConstructorUsedError;
  String? get activity => throw _privateConstructorUsedError;
  String? get weather => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'usage_count')
  int? get usageCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_favorite')
  bool get isFavorite => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_saved')
  bool get isSaved => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_used')
  bool get isUsed => throw _privateConstructorUsedError;
  @JsonKey(name: 'recommendation_reason')
  String? get recommendationReason => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError; // Старые поля
  @JsonKey(name: 'user_id')
  int? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'outfit_id')
  int? get outfitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'weather_condition')
  String? get weatherCondition => throw _privateConstructorUsedError;
  @JsonKey(name: 'recommended_items')
  List<String>? get recommendedItems => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_liked')
  bool? get isLiked => throw _privateConstructorUsedError;
  String? get feedback => throw _privateConstructorUsedError;

  /// Serializes this Recommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationCopyWith<Recommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationCopyWith<$Res> {
  factory $RecommendationCopyWith(
          Recommendation value, $Res Function(Recommendation) then) =
      _$RecommendationCopyWithImpl<$Res, Recommendation>;
  @useResult
  $Res call(
      {int? id,
      String? title,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl,
      RecommendationType? type,
      RecommendationSource? source,
      @JsonKey(name: 'confidence_score') double? confidenceScore,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'outfit') @OutfitConverter() Outfit? outfit,
      String? occasion,
      String? activity,
      String? weather,
      double? rating,
      @JsonKey(name: 'usage_count') int? usageCount,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      @JsonKey(name: 'is_saved') bool isSaved,
      @JsonKey(name: 'is_used') bool isUsed,
      @JsonKey(name: 'recommendation_reason') String? recommendationReason,
      List<String> tags,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'outfit_id') int? outfitId,
      @JsonKey(name: 'weather_condition') String? weatherCondition,
      @JsonKey(name: 'recommended_items') List<String>? recommendedItems,
      Map<String, dynamic>? metadata,
      @JsonKey(name: 'is_liked') bool? isLiked,
      String? feedback});

  $OutfitCopyWith<$Res>? get outfit;
}

/// @nodoc
class _$RecommendationCopyWithImpl<$Res, $Val extends Recommendation>
    implements $RecommendationCopyWith<$Res> {
  _$RecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? type = freezed,
    Object? source = freezed,
    Object? confidenceScore = freezed,
    Object? createdAt = freezed,
    Object? outfit = freezed,
    Object? occasion = freezed,
    Object? activity = freezed,
    Object? weather = freezed,
    Object? rating = freezed,
    Object? usageCount = freezed,
    Object? isFavorite = null,
    Object? isSaved = null,
    Object? isUsed = null,
    Object? recommendationReason = freezed,
    Object? tags = null,
    Object? userId = freezed,
    Object? outfitId = freezed,
    Object? weatherCondition = freezed,
    Object? recommendedItems = freezed,
    Object? metadata = freezed,
    Object? isLiked = freezed,
    Object? feedback = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecommendationType?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as RecommendationSource?,
      confidenceScore: freezed == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      outfit: freezed == outfit
          ? _value.outfit
          : outfit // ignore: cast_nullable_to_non_nullable
              as Outfit?,
      occasion: freezed == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String?,
      activity: freezed == activity
          ? _value.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as String?,
      weather: freezed == weather
          ? _value.weather
          : weather // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      usageCount: freezed == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      recommendationReason: freezed == recommendationReason
          ? _value.recommendationReason
          : recommendationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      outfitId: freezed == outfitId
          ? _value.outfitId
          : outfitId // ignore: cast_nullable_to_non_nullable
              as int?,
      weatherCondition: freezed == weatherCondition
          ? _value.weatherCondition
          : weatherCondition // ignore: cast_nullable_to_non_nullable
              as String?,
      recommendedItems: freezed == recommendedItems
          ? _value.recommendedItems
          : recommendedItems // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isLiked: freezed == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool?,
      feedback: freezed == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OutfitCopyWith<$Res>? get outfit {
    if (_value.outfit == null) {
      return null;
    }

    return $OutfitCopyWith<$Res>(_value.outfit!, (value) {
      return _then(_value.copyWith(outfit: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecommendationImplCopyWith<$Res>
    implements $RecommendationCopyWith<$Res> {
  factory _$$RecommendationImplCopyWith(_$RecommendationImpl value,
          $Res Function(_$RecommendationImpl) then) =
      __$$RecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? title,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl,
      RecommendationType? type,
      RecommendationSource? source,
      @JsonKey(name: 'confidence_score') double? confidenceScore,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'outfit') @OutfitConverter() Outfit? outfit,
      String? occasion,
      String? activity,
      String? weather,
      double? rating,
      @JsonKey(name: 'usage_count') int? usageCount,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      @JsonKey(name: 'is_saved') bool isSaved,
      @JsonKey(name: 'is_used') bool isUsed,
      @JsonKey(name: 'recommendation_reason') String? recommendationReason,
      List<String> tags,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'outfit_id') int? outfitId,
      @JsonKey(name: 'weather_condition') String? weatherCondition,
      @JsonKey(name: 'recommended_items') List<String>? recommendedItems,
      Map<String, dynamic>? metadata,
      @JsonKey(name: 'is_liked') bool? isLiked,
      String? feedback});

  @override
  $OutfitCopyWith<$Res>? get outfit;
}

/// @nodoc
class __$$RecommendationImplCopyWithImpl<$Res>
    extends _$RecommendationCopyWithImpl<$Res, _$RecommendationImpl>
    implements _$$RecommendationImplCopyWith<$Res> {
  __$$RecommendationImplCopyWithImpl(
      _$RecommendationImpl _value, $Res Function(_$RecommendationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? type = freezed,
    Object? source = freezed,
    Object? confidenceScore = freezed,
    Object? createdAt = freezed,
    Object? outfit = freezed,
    Object? occasion = freezed,
    Object? activity = freezed,
    Object? weather = freezed,
    Object? rating = freezed,
    Object? usageCount = freezed,
    Object? isFavorite = null,
    Object? isSaved = null,
    Object? isUsed = null,
    Object? recommendationReason = freezed,
    Object? tags = null,
    Object? userId = freezed,
    Object? outfitId = freezed,
    Object? weatherCondition = freezed,
    Object? recommendedItems = freezed,
    Object? metadata = freezed,
    Object? isLiked = freezed,
    Object? feedback = freezed,
  }) {
    return _then(_$RecommendationImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecommendationType?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as RecommendationSource?,
      confidenceScore: freezed == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      outfit: freezed == outfit
          ? _value.outfit
          : outfit // ignore: cast_nullable_to_non_nullable
              as Outfit?,
      occasion: freezed == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String?,
      activity: freezed == activity
          ? _value.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as String?,
      weather: freezed == weather
          ? _value.weather
          : weather // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      usageCount: freezed == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      recommendationReason: freezed == recommendationReason
          ? _value.recommendationReason
          : recommendationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      outfitId: freezed == outfitId
          ? _value.outfitId
          : outfitId // ignore: cast_nullable_to_non_nullable
              as int?,
      weatherCondition: freezed == weatherCondition
          ? _value.weatherCondition
          : weatherCondition // ignore: cast_nullable_to_non_nullable
              as String?,
      recommendedItems: freezed == recommendedItems
          ? _value._recommendedItems
          : recommendedItems // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isLiked: freezed == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool?,
      feedback: freezed == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationImpl implements _Recommendation {
  const _$RecommendationImpl(
      {this.id,
      this.title,
      this.description,
      @JsonKey(name: 'image_url') this.imageUrl,
      this.type,
      this.source,
      @JsonKey(name: 'confidence_score') this.confidenceScore,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'outfit') @OutfitConverter() this.outfit,
      this.occasion,
      this.activity,
      this.weather,
      this.rating,
      @JsonKey(name: 'usage_count') this.usageCount,
      @JsonKey(name: 'is_favorite') this.isFavorite = false,
      @JsonKey(name: 'is_saved') this.isSaved = false,
      @JsonKey(name: 'is_used') this.isUsed = false,
      @JsonKey(name: 'recommendation_reason') this.recommendationReason,
      final List<String> tags = const [],
      @JsonKey(name: 'user_id') this.userId,
      @JsonKey(name: 'outfit_id') this.outfitId,
      @JsonKey(name: 'weather_condition') this.weatherCondition,
      @JsonKey(name: 'recommended_items') final List<String>? recommendedItems,
      final Map<String, dynamic>? metadata,
      @JsonKey(name: 'is_liked') this.isLiked,
      this.feedback})
      : _tags = tags,
        _recommendedItems = recommendedItems,
        _metadata = metadata;

  factory _$RecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationImplFromJson(json);

  @override
  final int? id;
  @override
  final String? title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final RecommendationType? type;
  @override
  final RecommendationSource? source;
  @override
  @JsonKey(name: 'confidence_score')
  final double? confidenceScore;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
// Поля, которые используются в виджетах
  @override
  @JsonKey(name: 'outfit')
  @OutfitConverter()
  final Outfit? outfit;
  @override
  final String? occasion;
  @override
  final String? activity;
  @override
  final String? weather;
  @override
  final double? rating;
  @override
  @JsonKey(name: 'usage_count')
  final int? usageCount;
  @override
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @override
  @JsonKey(name: 'is_saved')
  final bool isSaved;
  @override
  @JsonKey(name: 'is_used')
  final bool isUsed;
  @override
  @JsonKey(name: 'recommendation_reason')
  final String? recommendationReason;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

// Старые поля
  @override
  @JsonKey(name: 'user_id')
  final int? userId;
  @override
  @JsonKey(name: 'outfit_id')
  final int? outfitId;
  @override
  @JsonKey(name: 'weather_condition')
  final String? weatherCondition;
  final List<String>? _recommendedItems;
  @override
  @JsonKey(name: 'recommended_items')
  List<String>? get recommendedItems {
    final value = _recommendedItems;
    if (value == null) return null;
    if (_recommendedItems is EqualUnmodifiableListView)
      return _recommendedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

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
  @JsonKey(name: 'is_liked')
  final bool? isLiked;
  @override
  final String? feedback;

  @override
  String toString() {
    return 'Recommendation(id: $id, title: $title, description: $description, imageUrl: $imageUrl, type: $type, source: $source, confidenceScore: $confidenceScore, createdAt: $createdAt, outfit: $outfit, occasion: $occasion, activity: $activity, weather: $weather, rating: $rating, usageCount: $usageCount, isFavorite: $isFavorite, isSaved: $isSaved, isUsed: $isUsed, recommendationReason: $recommendationReason, tags: $tags, userId: $userId, outfitId: $outfitId, weatherCondition: $weatherCondition, recommendedItems: $recommendedItems, metadata: $metadata, isLiked: $isLiked, feedback: $feedback)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.outfit, outfit) || other.outfit == outfit) &&
            (identical(other.occasion, occasion) ||
                other.occasion == occasion) &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed) &&
            (identical(other.recommendationReason, recommendationReason) ||
                other.recommendationReason == recommendationReason) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.outfitId, outfitId) ||
                other.outfitId == outfitId) &&
            (identical(other.weatherCondition, weatherCondition) ||
                other.weatherCondition == weatherCondition) &&
            const DeepCollectionEquality()
                .equals(other._recommendedItems, _recommendedItems) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        imageUrl,
        type,
        source,
        confidenceScore,
        createdAt,
        outfit,
        occasion,
        activity,
        weather,
        rating,
        usageCount,
        isFavorite,
        isSaved,
        isUsed,
        recommendationReason,
        const DeepCollectionEquality().hash(_tags),
        userId,
        outfitId,
        weatherCondition,
        const DeepCollectionEquality().hash(_recommendedItems),
        const DeepCollectionEquality().hash(_metadata),
        isLiked,
        feedback
      ]);

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationImplCopyWith<_$RecommendationImpl> get copyWith =>
      __$$RecommendationImplCopyWithImpl<_$RecommendationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationImplToJson(
      this,
    );
  }
}

abstract class _Recommendation implements Recommendation {
  const factory _Recommendation(
      {final int? id,
      final String? title,
      final String? description,
      @JsonKey(name: 'image_url') final String? imageUrl,
      final RecommendationType? type,
      final RecommendationSource? source,
      @JsonKey(name: 'confidence_score') final double? confidenceScore,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'outfit') @OutfitConverter() final Outfit? outfit,
      final String? occasion,
      final String? activity,
      final String? weather,
      final double? rating,
      @JsonKey(name: 'usage_count') final int? usageCount,
      @JsonKey(name: 'is_favorite') final bool isFavorite,
      @JsonKey(name: 'is_saved') final bool isSaved,
      @JsonKey(name: 'is_used') final bool isUsed,
      @JsonKey(name: 'recommendation_reason')
      final String? recommendationReason,
      final List<String> tags,
      @JsonKey(name: 'user_id') final int? userId,
      @JsonKey(name: 'outfit_id') final int? outfitId,
      @JsonKey(name: 'weather_condition') final String? weatherCondition,
      @JsonKey(name: 'recommended_items') final List<String>? recommendedItems,
      final Map<String, dynamic>? metadata,
      @JsonKey(name: 'is_liked') final bool? isLiked,
      final String? feedback}) = _$RecommendationImpl;

  factory _Recommendation.fromJson(Map<String, dynamic> json) =
      _$RecommendationImpl.fromJson;

  @override
  int? get id;
  @override
  String? get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  RecommendationType? get type;
  @override
  RecommendationSource? get source;
  @override
  @JsonKey(name: 'confidence_score')
  double? get confidenceScore;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt; // Поля, которые используются в виджетах
  @override
  @JsonKey(name: 'outfit')
  @OutfitConverter()
  Outfit? get outfit;
  @override
  String? get occasion;
  @override
  String? get activity;
  @override
  String? get weather;
  @override
  double? get rating;
  @override
  @JsonKey(name: 'usage_count')
  int? get usageCount;
  @override
  @JsonKey(name: 'is_favorite')
  bool get isFavorite;
  @override
  @JsonKey(name: 'is_saved')
  bool get isSaved;
  @override
  @JsonKey(name: 'is_used')
  bool get isUsed;
  @override
  @JsonKey(name: 'recommendation_reason')
  String? get recommendationReason;
  @override
  List<String> get tags; // Старые поля
  @override
  @JsonKey(name: 'user_id')
  int? get userId;
  @override
  @JsonKey(name: 'outfit_id')
  int? get outfitId;
  @override
  @JsonKey(name: 'weather_condition')
  String? get weatherCondition;
  @override
  @JsonKey(name: 'recommended_items')
  List<String>? get recommendedItems;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(name: 'is_liked')
  bool? get isLiked;
  @override
  String? get feedback;

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationImplCopyWith<_$RecommendationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
