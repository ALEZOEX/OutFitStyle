// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendationFeedback {

 String get id; String get userId; String get recommendationId; int get rating;// 1-5 stars
 List<String> get tags;// positive, negative, neutral tags
 String get comment; List<String> get likedItems;// specific items in the outfit that were liked
 List<String> get dislikedItems;// specific items in the outfit that were disliked
 bool get wouldReuse; bool get wouldRecommend; List<String> get improvementSuggestions; FeedbackCategory get category; FeedbackSource get source; String get dummyField;// Workaround for DateTime default issue
 DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of RecommendationFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationFeedbackCopyWith<RecommendationFeedback> get copyWith => _$RecommendationFeedbackCopyWithImpl<RecommendationFeedback>(this as RecommendationFeedback, _$identity);

  /// Serializes this RecommendationFeedback to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.recommendationId, recommendationId) || other.recommendationId == recommendationId)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.likedItems, likedItems)&&const DeepCollectionEquality().equals(other.dislikedItems, dislikedItems)&&(identical(other.wouldReuse, wouldReuse) || other.wouldReuse == wouldReuse)&&(identical(other.wouldRecommend, wouldRecommend) || other.wouldRecommend == wouldRecommend)&&const DeepCollectionEquality().equals(other.improvementSuggestions, improvementSuggestions)&&(identical(other.category, category) || other.category == category)&&(identical(other.source, source) || other.source == source)&&(identical(other.dummyField, dummyField) || other.dummyField == dummyField)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,recommendationId,rating,const DeepCollectionEquality().hash(tags),comment,const DeepCollectionEquality().hash(likedItems),const DeepCollectionEquality().hash(dislikedItems),wouldReuse,wouldRecommend,const DeepCollectionEquality().hash(improvementSuggestions),category,source,dummyField,createdAt,updatedAt);

