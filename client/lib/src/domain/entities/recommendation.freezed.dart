// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Recommendation {

 int? get id; String? get title; String? get description; RecommendationType? get type; RecommendationSource? get source;@JsonKey(name: 'confidence_score') double? get confidenceScore;@JsonKey(name: 'created_at') DateTime? get createdAt;// Поля, которые используются в виджетах
@JsonKey(name: 'outfit')@OutfitConverter() Outfit? get outfit; String? get occasion; String? get activity; String? get weather; double? get rating;@JsonKey(name: 'usage_count') int? get usageCount;@JsonKey(name: 'is_favorite') bool get isFavorite;@JsonKey(name: 'is_saved') bool get isSaved;@JsonKey(name: 'is_used') bool get isUsed;@JsonKey(name: 'recommendation_reason') String? get recommendationReason; List<String> get tags;// Старые поля
@JsonKey(name: 'user_id') int? get userId;@JsonKey(name: 'outfit_id') int? get outfitId;@JsonKey(name: 'weather_condition') String? get weatherCondition;@JsonKey(name: 'recommended_items') List<String>? get recommendedItems; Map<String, dynamic>? get metadata;@JsonKey(name: 'is_liked') bool? get isLiked; String? get feedback;
/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationCopyWith<Recommendation> get copyWith => _$RecommendationCopyWithImpl<Recommendation>(this as Recommendation, _$identity);

  /// Serializes this Recommendation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recommendation&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.source, source) || other.source == source)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.outfit, outfit) || other.outfit == outfit)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.weather, weather) || other.weather == weather)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.isUsed, isUsed) || other.isUsed == isUsed)&&(identical(other.recommendationReason, recommendationReason) || other.recommendationReason == recommendationReason)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.outfitId, outfitId) || other.outfitId == outfitId)&&(identical(other.weatherCondition, weatherCondition) || other.weatherCondition == weatherCondition)&&const DeepCollectionEquality().equals(other.recommendedItems, recommendedItems)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.feedback, feedback) || other.feedback == feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,type,source,confidenceScore,createdAt,outfit,occasion,activity,weather,rating,usageCount,isFavorite,isSaved,isUsed,recommendationReason,const DeepCollectionEquality().hash(tags),userId,outfitId,weatherCondition,const DeepCollectionEquality().hash(recommendedItems),const DeepCollectionEquality().hash(metadata),isLiked,feedback]);

@override
String toString() {
  return 'Recommendation(id: $id, title: $title, description: $description, type: $type, source: $source, confidenceScore: $confidenceScore, createdAt: $createdAt, outfit: $outfit, occasion: $occasion, activity: $activity, weather: $weather, rating: $rating, usageCount: $usageCount, isFavorite: $isFavorite, isSaved: $isSaved, isUsed: $isUsed, recommendationReason: $recommendationReason, tags: $tags, userId: $userId, outfitId: $outfitId, weatherCondition: $weatherCondition, recommendedItems: $recommendedItems, metadata: $metadata, isLiked: $isLiked, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class $RecommendationCopyWith<$Res>  {
  factory $RecommendationCopyWith(Recommendation value, $Res Function(Recommendation) _then) = _$RecommendationCopyWithImpl;
@useResult
$Res call({
 int? id, String? title, String? description, RecommendationType? type, RecommendationSource? source,@JsonKey(name: 'confidence_score') double? confidenceScore,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'outfit')@OutfitConverter() Outfit? outfit, String? occasion, String? activity, String? weather, double? rating,@JsonKey(name: 'usage_count') int? usageCount,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'is_saved') bool isSaved,@JsonKey(name: 'is_used') bool isUsed,@JsonKey(name: 'recommendation_reason') String? recommendationReason, List<String> tags,@JsonKey(name: 'user_id') int? userId,@JsonKey(name: 'outfit_id') int? outfitId,@JsonKey(name: 'weather_condition') String? weatherCondition,@JsonKey(name: 'recommended_items') List<String>? recommendedItems, Map<String, dynamic>? metadata,@JsonKey(name: 'is_liked') bool? isLiked, String? feedback
});


