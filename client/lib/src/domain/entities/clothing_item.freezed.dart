// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clothing_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClothingItem {

 int? get id; String? get name; String? get description;@JsonKey(name: 'image_url') String? get imageUrl; List<String> get tags; ClothingCategory get category; String? get color; String? get brand; String? get material; List<ClothingSeason> get seasons; List<ClothingWeather> get weatherConditions; bool get isFavorite; bool get isArchived; List<String> get occasions; int get usageCount; int get timesWorn; double get comfortRating; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get addedDate; DateTime? get lastWornDate; double? get price; String? get size;
/// Create a copy of ClothingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClothingItemCopyWith<ClothingItem> get copyWith => _$ClothingItemCopyWithImpl<ClothingItem>(this as ClothingItem, _$identity);

  /// Serializes this ClothingItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClothingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.category, category) || other.category == category)&&(identical(other.color, color) || other.color == color)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.material, material) || other.material == material)&&const DeepCollectionEquality().equals(other.seasons, seasons)&&const DeepCollectionEquality().equals(other.weatherConditions, weatherConditions)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&const DeepCollectionEquality().equals(other.occasions, occasions)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.timesWorn, timesWorn) || other.timesWorn == timesWorn)&&(identical(other.comfortRating, comfortRating) || other.comfortRating == comfortRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.addedDate, addedDate) || other.addedDate == addedDate)&&(identical(other.lastWornDate, lastWornDate) || other.lastWornDate == lastWornDate)&&(identical(other.price, price) || other.price == price)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,imageUrl,const DeepCollectionEquality().hash(tags),category,color,brand,material,const DeepCollectionEquality().hash(seasons),const DeepCollectionEquality().hash(weatherConditions),isFavorite,isArchived,const DeepCollectionEquality().hash(occasions),usageCount,timesWorn,comfortRating,createdAt,updatedAt,addedDate,lastWornDate,price,size]);

@override
String toString() {
  return 'ClothingItem(id: $id, name: $name, description: $description, imageUrl: $imageUrl, tags: $tags, category: $category, color: $color, brand: $brand, material: $material, seasons: $seasons, weatherConditions: $weatherConditions, isFavorite: $isFavorite, isArchived: $isArchived, occasions: $occasions, usageCount: $usageCount, timesWorn: $timesWorn, comfortRating: $comfortRating, createdAt: $createdAt, updatedAt: $updatedAt, addedDate: $addedDate, lastWornDate: $lastWornDate, price: $price, size: $size)';
}


}