@override
String toString() {
  return 'RecommendationFeedback(id: $id, userId: $userId, recommendationId: $recommendationId, rating: $rating, tags: $tags, comment: $comment, likedItems: $likedItems, dislikedItems: $dislikedItems, wouldReuse: $wouldReuse, wouldRecommend: $wouldRecommend, improvementSuggestions: $improvementSuggestions, category: $category, source: $source, dummyField: $dummyField, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RecommendationFeedbackCopyWith<$Res>  {
  factory $RecommendationFeedbackCopyWith(RecommendationFeedback value, $Res Function(RecommendationFeedback) _then) = _$RecommendationFeedbackCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String recommendationId, int rating, List<String> tags, String comment, List<String> likedItems, List<String> dislikedItems, bool wouldReuse, bool wouldRecommend, List<String> improvementSuggestions, FeedbackCategory category, FeedbackSource source, String dummyField, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$RecommendationFeedbackCopyWithImpl<$Res>
    implements $RecommendationFeedbackCopyWith<$Res> {
  _$RecommendationFeedbackCopyWithImpl(this._self, this._then);

  final RecommendationFeedback _self;
  final $Res Function(RecommendationFeedback) _then;

/// Create a copy of RecommendationFeedback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? recommendationId = null,Object? rating = null,Object? tags = null,Object? comment = null,Object? likedItems = null,Object? dislikedItems = null,Object? wouldReuse = null,Object? wouldRecommend = null,Object? improvementSuggestions = null,Object? category = null,Object? source = null,Object? dummyField = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,recommendationId: null == recommendationId ? _self.recommendationId : recommendationId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,likedItems: null == likedItems ? _self.likedItems : likedItems // ignore: cast_nullable_to_non_nullable
as List<String>,dislikedItems: null == dislikedItems ? _self.dislikedItems : dislikedItems // ignore: cast_nullable_to_non_nullable
as List<String>,wouldReuse: null == wouldReuse ? _self.wouldReuse : wouldReuse // ignore: cast_nullable_to_non_nullable
as bool,wouldRecommend: null == wouldRecommend ? _self.wouldRecommend : wouldRecommend // ignore: cast_nullable_to_non_nullable
as bool,improvementSuggestions: null == improvementSuggestions ? _self.improvementSuggestions : improvementSuggestions // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as FeedbackCategory,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FeedbackSource,dummyField: null == dummyField ? _self.dummyField : dummyField // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendationFeedback].
extension RecommendationFeedbackPatterns on RecommendationFeedback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationFeedback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationFeedback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationFeedback value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationFeedback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationFeedback value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationFeedback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String recommendationId,  int rating,  List<String> tags,  String comment,  List<String> likedItems,  List<String> dislikedItems,  bool wouldReuse,  bool wouldRecommend,  List<String> improvementSuggestions,  FeedbackCategory category,  FeedbackSource source,  String dummyField,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationFeedback() when $default != null:
return $default(_that.id,_that.userId,_that.recommendationId,_that.rating,_that.tags,_that.comment,_that.likedItems,_that.dislikedItems,_that.wouldReuse,_that.wouldRecommend,_that.improvementSuggestions,_that.category,_that.source,_that.dummyField,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String recommendationId,  int rating,  List<String> tags,  String comment,  List<String> likedItems,  List<String> dislikedItems,  bool wouldReuse,  bool wouldRecommend,  List<String> improvementSuggestions,  FeedbackCategory category,  FeedbackSource source,  String dummyField,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RecommendationFeedback():
return $default(_that.id,_that.userId,_that.recommendationId,_that.rating,_that.tags,_that.comment,_that.likedItems,_that.dislikedItems,_that.wouldReuse,_that.wouldRecommend,_that.improvementSuggestions,_that.category,_that.source,_that.dummyField,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String recommendationId,  int rating,  List<String> tags,  String comment,  List<String> likedItems,  List<String> dislikedItems,  bool wouldReuse,  bool wouldRecommend,  List<String> improvementSuggestions,  FeedbackCategory category,  FeedbackSource source,  String dummyField,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationFeedback() when $default != null:
return $default(_that.id,_that.userId,_that.recommendationId,_that.rating,_that.tags,_that.comment,_that.likedItems,_that.dislikedItems,_that.wouldReuse,_that.wouldRecommend,_that.improvementSuggestions,_that.category,_that.source,_that.dummyField,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationFeedback implements RecommendationFeedback {
  const _RecommendationFeedback({this.id = '', this.userId = '', this.recommendationId = '', this.rating = 0, final  List<String> tags = const <String>[], this.comment = '', final  List<String> likedItems = const <String>[], final  List<String> dislikedItems = const <String>[], this.wouldReuse = false, this.wouldRecommend = false, final  List<String> improvementSuggestions = const <String>[], this.category = FeedbackCategory.general, this.source = FeedbackSource.user, this.dummyField = '', this.createdAt, this.updatedAt}): _tags = tags,_likedItems = likedItems,_dislikedItems = dislikedItems,_improvementSuggestions = improvementSuggestions;
  factory _RecommendationFeedback.fromJson(Map<String, dynamic> json) => _$RecommendationFeedbackFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String userId;
@override@JsonKey() final  String recommendationId;
@override@JsonKey() final  int rating;
// 1-5 stars
 final  List<String> _tags;
// 1-5 stars
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

// positive, negative, neutral tags
@override@JsonKey() final  String comment;
 final  List<String> _likedItems;
@override@JsonKey() List<String> get likedItems {
  if (_likedItems is EqualUnmodifiableListView) return _likedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedItems);
}

// specific items in the outfit that were liked
 final  List<String> _dislikedItems;
// specific items in the outfit that were liked
@override@JsonKey() List<String> get dislikedItems {
  if (_dislikedItems is EqualUnmodifiableListView) return _dislikedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dislikedItems);
}

// specific items in the outfit that were disliked
@override@JsonKey() final  bool wouldReuse;
@override@JsonKey() final  bool wouldRecommend;
 final  List<String> _improvementSuggestions;
@override@JsonKey() List<String> get improvementSuggestions {
  if (_improvementSuggestions is EqualUnmodifiableListView) return _improvementSuggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_improvementSuggestions);
}

@override@JsonKey() final  FeedbackCategory category;
@override@JsonKey() final  FeedbackSource source;
@override@JsonKey() final  String dummyField;
// Workaround for DateTime default issue
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of RecommendationFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationFeedbackCopyWith<_RecommendationFeedback> get copyWith => __$RecommendationFeedbackCopyWithImpl<_RecommendationFeedback>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationFeedbackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.recommendationId, recommendationId) || other.recommendationId == recommendationId)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other._likedItems, _likedItems)&&const DeepCollectionEquality().equals(other._dislikedItems, _dislikedItems)&&(identical(other.wouldReuse, wouldReuse) || other.wouldReuse == wouldReuse)&&(identical(other.wouldRecommend, wouldRecommend) || other.wouldRecommend == wouldRecommend)&&const DeepCollectionEquality().equals(other._improvementSuggestions, _improvementSuggestions)&&(identical(other.category, category) || other.category == category)&&(identical(other.source, source) || other.source == source)&&(identical(other.dummyField, dummyField) || other.dummyField == dummyField)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,recommendationId,rating,const DeepCollectionEquality().hash(_tags),comment,const DeepCollectionEquality().hash(_likedItems),const DeepCollectionEquality().hash(_dislikedItems),wouldReuse,wouldRecommend,const DeepCollectionEquality().hash(_improvementSuggestions),category,source,dummyField,createdAt,updatedAt);

