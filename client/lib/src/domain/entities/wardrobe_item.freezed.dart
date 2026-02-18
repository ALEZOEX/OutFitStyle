// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wardrobe_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WardrobeItem {

 String? get id; String? get name; String? get category; String? get subcategory; String? get brand; String? get color; String? get size; String? get imageUrl; String? get iconEmoji; String? get blurHash; double? get minTemp; double? get maxTemp; int? get warmthLevel; bool? get rainOk; bool? get snowOk; bool? get windOk; int? get usage; List<String>? get materials; String? get gender; String? get fit; String? get pattern; String? get localImagePath; String? get style; bool? get isFavorite; bool? get isArchived; String? get season; String? get serverId; bool? get dirty; DateTime? get lastSyncedAt;
/// Create a copy of WardrobeItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WardrobeItemCopyWith<WardrobeItem> get copyWith => _$WardrobeItemCopyWithImpl<WardrobeItem>(this as WardrobeItem, _$identity);

  /// Serializes this WardrobeItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WardrobeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.color, color) || other.color == color)&&(identical(other.size, size) || other.size == size)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.iconEmoji, iconEmoji) || other.iconEmoji == iconEmoji)&&(identical(other.blurHash, blurHash) || other.blurHash == blurHash)&&(identical(other.minTemp, minTemp) || other.minTemp == minTemp)&&(identical(other.maxTemp, maxTemp) || other.maxTemp == maxTemp)&&(identical(other.warmthLevel, warmthLevel) || other.warmthLevel == warmthLevel)&&(identical(other.rainOk, rainOk) || other.rainOk == rainOk)&&(identical(other.snowOk, snowOk) || other.snowOk == snowOk)&&(identical(other.windOk, windOk) || other.windOk == windOk)&&(identical(other.usage, usage) || other.usage == usage)&&const DeepCollectionEquality().equals(other.materials, materials)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.fit, fit) || other.fit == fit)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.localImagePath, localImagePath) || other.localImagePath == localImagePath)&&(identical(other.style, style) || other.style == style)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.season, season) || other.season == season)&&(identical(other.serverId, serverId) || other.serverId == serverId)&&(identical(other.dirty, dirty) || other.dirty == dirty)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,category,subcategory,brand,color,size,imageUrl,iconEmoji,blurHash,minTemp,maxTemp,warmthLevel,rainOk,snowOk,windOk,usage,const DeepCollectionEquality().hash(materials),gender,fit,pattern,localImagePath,style,isFavorite,isArchived,season,serverId,dirty,lastSyncedAt]);