/// @nodoc
abstract mixin class $ClothingItemCopyWith<$Res>  {
  factory $ClothingItemCopyWith(ClothingItem value, $Res Function(ClothingItem) _then) = _$ClothingItemCopyWithImpl;
@useResult
$Res call({
 int? id, String? name, String? description,@JsonKey(name: 'image_url') String? imageUrl, List<String> tags, ClothingCategory category, String? color, String? brand, String? material, List<ClothingSeason> seasons, List<ClothingWeather> weatherConditions, bool isFavorite, bool isArchived, List<String> occasions, int usageCount, int timesWorn, double comfortRating, DateTime? createdAt, DateTime? updatedAt, DateTime? addedDate, DateTime? lastWornDate, double? price, String? size
});




}
/// @nodoc
class _$ClothingItemCopyWithImpl<$Res>
    implements $ClothingItemCopyWith<$Res> {
  _$ClothingItemCopyWithImpl(this._self, this._then);

  final ClothingItem _self;
  final $Res Function(ClothingItem) _then;

/// Create a copy of ClothingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? tags = null,Object? category = null,Object? color = freezed,Object? brand = freezed,Object? material = freezed,Object? seasons = null,Object? weatherConditions = null,Object? isFavorite = null,Object? isArchived = null,Object? occasions = null,Object? usageCount = null,Object? timesWorn = null,Object? comfortRating = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? addedDate = freezed,Object? lastWornDate = freezed,Object? price = freezed,Object? size = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ClothingCategory,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,seasons: null == seasons ? _self.seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<ClothingSeason>,weatherConditions: null == weatherConditions ? _self.weatherConditions : weatherConditions // ignore: cast_nullable_to_non_nullable
as List<ClothingWeather>,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,occasions: null == occasions ? _self.occasions : occasions // ignore: cast_nullable_to_non_nullable
as List<String>,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,timesWorn: null == timesWorn ? _self.timesWorn : timesWorn // ignore: cast_nullable_to_non_nullable
as int,comfortRating: null == comfortRating ? _self.comfortRating : comfortRating // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,addedDate: freezed == addedDate ? _self.addedDate : addedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastWornDate: freezed == lastWornDate ? _self.lastWornDate : lastWornDate // ignore: cast_nullable_to_non_nullable
as DateTime?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClothingItem].
extension ClothingItemPatterns on ClothingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClothingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClothingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClothingItem value)  $default,){
final _that = this;
switch (_that) {
case _ClothingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClothingItem value)?  $default,){
final _that = this;
switch (_that) {
case _ClothingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? name,  String? description, @JsonKey(name: 'image_url')  String? imageUrl,  List<String> tags,  ClothingCategory category,  String? color,  String? brand,  String? material,  List<ClothingSeason> seasons,  List<ClothingWeather> weatherConditions,  bool isFavorite,  bool isArchived,  List<String> occasions,  int usageCount,  int timesWorn,  double comfortRating,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? addedDate,  DateTime? lastWornDate,  double? price,  String? size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClothingItem() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.imageUrl,_that.tags,_that.category,_that.color,_that.brand,_that.material,_that.seasons,_that.weatherConditions,_that.isFavorite,_that.isArchived,_that.occasions,_that.usageCount,_that.timesWorn,_that.comfortRating,_that.createdAt,_that.updatedAt,_that.addedDate,_that.lastWornDate,_that.price,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? name,  String? description, @JsonKey(name: 'image_url')  String? imageUrl,  List<String> tags,  ClothingCategory category,  String? color,  String? brand,  String? material,  List<ClothingSeason> seasons,  List<ClothingWeather> weatherConditions,  bool isFavorite,  bool isArchived,  List<String> occasions,  int usageCount,  int timesWorn,  double comfortRating,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? addedDate,  DateTime? lastWornDate,  double? price,  String? size)  $default,) {final _that = this;
switch (_that) {
case _ClothingItem():
return $default(_that.id,_that.name,_that.description,_that.imageUrl,_that.tags,_that.category,_that.color,_that.brand,_that.material,_that.seasons,_that.weatherConditions,_that.isFavorite,_that.isArchived,_that.occasions,_that.usageCount,_that.timesWorn,_that.comfortRating,_that.createdAt,_that.updatedAt,_that.addedDate,_that.lastWornDate,_that.price,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? name,  String? description, @JsonKey(name: 'image_url')  String? imageUrl,  List<String> tags,  ClothingCategory category,  String? color,  String? brand,  String? material,  List<ClothingSeason> seasons,  List<ClothingWeather> weatherConditions,  bool isFavorite,  bool isArchived,  List<String> occasions,  int usageCount,  int timesWorn,  double comfortRating,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? addedDate,  DateTime? lastWornDate,  double? price,  String? size)?  $default,) {final _that = this;
switch (_that) {
case _ClothingItem() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.imageUrl,_that.tags,_that.category,_that.color,_that.brand,_that.material,_that.seasons,_that.weatherConditions,_that.isFavorite,_that.isArchived,_that.occasions,_that.usageCount,_that.timesWorn,_that.comfortRating,_that.createdAt,_that.updatedAt,_that.addedDate,_that.lastWornDate,_that.price,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClothingItem implements ClothingItem {
  const _ClothingItem({this.id, this.name, this.description, @JsonKey(name: 'image_url') this.imageUrl, final  List<String> tags = const [], this.category = ClothingCategory.tops, this.color, this.brand, this.material, final  List<ClothingSeason> seasons = const [], final  List<ClothingWeather> weatherConditions = const [], this.isFavorite = false, this.isArchived = false, final  List<String> occasions = const [], this.usageCount = 0, this.timesWorn = 0, this.comfortRating = 0.0, this.createdAt, this.updatedAt, this.addedDate, this.lastWornDate, this.price, this.size}): _tags = tags,_seasons = seasons,_weatherConditions = weatherConditions,_occasions = occasions;
  factory _ClothingItem.fromJson(Map<String, dynamic> json) => _$ClothingItemFromJson(json);

@override final  int? id;
@override final  String? name;
@override final  String? description;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  ClothingCategory category;
@override final  String? color;
@override final  String? brand;
@override final  String? material;
 final  List<ClothingSeason> _seasons;
@override@JsonKey() List<ClothingSeason> get seasons {
  if (_seasons is EqualUnmodifiableListView) return _seasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seasons);
}

 final  List<ClothingWeather> _weatherConditions;
@override@JsonKey() List<ClothingWeather> get weatherConditions {
  if (_weatherConditions is EqualUnmodifiableListView) return _weatherConditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weatherConditions);
}

@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  bool isArchived;
 final  List<String> _occasions;
@override@JsonKey() List<String> get occasions {
  if (_occasions is EqualUnmodifiableListView) return _occasions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_occasions);
}

@override@JsonKey() final  int usageCount;
@override@JsonKey() final  int timesWorn;
@override@JsonKey() final  double comfortRating;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? addedDate;
@override final  DateTime? lastWornDate;
@override final  double? price;
@override final  String? size;

/// Create a copy of ClothingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClothingItemCopyWith<_ClothingItem> get copyWith => __$ClothingItemCopyWithImpl<_ClothingItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClothingItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClothingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.category, category) || other.category == category)&&(identical(other.color, color) || other.color == color)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.material, material) || other.material == material)&&const DeepCollectionEquality().equals(other._seasons, _seasons)&&const DeepCollectionEquality().equals(other._weatherConditions, _weatherConditions)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&const DeepCollectionEquality().equals(other._occasions, _occasions)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.timesWorn, timesWorn) || other.timesWorn == timesWorn)&&(identical(other.comfortRating, comfortRating) || other.comfortRating == comfortRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.addedDate, addedDate) || other.addedDate == addedDate)&&(identical(other.lastWornDate, lastWornDate) || other.lastWornDate == lastWornDate)&&(identical(other.price, price) || other.price == price)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,imageUrl,const DeepCollectionEquality().hash(_tags),category,color,brand,material,const DeepCollectionEquality().hash(_seasons),const DeepCollectionEquality().hash(_weatherConditions),isFavorite,isArchived,const DeepCollectionEquality().hash(_occasions),usageCount,timesWorn,comfortRating,createdAt,updatedAt,addedDate,lastWornDate,price,size]);

@override
String toString() {
  return 'ClothingItem(id: $id, name: $name, description: $description, imageUrl: $imageUrl, tags: $tags, category: $category, color: $color, brand: $brand, material: $material, seasons: $seasons, weatherConditions: $weatherConditions, isFavorite: $isFavorite, isArchived: $isArchived, occasions: $occasions, usageCount: $usageCount, timesWorn: $timesWorn, comfortRating: $comfortRating, createdAt: $createdAt, updatedAt: $updatedAt, addedDate: $addedDate, lastWornDate: $lastWornDate, price: $price, size: $size)';
}


}