@override
String toString() {
  return 'RecommendationFeedback(id: $id, userId: $userId, recommendationId: $recommendationId, rating: $rating, tags: $tags, comment: $comment, likedItems: $likedItems, dislikedItems: $dislikedItems, wouldReuse: $wouldReuse, wouldRecommend: $wouldRecommend, improvementSuggestions: $improvementSuggestions, category: $category, source: $source, dummyField: $dummyField, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RecommendationFeedbackCopyWith<$Res> implements $RecommendationFeedbackCopyWith<$Res> {
  factory _$RecommendationFeedbackCopyWith(_RecommendationFeedback value, $Res Function(_RecommendationFeedback) _then) = __$RecommendationFeedbackCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String recommendationId, int rating, List<String> tags, String comment, List<String> likedItems, List<String> dislikedItems, bool wouldReuse, bool wouldRecommend, List<String> improvementSuggestions, FeedbackCategory category, FeedbackSource source, String dummyField, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$RecommendationFeedbackCopyWithImpl<$Res>
    implements _$RecommendationFeedbackCopyWith<$Res> {
  __$RecommendationFeedbackCopyWithImpl(this._self, this._then);

  final _RecommendationFeedback _self;
  final $Res Function(_RecommendationFeedback) _then;

/// Create a copy of RecommendationFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? recommendationId = null,Object? rating = null,Object? tags = null,Object? comment = null,Object? likedItems = null,Object? dislikedItems = null,Object? wouldReuse = null,Object? wouldRecommend = null,Object? improvementSuggestions = null,Object? category = null,Object? source = null,Object? dummyField = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RecommendationFeedback(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,recommendationId: null == recommendationId ? _self.recommendationId : recommendationId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,likedItems: null == likedItems ? _self._likedItems : likedItems // ignore: cast_nullable_to_non_nullable
as List<String>,dislikedItems: null == dislikedItems ? _self._dislikedItems : dislikedItems // ignore: cast_nullable_to_non_nullable
as List<String>,wouldReuse: null == wouldReuse ? _self.wouldReuse : wouldReuse // ignore: cast_nullable_to_non_nullable
as bool,wouldRecommend: null == wouldRecommend ? _self.wouldRecommend : wouldRecommend // ignore: cast_nullable_to_non_nullable
as bool,improvementSuggestions: null == improvementSuggestions ? _self._improvementSuggestions : improvementSuggestions // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as FeedbackCategory,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FeedbackSource,dummyField: null == dummyField ? _self.dummyField : dummyField // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