@override
String toString() {
  return 'WardrobeItem(id: $id, name: $name, category: $category, subcategory: $subcategory, brand: $brand, color: $color, size: $size, imageUrl: $imageUrl, iconEmoji: $iconEmoji, blurHash: $blurHash, minTemp: $minTemp, maxTemp: $maxTemp, warmthLevel: $warmthLevel, rainOk: $rainOk, snowOk: $snowOk, windOk: $windOk, usage: $usage, materials: $materials, gender: $gender, fit: $fit, pattern: $pattern, localImagePath: $localImagePath, style: $style, isFavorite: $isFavorite, isArchived: $isArchived, season: $season, serverId: $serverId, dirty: $dirty, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $WardrobeItemCopyWith<$Res>  {
  factory $WardrobeItemCopyWith(WardrobeItem value, $Res Function(WardrobeItem) _then) = _$WardrobeItemCopyWithImpl;
@useResult
$Res call({
 String? id, String? name, String? category, String? subcategory, String? brand, String? color, String? size, String? imageUrl, String? iconEmoji, String? blurHash, double? minTemp, double? maxTemp, int? warmthLevel, bool? rainOk, bool? snowOk, bool? windOk, int? usage, List<String>? materials, String? gender, String? fit, String? pattern, String? localImagePath, String? style, bool? isFavorite, bool? isArchived, String? season, String? serverId, bool? dirty, DateTime? lastSyncedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? category = freezed,Object? subcategory = freezed,Object? brand = freezed,Object? color = freezed,Object? size = freezed,Object? imageUrl = freezed,Object? iconEmoji = freezed,Object? blurHash = freezed,Object? minTemp = freezed,Object? maxTemp = freezed,Object? warmthLevel = freezed,Object? rainOk = freezed,Object? snowOk = freezed,Object? windOk = freezed,Object? usage = freezed,Object? materials = freezed,Object? gender = freezed,Object? fit = freezed,Object? pattern = freezed,Object? localImagePath = freezed,Object? style = freezed,Object? isFavorite = freezed,Object? isArchived = freezed,Object? season = freezed,Object? serverId = freezed,Object? dirty = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,iconEmoji: freezed == iconEmoji ? _self.iconEmoji : iconEmoji // ignore: cast_nullable_to_non_nullable
as String?,blurHash: freezed == blurHash ? _self.blurHash : blurHash // ignore: cast_nullable_to_non_nullable
as String?,minTemp: freezed == minTemp ? _self.minTemp : minTemp // ignore: cast_nullable_to_non_nullable
as double?,maxTemp: freezed == maxTemp ? _self.maxTemp : maxTemp // ignore: cast_nullable_to_non_nullable
as double?,warmthLevel: freezed == warmthLevel ? _self.warmthLevel : warmthLevel // ignore: cast_nullable_to_non_nullable
as int?,rainOk: freezed == rainOk ? _self.rainOk : rainOk // ignore: cast_nullable_to_non_nullable
as bool?,snowOk: freezed == snowOk ? _self.snowOk : snowOk // ignore: cast_nullable_to_non_nullable
as bool?,windOk: freezed == windOk ? _self.windOk : windOk // ignore: cast_nullable_to_non_nullable
as bool?,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as int?,materials: freezed == materials ? _self.materials : materials // ignore: cast_nullable_to_non_nullable
as List<String>?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,fit: freezed == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,localImagePath: freezed == localImagePath ? _self.localImagePath : localImagePath // ignore: cast_nullable_to_non_nullable
as String?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: freezed == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool?,isArchived: freezed == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool?,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as String?,serverId: freezed == serverId ? _self.serverId : serverId // ignore: cast_nullable_to_non_nullable
as String?,dirty: freezed == dirty ? _self.dirty : dirty // ignore: cast_nullable_to_non_nullable
as bool?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name,  String? category,  String? subcategory,  String? brand,  String? color,  String? size,  String? imageUrl,  String? iconEmoji,  String? blurHash,  double? minTemp,  double? maxTemp,  int? warmthLevel,  bool? rainOk,  bool? snowOk,  bool? windOk,  int? usage,  List<String>? materials,  String? gender,  String? fit,  String? pattern,  String? localImagePath,  String? style,  bool? isFavorite,  bool? isArchived,  String? season,  String? serverId,  bool? dirty,  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WardrobeItem() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.subcategory,_that.brand,_that.color,_that.size,_that.imageUrl,_that.iconEmoji,_that.blurHash,_that.minTemp,_that.maxTemp,_that.warmthLevel,_that.rainOk,_that.snowOk,_that.windOk,_that.usage,_that.materials,_that.gender,_that.fit,_that.pattern,_that.localImagePath,_that.style,_that.isFavorite,_that.isArchived,_that.season,_that.serverId,_that.dirty,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name,  String? category,  String? subcategory,  String? brand,  String? color,  String? size,  String? imageUrl,  String? iconEmoji,  String? blurHash,  double? minTemp,  double? maxTemp,  int? warmthLevel,  bool? rainOk,  bool? snowOk,  bool? windOk,  int? usage,  List<String>? materials,  String? gender,  String? fit,  String? pattern,  String? localImagePath,  String? style,  bool? isFavorite,  bool? isArchived,  String? season,  String? serverId,  bool? dirty,  DateTime? lastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _WardrobeItem():
return $default(_that.id,_that.name,_that.category,_that.subcategory,_that.brand,_that.color,_that.size,_that.imageUrl,_that.iconEmoji,_that.blurHash,_that.minTemp,_that.maxTemp,_that.warmthLevel,_that.rainOk,_that.snowOk,_that.windOk,_that.usage,_that.materials,_that.gender,_that.fit,_that.pattern,_that.localImagePath,_that.style,_that.isFavorite,_that.isArchived,_that.season,_that.serverId,_that.dirty,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name,  String? category,  String? subcategory,  String? brand,  String? color,  String? size,  String? imageUrl,  String? iconEmoji,  String? blurHash,  double? minTemp,  double? maxTemp,  int? warmthLevel,  bool? rainOk,  bool? snowOk,  bool? windOk,  int? usage,  List<String>? materials,  String? gender,  String? fit,  String? pattern,  String? localImagePath,  String? style,  bool? isFavorite,  bool? isArchived,  String? season,  String? serverId,  bool? dirty,  DateTime? lastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _WardrobeItem() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.subcategory,_that.brand,_that.color,_that.size,_that.imageUrl,_that.iconEmoji,_that.blurHash,_that.minTemp,_that.maxTemp,_that.warmthLevel,_that.rainOk,_that.snowOk,_that.windOk,_that.usage,_that.materials,_that.gender,_that.fit,_that.pattern,_that.localImagePath,_that.style,_that.isFavorite,_that.isArchived,_that.season,_that.serverId,_that.dirty,_that.lastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WardrobeItem implements WardrobeItem {
  const _WardrobeItem({this.id, this.name, this.category, this.subcategory, this.brand, this.color, this.size, this.imageUrl, this.iconEmoji, this.blurHash, this.minTemp, this.maxTemp, this.warmthLevel, this.rainOk, this.snowOk, this.windOk, this.usage, final  List<String>? materials, this.gender, this.fit, this.pattern, this.localImagePath, this.style, this.isFavorite, this.isArchived, this.season, this.serverId, this.dirty, this.lastSyncedAt}): _materials = materials;
  factory _WardrobeItem.fromJson(Map<String, dynamic> json) => _$WardrobeItemFromJson(json);

@override final  String? id;
@override final  String? name;
@override final  String? category;
@override final  String? subcategory;
@override final  String? brand;
@override final  String? color;
@override final  String? size;
@override final  String? imageUrl;
@override final  String? iconEmoji;
@override final  String? blurHash;
@override final  double? minTemp;
@override final  double? maxTemp;
@override final  int? warmthLevel;
@override final  bool? rainOk;
@override final  bool? snowOk;
@override final  bool? windOk;
@override final  int? usage;
 final  List<String>? _materials;
@override List<String>? get materials {
  final value = _materials;
  if (value == null) return null;
  if (_materials is EqualUnmodifiableListView) return _materials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? gender;
@override final  String? fit;
@override final  String? pattern;
@override final  String? localImagePath;
@override final  String? style;
@override final  bool? isFavorite;
@override final  bool? isArchived;
@override final  String? season;
@override final  String? serverId;
@override final  bool? dirty;
@override final  DateTime? lastSyncedAt;

/// Create a copy of WardrobeItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WardrobeItemCopyWith<_WardrobeItem> get copyWith => __$WardrobeItemCopyWithImpl<_WardrobeItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WardrobeItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WardrobeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.color, color) || other.color == color)&&(identical(other.size, size) || other.size == size)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.iconEmoji, iconEmoji) || other.iconEmoji == iconEmoji)&&(identical(other.blurHash, blurHash) || other.blurHash == blurHash)&&(identical(other.minTemp, minTemp) || other.minTemp == minTemp)&&(identical(other.maxTemp, maxTemp) || other.maxTemp == maxTemp)&&(identical(other.warmthLevel, warmthLevel) || other.warmthLevel == warmthLevel)&&(identical(other.rainOk, rainOk) || other.rainOk == rainOk)&&(identical(other.snowOk, snowOk) || other.snowOk == snowOk)&&(identical(other.windOk, windOk) || other.windOk == windOk)&&(identical(other.usage, usage) || other.usage == usage)&&const DeepCollectionEquality().equals(other._materials, _materials)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.fit, fit) || other.fit == fit)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.localImagePath, localImagePath) || other.localImagePath == localImagePath)&&(identical(other.style, style) || other.style == style)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.season, season) || other.season == season)&&(identical(other.serverId, serverId) || other.serverId == serverId)&&(identical(other.dirty, dirty) || other.dirty == dirty)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,category,subcategory,brand,color,size,imageUrl,iconEmoji,blurHash,minTemp,maxTemp,warmthLevel,rainOk,snowOk,windOk,usage,const DeepCollectionEquality().hash(_materials),gender,fit,pattern,localImagePath,style,isFavorite,isArchived,season,serverId,dirty,lastSyncedAt]);

@override
String toString() {
  return 'WardrobeItem(id: $id, name: $name, category: $category, subcategory: $subcategory, brand: $brand, color: $color, size: $size, imageUrl: $imageUrl, iconEmoji: $iconEmoji, blurHash: $blurHash, minTemp: $minTemp, maxTemp: $maxTemp, warmthLevel: $warmthLevel, rainOk: $rainOk, snowOk: $snowOk, windOk: $windOk, usage: $usage, materials: $materials, gender: $gender, fit: $fit, pattern: $pattern, localImagePath: $localImagePath, style: $style, isFavorite: $isFavorite, isArchived: $isArchived, season: $season, serverId: $serverId, dirty: $dirty, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$WardrobeItemCopyWith<$Res> implements $WardrobeItemCopyWith<$Res> {
  factory _$WardrobeItemCopyWith(_WardrobeItem value, $Res Function(_WardrobeItem) _then) = __$WardrobeItemCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name, String? category, String? subcategory, String? brand, String? color, String? size, String? imageUrl, String? iconEmoji, String? blurHash, double? minTemp, double? maxTemp, int? warmthLevel, bool? rainOk, bool? snowOk, bool? windOk, int? usage, List<String>? materials, String? gender, String? fit, String? pattern, String? localImagePath, String? style, bool? isFavorite, bool? isArchived, String? season, String? serverId, bool? dirty, DateTime? lastSyncedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? category = freezed,Object? subcategory = freezed,Object? brand = freezed,Object? color = freezed,Object? size = freezed,Object? imageUrl = freezed,Object? iconEmoji = freezed,Object? blurHash = freezed,Object? minTemp = freezed,Object? maxTemp = freezed,Object? warmthLevel = freezed,Object? rainOk = freezed,Object? snowOk = freezed,Object? windOk = freezed,Object? usage = freezed,Object? materials = freezed,Object? gender = freezed,Object? fit = freezed,Object? pattern = freezed,Object? localImagePath = freezed,Object? style = freezed,Object? isFavorite = freezed,Object? isArchived = freezed,Object? season = freezed,Object? serverId = freezed,Object? dirty = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_WardrobeItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,iconEmoji: freezed == iconEmoji ? _self.iconEmoji : iconEmoji // ignore: cast_nullable_to_non_nullable
as String?,blurHash: freezed == blurHash ? _self.blurHash : blurHash // ignore: cast_nullable_to_non_nullable
as String?,minTemp: freezed == minTemp ? _self.minTemp : minTemp // ignore: cast_nullable_to_non_nullable
as double?,maxTemp: freezed == maxTemp ? _self.maxTemp : maxTemp // ignore: cast_nullable_to_non_nullable
as double?,warmthLevel: freezed == warmthLevel ? _self.warmthLevel : warmthLevel // ignore: cast_nullable_to_non_nullable
as int?,rainOk: freezed == rainOk ? _self.rainOk : rainOk // ignore: cast_nullable_to_non_nullable
as bool?,snowOk: freezed == snowOk ? _self.snowOk : snowOk // ignore: cast_nullable_to_non_nullable
as bool?,windOk: freezed == windOk ? _self.windOk : windOk // ignore: cast_nullable_to_non_nullable
as bool?,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as int?,materials: freezed == materials ? _self._materials : materials // ignore: cast_nullable_to_non_nullable
as List<String>?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,fit: freezed == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,localImagePath: freezed == localImagePath ? _self.localImagePath : localImagePath // ignore: cast_nullable_to_non_nullable
as String?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: freezed == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool?,isArchived: freezed == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool?,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as String?,serverId: freezed == serverId ? _self.serverId : serverId // ignore: cast_nullable_to_non_nullable
as String?,dirty: freezed == dirty ? _self.dirty : dirty // ignore: cast_nullable_to_non_nullable
as bool?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
