// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutfitRecommendation {

 String? get id; String? get title; String? get description; String? get imageUrl; List<String>? get recommendedItems; double? get temperature; String? get weatherCondition; DateTime? get createdAt;
/// Create a copy of OutfitRecommendation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutfitRecommendationCopyWith<OutfitRecommendation> get copyWith => _$OutfitRecommendationCopyWithImpl<OutfitRecommendation>(this as OutfitRecommendation, _$identity);

  /// Serializes this OutfitRecommendation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutfitRecommendation&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.recommendedItems, recommendedItems)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.weatherCondition, weatherCondition) || other.weatherCondition == weatherCondition)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,imageUrl,const DeepCollectionEquality().hash(recommendedItems),temperature,weatherCondition,createdAt);

@override
String toString() {
  return 'OutfitRecommendation(id: $id, title: $title, description: $description, imageUrl: $imageUrl, recommendedItems: $recommendedItems, temperature: $temperature, weatherCondition: $weatherCondition, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OutfitRecommendationCopyWith<$Res>  {
  factory $OutfitRecommendationCopyWith(OutfitRecommendation value, $Res Function(OutfitRecommendation) _then) = _$OutfitRecommendationCopyWithImpl;
@useResult
$Res call({
 String? id, String? title, String? description, String? imageUrl, List<String>? recommendedItems, double? temperature, String? weatherCondition, DateTime? createdAt
});




}
/// @nodoc
class _$OutfitRecommendationCopyWithImpl<$Res>
    implements $OutfitRecommendationCopyWith<$Res> {
  _$OutfitRecommendationCopyWithImpl(this._self, this._then);

  final OutfitRecommendation _self;
  final $Res Function(OutfitRecommendation) _then;

/// Create a copy of OutfitRecommendation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? recommendedItems = freezed,Object? temperature = freezed,Object? weatherCondition = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,recommendedItems: freezed == recommendedItems ? _self.recommendedItems : recommendedItems // ignore: cast_nullable_to_non_nullable
as List<String>?,temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,weatherCondition: freezed == weatherCondition ? _self.weatherCondition : weatherCondition // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OutfitRecommendation].
extension OutfitRecommendationPatterns on OutfitRecommendation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutfitRecommendation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutfitRecommendation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutfitRecommendation value)  $default,){
final _that = this;
switch (_that) {
case _OutfitRecommendation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutfitRecommendation value)?  $default,){
final _that = this;
switch (_that) {
case _OutfitRecommendation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? title,  String? description,  String? imageUrl,  List<String>? recommendedItems,  double? temperature,  String? weatherCondition,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutfitRecommendation() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.imageUrl,_that.recommendedItems,_that.temperature,_that.weatherCondition,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? title,  String? description,  String? imageUrl,  List<String>? recommendedItems,  double? temperature,  String? weatherCondition,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _OutfitRecommendation():
return $default(_that.id,_that.title,_that.description,_that.imageUrl,_that.recommendedItems,_that.temperature,_that.weatherCondition,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? title,  String? description,  String? imageUrl,  List<String>? recommendedItems,  double? temperature,  String? weatherCondition,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OutfitRecommendation() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.imageUrl,_that.recommendedItems,_that.temperature,_that.weatherCondition,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutfitRecommendation implements OutfitRecommendation {
  const _OutfitRecommendation({this.id, this.title, this.description, this.imageUrl, final  List<String>? recommendedItems, this.temperature, this.weatherCondition, this.createdAt}): _recommendedItems = recommendedItems;
  factory _OutfitRecommendation.fromJson(Map<String, dynamic> json) => _$OutfitRecommendationFromJson(json);

@override final  String? id;
@override final  String? title;
@override final  String? description;
@override final  String? imageUrl;
 final  List<String>? _recommendedItems;
@override List<String>? get recommendedItems {
  final value = _recommendedItems;
  if (value == null) return null;
  if (_recommendedItems is EqualUnmodifiableListView) return _recommendedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  double? temperature;
@override final  String? weatherCondition;
@override final  DateTime? createdAt;

/// Create a copy of OutfitRecommendation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutfitRecommendationCopyWith<_OutfitRecommendation> get copyWith => __$OutfitRecommendationCopyWithImpl<_OutfitRecommendation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutfitRecommendationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutfitRecommendation&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._recommendedItems, _recommendedItems)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.weatherCondition, weatherCondition) || other.weatherCondition == weatherCondition)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,imageUrl,const DeepCollectionEquality().hash(_recommendedItems),temperature,weatherCondition,createdAt);

@override
String toString() {
  return 'OutfitRecommendation(id: $id, title: $title, description: $description, imageUrl: $imageUrl, recommendedItems: $recommendedItems, temperature: $temperature, weatherCondition: $weatherCondition, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OutfitRecommendationCopyWith<$Res> implements $OutfitRecommendationCopyWith<$Res> {
  factory _$OutfitRecommendationCopyWith(_OutfitRecommendation value, $Res Function(_OutfitRecommendation) _then) = __$OutfitRecommendationCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? title, String? description, String? imageUrl, List<String>? recommendedItems, double? temperature, String? weatherCondition, DateTime? createdAt
});




}
/// @nodoc
class __$OutfitRecommendationCopyWithImpl<$Res>
    implements _$OutfitRecommendationCopyWith<$Res> {
  __$OutfitRecommendationCopyWithImpl(this._self, this._then);

  final _OutfitRecommendation _self;
  final $Res Function(_OutfitRecommendation) _then;

/// Create a copy of OutfitRecommendation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? recommendedItems = freezed,Object? temperature = freezed,Object? weatherCondition = freezed,Object? createdAt = freezed,}) {
  return _then(_OutfitRecommendation(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,recommendedItems: freezed == recommendedItems ? _self._recommendedItems : recommendedItems // ignore: cast_nullable_to_non_nullable
as List<String>?,temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,weatherCondition: freezed == weatherCondition ? _self.weatherCondition : weatherCondition // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
