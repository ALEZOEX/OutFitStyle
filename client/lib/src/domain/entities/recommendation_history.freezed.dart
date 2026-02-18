// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendationHistory {

 int? get id; int? get userId;@JsonKey(name: 'recommendation')@RecommendationConverter() Recommendation? get recommendation; bool get isUsed; bool get isLiked; bool get isSaved; int get rating; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of RecommendationHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationHistoryCopyWith<RecommendationHistory> get copyWith => _$RecommendationHistoryCopyWithImpl<RecommendationHistory>(this as RecommendationHistory, _$identity);

  /// Serializes this RecommendationHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.isUsed, isUsed) || other.isUsed == isUsed)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,recommendation,isUsed,isLiked,isSaved,rating,createdAt,updatedAt);

@override
String toString() {
  return 'RecommendationHistory(id: $id, userId: $userId, recommendation: $recommendation, isUsed: $isUsed, isLiked: $isLiked, isSaved: $isSaved, rating: $rating, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RecommendationHistoryCopyWith<$Res>  {
  factory $RecommendationHistoryCopyWith(RecommendationHistory value, $Res Function(RecommendationHistory) _then) = _$RecommendationHistoryCopyWithImpl;
@useResult
$Res call({
 int? id, int? userId,@JsonKey(name: 'recommendation')@RecommendationConverter() Recommendation? recommendation, bool isUsed, bool isLiked, bool isSaved, int rating, DateTime? createdAt, DateTime? updatedAt
});


$RecommendationCopyWith<$Res>? get recommendation;

}
/// @nodoc
class _$RecommendationHistoryCopyWithImpl<$Res>
    implements $RecommendationHistoryCopyWith<$Res> {
  _$RecommendationHistoryCopyWithImpl(this._self, this._then);

  final RecommendationHistory _self;
  final $Res Function(RecommendationHistory) _then;

/// Create a copy of RecommendationHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = freezed,Object? recommendation = freezed,Object? isUsed = null,Object? isLiked = null,Object? isSaved = null,Object? rating = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,recommendation: freezed == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as Recommendation?,isUsed: null == isUsed ? _self.isUsed : isUsed // ignore: cast_nullable_to_non_nullable
as bool,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RecommendationHistory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecommendationCopyWith<$Res>? get recommendation {
    if (_self.recommendation == null) {
    return null;
  }

  return $RecommendationCopyWith<$Res>(_self.recommendation!, (value) {
    return _then(_self.copyWith(recommendation: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecommendationHistory].
extension RecommendationHistoryPatterns on RecommendationHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationHistory value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationHistory value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? userId, @JsonKey(name: 'recommendation')@RecommendationConverter()  Recommendation? recommendation,  bool isUsed,  bool isLiked,  bool isSaved,  int rating,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationHistory() when $default != null:
return $default(_that.id,_that.userId,_that.recommendation,_that.isUsed,_that.isLiked,_that.isSaved,_that.rating,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? userId, @JsonKey(name: 'recommendation')@RecommendationConverter()  Recommendation? recommendation,  bool isUsed,  bool isLiked,  bool isSaved,  int rating,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RecommendationHistory():
return $default(_that.id,_that.userId,_that.recommendation,_that.isUsed,_that.isLiked,_that.isSaved,_that.rating,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? userId, @JsonKey(name: 'recommendation')@RecommendationConverter()  Recommendation? recommendation,  bool isUsed,  bool isLiked,  bool isSaved,  int rating,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationHistory() when $default != null:
return $default(_that.id,_that.userId,_that.recommendation,_that.isUsed,_that.isLiked,_that.isSaved,_that.rating,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationHistory implements RecommendationHistory {
  const _RecommendationHistory({this.id, this.userId, @JsonKey(name: 'recommendation')@RecommendationConverter() this.recommendation, this.isUsed = false, this.isLiked = false, this.isSaved = false, this.rating = 0, this.createdAt, this.updatedAt});
  factory _RecommendationHistory.fromJson(Map<String, dynamic> json) => _$RecommendationHistoryFromJson(json);

@override final  int? id;
@override final  int? userId;
@override@JsonKey(name: 'recommendation')@RecommendationConverter() final  Recommendation? recommendation;
@override@JsonKey() final  bool isUsed;
@override@JsonKey() final  bool isLiked;
@override@JsonKey() final  bool isSaved;
@override@JsonKey() final  int rating;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of RecommendationHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationHistoryCopyWith<_RecommendationHistory> get copyWith => __$RecommendationHistoryCopyWithImpl<_RecommendationHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.isUsed, isUsed) || other.isUsed == isUsed)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,recommendation,isUsed,isLiked,isSaved,rating,createdAt,updatedAt);

@override
String toString() {
  return 'RecommendationHistory(id: $id, userId: $userId, recommendation: $recommendation, isUsed: $isUsed, isLiked: $isLiked, isSaved: $isSaved, rating: $rating, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RecommendationHistoryCopyWith<$Res> implements $RecommendationHistoryCopyWith<$Res> {
  factory _$RecommendationHistoryCopyWith(_RecommendationHistory value, $Res Function(_RecommendationHistory) _then) = __$RecommendationHistoryCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? userId,@JsonKey(name: 'recommendation')@RecommendationConverter() Recommendation? recommendation, bool isUsed, bool isLiked, bool isSaved, int rating, DateTime? createdAt, DateTime? updatedAt
});


@override $RecommendationCopyWith<$Res>? get recommendation;

}
/// @nodoc
class __$RecommendationHistoryCopyWithImpl<$Res>
    implements _$RecommendationHistoryCopyWith<$Res> {
  __$RecommendationHistoryCopyWithImpl(this._self, this._then);

  final _RecommendationHistory _self;
  final $Res Function(_RecommendationHistory) _then;

/// Create a copy of RecommendationHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = freezed,Object? recommendation = freezed,Object? isUsed = null,Object? isLiked = null,Object? isSaved = null,Object? rating = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RecommendationHistory(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,recommendation: freezed == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as Recommendation?,isUsed: null == isUsed ? _self.isUsed : isUsed // ignore: cast_nullable_to_non_nullable
as bool,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RecommendationHistory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecommendationCopyWith<$Res>? get recommendation {
    if (_self.recommendation == null) {
    return null;
  }

  return $RecommendationCopyWith<$Res>(_self.recommendation!, (value) {
    return _then(_self.copyWith(recommendation: value));
  });
}
}

// dart format on
