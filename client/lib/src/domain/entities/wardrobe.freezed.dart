// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wardrobe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WardrobeItem {

 String get id; String get userId; String get name; String get category; String get subcategory; String get brand; String get color; String get size; String get material; String get season; String get weatherCondition; double get temperatureMin; double get temperatureMax; String get imageUrl; bool get isFavorite; bool get isArchived; DateTime get addedAt; DateTime get updatedAt; Map<String, dynamic>? get metadata;
/// Create a copy of WardrobeItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WardrobeItemCopyWith<WardrobeItem> get copyWith => _$WardrobeItemCopyWithImpl<WardrobeItem>(this as WardrobeItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WardrobeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.color, color) || other.color == color)&&(identical(other.size, size) || other.size == size)&&(identical(other.material, material) || other.material == material)&&(identical(other.season, season) || other.season == season)&&(identical(other.weatherCondition, weatherCondition) || other.weatherCondition == weatherCondition)&&(identical(other.temperatureMin, temperatureMin) || other.temperatureMin == temperatureMin)&&(identical(other.temperatureMax, temperatureMax) || other.temperatureMax == temperatureMax)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,category,subcategory,brand,color,size,material,season,weatherCondition,temperatureMin,temperatureMax,imageUrl,isFavorite,isArchived,addedAt,updatedAt,const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'WardrobeItem(id: $id, userId: $userId, name: $name, category: $category, subcategory: $subcategory, brand: $brand, color: $color, size: $size, material: $material, season: $season, weatherCondition: $weatherCondition, temperatureMin: $temperatureMin, temperatureMax: $temperatureMax, imageUrl: $imageUrl, isFavorite: $isFavorite, isArchived: $isArchived, addedAt: $addedAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $WardrobeItemCopyWith<$Res>  {
  factory $WardrobeItemCopyWith(WardrobeItem value, $Res Function(WardrobeItem) _then) = _$WardrobeItemCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String category, String subcategory, String brand, String color, String size, String material, String season, String weatherCondition, double temperatureMin, double temperatureMax, String imageUrl, bool isFavorite, bool isArchived, DateTime addedAt, DateTime updatedAt, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$WardrobeItemCopyWithImpl<$Res>
    implements $WardrobeItemCopyWith<$Res> {
  _$WardrobeItemCopyWithImpl(this._self, this._then);

  final WardrobeItem _self;
  final $Res Function(WardrobeItem) _then;

/// Create a copy of WardrobeItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? category = null,Object? subcategory = null,Object? brand = null,Object? color = null,Object? size = null,Object? material = null,Object? season = null,Object? weatherCondition = null,Object? temperatureMin = null,Object? temperatureMax = null,Object? imageUrl = null,Object? isFavorite = null,Object? isArchived = null,Object? addedAt = null,Object? updatedAt = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: null == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,material: null == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String,season: null == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as String,weatherCondition: null == weatherCondition ? _self.weatherCondition : weatherCondition // ignore: cast_nullable_to_non_nullable
as String,temperatureMin: null == temperatureMin ? _self.temperatureMin : temperatureMin // ignore: cast_nullable_to_non_nullable
as double,temperatureMax: null == temperatureMax ? _self.temperatureMax : temperatureMax // ignore: cast_nullable_to_non_nullable
as double,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [WardrobeItem].
extension WardrobeItemPatterns on WardrobeItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WardrobeItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WardrobeItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WardrobeItem value)  $default,){
final _that = this;
switch (_that) {
case _WardrobeItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WardrobeItem value)?  $default,){
final _that = this;
switch (_that) {
case _WardrobeItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String category,  String subcategory,  String brand,  String color,  String size,  String material,  String season,  String weatherCondition,  double temperatureMin,  double temperatureMax,  String imageUrl,  bool isFavorite,  bool isArchived,  DateTime addedAt,  DateTime updatedAt,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WardrobeItem() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.category,_that.subcategory,_that.brand,_that.color,_that.size,_that.material,_that.season,_that.weatherCondition,_that.temperatureMin,_that.temperatureMax,_that.imageUrl,_that.isFavorite,_that.isArchived,_that.addedAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String category,  String subcategory,  String brand,  String color,  String size,  String material,  String season,  String weatherCondition,  double temperatureMin,  double temperatureMax,  String imageUrl,  bool isFavorite,  bool isArchived,  DateTime addedAt,  DateTime updatedAt,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _WardrobeItem():
return $default(_that.id,_that.userId,_that.name,_that.category,_that.subcategory,_that.brand,_that.color,_that.size,_that.material,_that.season,_that.weatherCondition,_that.temperatureMin,_that.temperatureMax,_that.imageUrl,_that.isFavorite,_that.isArchived,_that.addedAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String category,  String subcategory,  String brand,  String color,  String size,  String material,  String season,  String weatherCondition,  double temperatureMin,  double temperatureMax,  String imageUrl,  bool isFavorite,  bool isArchived,  DateTime addedAt,  DateTime updatedAt,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _WardrobeItem() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.category,_that.subcategory,_that.brand,_that.color,_that.size,_that.material,_that.season,_that.weatherCondition,_that.temperatureMin,_that.temperatureMax,_that.imageUrl,_that.isFavorite,_that.isArchived,_that.addedAt,_that.updatedAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc


class _WardrobeItem implements WardrobeItem {
  const _WardrobeItem({required this.id, required this.userId, required this.name, required this.category, required this.subcategory, required this.brand, required this.color, required this.size, required this.material, required this.season, required this.weatherCondition, required this.temperatureMin, required this.temperatureMax, required this.imageUrl, required this.isFavorite, required this.isArchived, required this.addedAt, required this.updatedAt, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String category;
@override final  String subcategory;
@override final  String brand;
@override final  String color;
@override final  String size;
@override final  String material;
@override final  String season;
@override final  String weatherCondition;
@override final  double temperatureMin;
@override final  double temperatureMax;
@override final  String imageUrl;
@override final  bool isFavorite;
@override final  bool isArchived;
@override final  DateTime addedAt;
@override final  DateTime updatedAt;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of WardrobeItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WardrobeItemCopyWith<_WardrobeItem> get copyWith => __$WardrobeItemCopyWithImpl<_WardrobeItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WardrobeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.color, color) || other.color == color)&&(identical(other.size, size) || other.size == size)&&(identical(other.material, material) || other.material == material)&&(identical(other.season, season) || other.season == season)&&(identical(other.weatherCondition, weatherCondition) || other.weatherCondition == weatherCondition)&&(identical(other.temperatureMin, temperatureMin) || other.temperatureMin == temperatureMin)&&(identical(other.temperatureMax, temperatureMax) || other.temperatureMax == temperatureMax)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,category,subcategory,brand,color,size,material,season,weatherCondition,temperatureMin,temperatureMax,imageUrl,isFavorite,isArchived,addedAt,updatedAt,const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'WardrobeItem(id: $id, userId: $userId, name: $name, category: $category, subcategory: $subcategory, brand: $brand, color: $color, size: $size, material: $material, season: $season, weatherCondition: $weatherCondition, temperatureMin: $temperatureMin, temperatureMax: $temperatureMax, imageUrl: $imageUrl, isFavorite: $isFavorite, isArchived: $isArchived, addedAt: $addedAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$WardrobeItemCopyWith<$Res> implements $WardrobeItemCopyWith<$Res> {
  factory _$WardrobeItemCopyWith(_WardrobeItem value, $Res Function(_WardrobeItem) _then) = __$WardrobeItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String category, String subcategory, String brand, String color, String size, String material, String season, String weatherCondition, double temperatureMin, double temperatureMax, String imageUrl, bool isFavorite, bool isArchived, DateTime addedAt, DateTime updatedAt, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$WardrobeItemCopyWithImpl<$Res>
    implements _$WardrobeItemCopyWith<$Res> {
  __$WardrobeItemCopyWithImpl(this._self, this._then);

  final _WardrobeItem _self;
  final $Res Function(_WardrobeItem) _then;

/// Create a copy of WardrobeItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? category = null,Object? subcategory = null,Object? brand = null,Object? color = null,Object? size = null,Object? material = null,Object? season = null,Object? weatherCondition = null,Object? temperatureMin = null,Object? temperatureMax = null,Object? imageUrl = null,Object? isFavorite = null,Object? isArchived = null,Object? addedAt = null,Object? updatedAt = null,Object? metadata = freezed,}) {
  return _then(_WardrobeItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: null == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,material: null == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String,season: null == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as String,weatherCondition: null == weatherCondition ? _self.weatherCondition : weatherCondition // ignore: cast_nullable_to_non_nullable
as String,temperatureMin: null == temperatureMin ? _self.temperatureMin : temperatureMin // ignore: cast_nullable_to_non_nullable
as double,temperatureMax: null == temperatureMax ? _self.temperatureMax : temperatureMax // ignore: cast_nullable_to_non_nullable
as double,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