$OutfitCopyWith<$Res>? get outfit;

}
/// @nodoc
class _$RecommendationCopyWithImpl<$Res>
    implements $RecommendationCopyWith<$Res> {
  _$RecommendationCopyWithImpl(this._self, this._then);

  final Recommendation _self;
  final $Res Function(Recommendation) _then;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = freezed,Object? description = freezed,Object? type = freezed,Object? source = freezed,Object? confidenceScore = freezed,Object? createdAt = freezed,Object? outfit = freezed,Object? occasion = freezed,Object? activity = freezed,Object? weather = freezed,Object? rating = freezed,Object? usageCount = freezed,Object? isFavorite = null,Object? isSaved = null,Object? isUsed = null,Object? recommendationReason = freezed,Object? tags = null,Object? userId = freezed,Object? outfitId = freezed,Object? weatherCondition = freezed,Object? recommendedItems = freezed,Object? metadata = freezed,Object? isLiked = freezed,Object? feedback = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecommendationType?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RecommendationSource?,confidenceScore: freezed == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outfit: freezed == outfit ? _self.outfit : outfit // ignore: cast_nullable_to_non_nullable
as Outfit?,occasion: freezed == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String?,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as String?,weather: freezed == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,usageCount: freezed == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,isUsed: null == isUsed ? _self.isUsed : isUsed // ignore: cast_nullable_to_non_nullable
as bool,recommendationReason: freezed == recommendationReason ? _self.recommendationReason : recommendationReason // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,outfitId: freezed == outfitId ? _self.outfitId : outfitId // ignore: cast_nullable_to_non_nullable
as int?,weatherCondition: freezed == weatherCondition ? _self.weatherCondition : weatherCondition // ignore: cast_nullable_to_non_nullable
as String?,recommendedItems: freezed == recommendedItems ? _self.recommendedItems : recommendedItems // ignore: cast_nullable_to_non_nullable
as List<String>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isLiked: freezed == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutfitCopyWith<$Res>? get outfit {
    if (_self.outfit == null) {
    return null;
  }

  return $OutfitCopyWith<$Res>(_self.outfit!, (value) {
    return _then(_self.copyWith(outfit: value));
  });
}
}


/// Adds pattern-matching-related methods to [Recommendation].
extension RecommendationPatterns on Recommendation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recommendation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recommendation value)  $default,){
final _that = this;
switch (_that) {
case _Recommendation():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recommendation value)?  $default,){
final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? title,  String? description,  RecommendationType? type,  RecommendationSource? source, @JsonKey(name: 'confidence_score')  double? confidenceScore, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'outfit')@OutfitConverter()  Outfit? outfit,  String? occasion,  String? activity,  String? weather,  double? rating, @JsonKey(name: 'usage_count')  int? usageCount, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'is_saved')  bool isSaved, @JsonKey(name: 'is_used')  bool isUsed, @JsonKey(name: 'recommendation_reason')  String? recommendationReason,  List<String> tags, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'outfit_id')  int? outfitId, @JsonKey(name: 'weather_condition')  String? weatherCondition, @JsonKey(name: 'recommended_items')  List<String>? recommendedItems,  Map<String, dynamic>? metadata, @JsonKey(name: 'is_liked')  bool? isLiked,  String? feedback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.type,_that.source,_that.confidenceScore,_that.createdAt,_that.outfit,_that.occasion,_that.activity,_that.weather,_that.rating,_that.usageCount,_that.isFavorite,_that.isSaved,_that.isUsed,_that.recommendationReason,_that.tags,_that.userId,_that.outfitId,_that.weatherCondition,_that.recommendedItems,_that.metadata,_that.isLiked,_that.feedback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? title,  String? description,  RecommendationType? type,  RecommendationSource? source, @JsonKey(name: 'confidence_score')  double? confidenceScore, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'outfit')@OutfitConverter()  Outfit? outfit,  String? occasion,  String? activity,  String? weather,  double? rating, @JsonKey(name: 'usage_count')  int? usageCount, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'is_saved')  bool isSaved, @JsonKey(name: 'is_used')  bool isUsed, @JsonKey(name: 'recommendation_reason')  String? recommendationReason,  List<String> tags, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'outfit_id')  int? outfitId, @JsonKey(name: 'weather_condition')  String? weatherCondition, @JsonKey(name: 'recommended_items')  List<String>? recommendedItems,  Map<String, dynamic>? metadata, @JsonKey(name: 'is_liked')  bool? isLiked,  String? feedback)  $default,) {final _that = this;
switch (_that) {
case _Recommendation():
return $default(_that.id,_that.title,_that.description,_that.type,_that.source,_that.confidenceScore,_that.createdAt,_that.outfit,_that.occasion,_that.activity,_that.weather,_that.rating,_that.usageCount,_that.isFavorite,_that.isSaved,_that.isUsed,_that.recommendationReason,_that.tags,_that.userId,_that.outfitId,_that.weatherCondition,_that.recommendedItems,_that.metadata,_that.isLiked,_that.feedback);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? title,  String? description,  RecommendationType? type,  RecommendationSource? source, @JsonKey(name: 'confidence_score')  double? confidenceScore, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'outfit')@OutfitConverter()  Outfit? outfit,  String? occasion,  String? activity,  String? weather,  double? rating, @JsonKey(name: 'usage_count')  int? usageCount, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'is_saved')  bool isSaved, @JsonKey(name: 'is_used')  bool isUsed, @JsonKey(name: 'recommendation_reason')  String? recommendationReason,  List<String> tags, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'outfit_id')  int? outfitId, @JsonKey(name: 'weather_condition')  String? weatherCondition, @JsonKey(name: 'recommended_items')  List<String>? recommendedItems,  Map<String, dynamic>? metadata, @JsonKey(name: 'is_liked')  bool? isLiked,  String? feedback)?  $default,) {final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.type,_that.source,_that.confidenceScore,_that.createdAt,_that.outfit,_that.occasion,_that.activity,_that.weather,_that.rating,_that.usageCount,_that.isFavorite,_that.isSaved,_that.isUsed,_that.recommendationReason,_that.tags,_that.userId,_that.outfitId,_that.weatherCondition,_that.recommendedItems,_that.metadata,_that.isLiked,_that.feedback);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recommendation implements Recommendation {
  const _Recommendation({this.id, this.title, this.description, this.type, this.source, @JsonKey(name: 'confidence_score') this.confidenceScore, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'outfit')@OutfitConverter() this.outfit, this.occasion, this.activity, this.weather, this.rating, @JsonKey(name: 'usage_count') this.usageCount, @JsonKey(name: 'is_favorite') this.isFavorite = false, @JsonKey(name: 'is_saved') this.isSaved = false, @JsonKey(name: 'is_used') this.isUsed = false, @JsonKey(name: 'recommendation_reason') this.recommendationReason, final  List<String> tags = const [], @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'outfit_id') this.outfitId, @JsonKey(name: 'weather_condition') this.weatherCondition, @JsonKey(name: 'recommended_items') final  List<String>? recommendedItems, final  Map<String, dynamic>? metadata, @JsonKey(name: 'is_liked') this.isLiked, this.feedback}): _tags = tags,_recommendedItems = recommendedItems,_metadata = metadata;
  factory _Recommendation.fromJson(Map<String, dynamic> json) => _$RecommendationFromJson(json);