/// @nodoc
abstract mixin class _$ClothingItemCopyWith<$Res> implements $ClothingItemCopyWith<$Res> {
  factory _$ClothingItemCopyWith(_ClothingItem value, $Res Function(_ClothingItem) _then) = __$ClothingItemCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? name, String? description,@JsonKey(name: 'image_url') String? imageUrl, List<String> tags, ClothingCategory category, String? color, String? brand, String? material, List<ClothingSeason> seasons, List<ClothingWeather> weatherConditions, bool isFavorite, bool isArchived, List<String> occasions, int usageCount, int timesWorn, double comfortRating, DateTime? createdAt, DateTime? updatedAt, DateTime? addedDate, DateTime? lastWornDate, double? price, String? size
});




}
/// @nodoc
class __$ClothingItemCopyWithImpl<$Res>
    implements _$ClothingItemCopyWith<$Res> {
  __$ClothingItemCopyWithImpl(this._self, this._then);

  final _ClothingItem _self;
  final $Res Function(_ClothingItem) _then;

/// Create a copy of ClothingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? tags = null,Object? category = null,Object? color = freezed,Object? brand = freezed,Object? material = freezed,Object? seasons = null,Object? weatherConditions = null,Object? isFavorite = null,Object? isArchived = null,Object? occasions = null,Object? usageCount = null,Object? timesWorn = null,Object? comfortRating = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? addedDate = freezed,Object? lastWornDate = freezed,Object? price = freezed,Object? size = freezed,}) {
  return _then(_ClothingItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ClothingCategory,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,seasons: null == seasons ? _self._seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<ClothingSeason>,weatherConditions: null == weatherConditions ? _self._weatherConditions : weatherConditions // ignore: cast_nullable_to_non_nullable
as List<ClothingWeather>,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,occasions: null == occasions ? _self._occasions : occasions // ignore: cast_nullable_to_non_nullable
as List<String>,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,timesWorn: null == timesWorn ? _self.timesWorn : timesWorn // ignore: cast_nullable_to_non_nullable
as int,comfortRating: null == comfortRating ? _self.comfortRating : comfortRating // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,addedDate: freezed == addedDate ? _self.addedDate : addedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastWornDate: freezed == lastWornDate ? _self.lastWornDate : lastWornDate // ignore: cast_nullable_to_non_nullable
as DateTime?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