@override final  int? id;
@override final  String? title;
@override final  String? description;
@override final  RecommendationType? type;
@override final  RecommendationSource? source;
@override@JsonKey(name: 'confidence_score') final  double? confidenceScore;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
// Поля, которые используются в виджетах
@override@JsonKey(name: 'outfit')@OutfitConverter() final  Outfit? outfit;
@override final  String? occasion;
@override final  String? activity;
@override final  String? weather;
@override final  double? rating;
@override@JsonKey(name: 'usage_count') final  int? usageCount;
@override@JsonKey(name: 'is_favorite') final  bool isFavorite;
@override@JsonKey(name: 'is_saved') final  bool isSaved;
@override@JsonKey(name: 'is_used') final  bool isUsed;
@override@JsonKey(name: 'recommendation_reason') final  String? recommendationReason;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

// Старые поля
@override@JsonKey(name: 'user_id') final  int? userId;
@override@JsonKey(name: 'outfit_id') final  int? outfitId;
@override@JsonKey(name: 'weather_condition') final  String? weatherCondition;
 final  List<String>? _recommendedItems;
@override@JsonKey(name: 'recommended_items') List<String>? get recommendedItems {
  final value = _recommendedItems;
  if (value == null) return null;
  if (_recommendedItems is EqualUnmodifiableListView) return _recommendedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'is_liked') final  bool? isLiked;
@override final  String? feedback;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationCopyWith<_Recommendation> get copyWith => __$RecommendationCopyWithImpl<_Recommendation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recommendation&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.source, source) || other.source == source)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.outfit, outfit) || other.outfit == outfit)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.weather, weather) || other.weather == weather)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.isUsed, isUsed) || other.isUsed == isUsed)&&(identical(other.recommendationReason, recommendationReason) || other.recommendationReason == recommendationReason)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.outfitId, outfitId) || other.outfitId == outfitId)&&(identical(other.weatherCondition, weatherCondition) || other.weatherCondition == weatherCondition)&&const DeepCollectionEquality().equals(other._recommendedItems, _recommendedItems)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.feedback, feedback) || other.feedback == feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,type,source,confidenceScore,createdAt,outfit,occasion,activity,weather,rating,usageCount,isFavorite,isSaved,isUsed,recommendationReason,const DeepCollectionEquality().hash(_tags),userId,outfitId,weatherCondition,const DeepCollectionEquality().hash(_recommendedItems),const DeepCollectionEquality().hash(_metadata),isLiked,feedback]);

@override
String toString() {
  return 'Recommendation(id: $id, title: $title, description: $description, type: $type, source: $source, confidenceScore: $confidenceScore, createdAt: $createdAt, outfit: $outfit, occasion: $occasion, activity: $activity, weather: $weather, rating: $rating, usageCount: $usageCount, isFavorite: $isFavorite, isSaved: $isSaved, isUsed: $isUsed, recommendationReason: $recommendationReason, tags: $tags, userId: $userId, outfitId: $outfitId, weatherCondition: $weatherCondition, recommendedItems: $recommendedItems, metadata: $metadata, isLiked: $isLiked, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class _$RecommendationCopyWith<$Res> implements $RecommendationCopyWith<$Res> {
  factory _$RecommendationCopyWith(_Recommendation value, $Res Function(_Recommendation) _then) = __$RecommendationCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? title, String? description, RecommendationType? type, RecommendationSource? source,@JsonKey(name: 'confidence_score') double? confidenceScore,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'outfit')@OutfitConverter() Outfit? outfit, String? occasion, String? activity, String? weather, double? rating,@JsonKey(name: 'usage_count') int? usageCount,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'is_saved') bool isSaved,@JsonKey(name: 'is_used') bool isUsed,@JsonKey(name: 'recommendation_reason') String? recommendationReason, List<String> tags,@JsonKey(name: 'user_id') int? userId,@JsonKey(name: 'outfit_id') int? outfitId,@JsonKey(name: 'weather_condition') String? weatherCondition,@JsonKey(name: 'recommended_items') List<String>? recommendedItems, Map<String, dynamic>? metadata,@JsonKey(name: 'is_liked') bool? isLiked, String? feedback
});


@override $OutfitCopyWith<$Res>? get outfit;

}
/// @nodoc
class __$RecommendationCopyWithImpl<$Res>
    implements _$RecommendationCopyWith<$Res> {
  __$RecommendationCopyWithImpl(this._self, this._then);

  final _Recommendation _self;
  final $Res Function(_Recommendation) _then;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = freezed,Object? description = freezed,Object? type = freezed,Object? source = freezed,Object? confidenceScore = freezed,Object? createdAt = freezed,Object? outfit = freezed,Object? occasion = freezed,Object? activity = freezed,Object? weather = freezed,Object? rating = freezed,Object? usageCount = freezed,Object? isFavorite = null,Object? isSaved = null,Object? isUsed = null,Object? recommendationReason = freezed,Object? tags = null,Object? userId = freezed,Object? outfitId = freezed,Object? weatherCondition = freezed,Object? recommendedItems = freezed,Object? metadata = freezed,Object? isLiked = freezed,Object? feedback = freezed,}) {
  return _then(_Recommendation(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecommendationType?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RecommendationSource?,confidenceScore: freezed == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outfit: freezed == outfit ? _self.outfit : outfit // ignore: cast_nullable_to_non_nullable
as Outfit?,occasion: freezed == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String?,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as String?,weather: freezed == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,usageCount: freezed == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,isUsed: null == isUsed ? _self.isUsed : isUsed // ignore: cast_nullable_to_non_nullable
as bool,recommendationReason: freezed == recommendationReason ? _self.recommendationReason : recommendationReason // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,outfitId: freezed == outfitId ? _self.outfitId : outfitId // ignore: cast_nullable_to_non_nullable
as int?,weatherCondition: freezed == weatherCondition ? _self.weatherCondition : weatherCondition // ignore: cast_nullable_to_non_nullable
as String?,recommendedItems: freezed == recommendedItems ? _self._recommendedItems : recommendedItems // ignore: cast_nullable_to_non_nullable
as List<String>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isLiked: freezed == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutfitCopyWith<$Res>? get outfit {
    if (_self.outfit == null) {
    return null;
  }

  return $OutfitCopyWith<$Res>(_self.outfit!, (value) {
    return _then(_self.copyWith(outfit: value));
  });
}
}

// dart format on
