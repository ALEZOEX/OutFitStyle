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

/// Уникальный идентификатор
 String? get id;/// Название предмета (например, "Белая футболка Basic")
 String? get name;/// Категория: top, bottom, shoes, outerwear, accessories, headwear
@JsonKey(name: 'category') String? get category;/// Подкатегория: tshirt, jeans, sneakers и т.д.
@JsonKey(name: 'subcategory') String? get subcategory;/// Бренд
 String? get brand;/// Цвет
 String? get color;/// Размер (S, M, L, XL, 42, 44 и т.д.)
 String? get size;/// URL изображения
 String? get imageUrl;/// Emoji иконка для предмета
 String? get iconEmoji;/// BlurHash для плейсхолдера изображения
 String? get blurHash;/// Минимальная температура для носки (°C)
@JsonKey(name: 'min_temp') double? get minTemp;/// Максимальная температура для носки (°C)
@JsonKey(name: 'max_temp') double? get maxTemp;/// Уровень теплоты (1-5, где 5 - самый теплый)
@JsonKey(name: 'warmth_level') int? get warmthLevel;/// Подходит для дождя
@JsonKey(name: 'rain_ok') bool? get rainOk;/// Подходит для снега
@JsonKey(name: 'snow_ok') bool? get snowOk;/// Подходит для ветреной погоды
@JsonKey(name: 'wind_ok') bool? get windOk;/// Количество использований
 int? get usage;/// Материалы (например, ["cotton", "polyester"])
 List<String>? get materials;/// Пол: unisex, male, female
 String? get gender;/// Крой: slim, regular, loose, oversized
 String? get fit;/// Узор: solid, striped, checked, printed
 String? get pattern;/// Локальный путь к изображению
 String? get localImagePath;/// Стиль: casual, formal, sport, streetwear
 String? get style;/// Избранное
@JsonKey(name: 'is_favorite') bool? get isFavorite;/// Архивировано
@JsonKey(name: 'is_archived') bool? get isArchived;/// Сезон: all_season, spring, summer, autumn, winter
 String? get season;/// ID на сервере
@JsonKey(name: 'server_id') String? get serverId;/// Есть ли несохраненные изменения
 bool? get dirty;/// Дата последней синхронизации
@JsonKey(name: 'last_synced_at') DateTime? get lastSyncedAt;
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
 String? id, String? name,@JsonKey(name: 'category') String? category,@JsonKey(name: 'subcategory') String? subcategory, String? brand, String? color, String? size, String? imageUrl, String? iconEmoji, String? blurHash,@JsonKey(name: 'min_temp') double? minTemp,@JsonKey(name: 'max_temp') double? maxTemp,@JsonKey(name: 'warmth_level') int? warmthLevel,@JsonKey(name: 'rain_ok') bool? rainOk,@JsonKey(name: 'snow_ok') bool? snowOk,@JsonKey(name: 'wind_ok') bool? windOk, int? usage, List<String>? materials, String? gender, String? fit, String? pattern, String? localImagePath, String? style,@JsonKey(name: 'is_favorite') bool? isFavorite,@JsonKey(name: 'is_archived') bool? isArchived, String? season,@JsonKey(name: 'server_id') String? serverId, bool? dirty,@JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name, @JsonKey(name: 'category')  String? category, @JsonKey(name: 'subcategory')  String? subcategory,  String? brand,  String? color,  String? size,  String? imageUrl,  String? iconEmoji,  String? blurHash, @JsonKey(name: 'min_temp')  double? minTemp, @JsonKey(name: 'max_temp')  double? maxTemp, @JsonKey(name: 'warmth_level')  int? warmthLevel, @JsonKey(name: 'rain_ok')  bool? rainOk, @JsonKey(name: 'snow_ok')  bool? snowOk, @JsonKey(name: 'wind_ok')  bool? windOk,  int? usage,  List<String>? materials,  String? gender,  String? fit,  String? pattern,  String? localImagePath,  String? style, @JsonKey(name: 'is_favorite')  bool? isFavorite, @JsonKey(name: 'is_archived')  bool? isArchived,  String? season, @JsonKey(name: 'server_id')  String? serverId,  bool? dirty, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name, @JsonKey(name: 'category')  String? category, @JsonKey(name: 'subcategory')  String? subcategory,  String? brand,  String? color,  String? size,  String? imageUrl,  String? iconEmoji,  String? blurHash, @JsonKey(name: 'min_temp')  double? minTemp, @JsonKey(name: 'max_temp')  double? maxTemp, @JsonKey(name: 'warmth_level')  int? warmthLevel, @JsonKey(name: 'rain_ok')  bool? rainOk, @JsonKey(name: 'snow_ok')  bool? snowOk, @JsonKey(name: 'wind_ok')  bool? windOk,  int? usage,  List<String>? materials,  String? gender,  String? fit,  String? pattern,  String? localImagePath,  String? style, @JsonKey(name: 'is_favorite')  bool? isFavorite, @JsonKey(name: 'is_archived')  bool? isArchived,  String? season, @JsonKey(name: 'server_id')  String? serverId,  bool? dirty, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name, @JsonKey(name: 'category')  String? category, @JsonKey(name: 'subcategory')  String? subcategory,  String? brand,  String? color,  String? size,  String? imageUrl,  String? iconEmoji,  String? blurHash, @JsonKey(name: 'min_temp')  double? minTemp, @JsonKey(name: 'max_temp')  double? maxTemp, @JsonKey(name: 'warmth_level')  int? warmthLevel, @JsonKey(name: 'rain_ok')  bool? rainOk, @JsonKey(name: 'snow_ok')  bool? snowOk, @JsonKey(name: 'wind_ok')  bool? windOk,  int? usage,  List<String>? materials,  String? gender,  String? fit,  String? pattern,  String? localImagePath,  String? style, @JsonKey(name: 'is_favorite')  bool? isFavorite, @JsonKey(name: 'is_archived')  bool? isArchived,  String? season, @JsonKey(name: 'server_id')  String? serverId,  bool? dirty, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt)?  $default,) {final _that = this;
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
  const _WardrobeItem({this.id, this.name, @JsonKey(name: 'category') this.category, @JsonKey(name: 'subcategory') this.subcategory, this.brand, this.color, this.size, this.imageUrl, this.iconEmoji, this.blurHash, @JsonKey(name: 'min_temp') this.minTemp, @JsonKey(name: 'max_temp') this.maxTemp, @JsonKey(name: 'warmth_level') this.warmthLevel, @JsonKey(name: 'rain_ok') this.rainOk, @JsonKey(name: 'snow_ok') this.snowOk, @JsonKey(name: 'wind_ok') this.windOk, this.usage, final  List<String>? materials, this.gender, this.fit, this.pattern, this.localImagePath, this.style, @JsonKey(name: 'is_favorite') this.isFavorite, @JsonKey(name: 'is_archived') this.isArchived, this.season, @JsonKey(name: 'server_id') this.serverId, this.dirty, @JsonKey(name: 'last_synced_at') this.lastSyncedAt}): _materials = materials;
  factory _WardrobeItem.fromJson(Map<String, dynamic> json) => _$WardrobeItemFromJson(json);

/// Уникальный идентификатор
@override final  String? id;
/// Название предмета (например, "Белая футболка Basic")
@override final  String? name;
/// Категория: top, bottom, shoes, outerwear, accessories, headwear
@override@JsonKey(name: 'category') final  String? category;
/// Подкатегория: tshirt, jeans, sneakers и т.д.
@override@JsonKey(name: 'subcategory') final  String? subcategory;
/// Бренд
@override final  String? brand;
/// Цвет
@override final  String? color;
/// Размер (S, M, L, XL, 42, 44 и т.д.)
@override final  String? size;
/// URL изображения
@override final  String? imageUrl;
/// Emoji иконка для предмета
@override final  String? iconEmoji;
/// BlurHash для плейсхолдера изображения
@override final  String? blurHash;
/// Минимальная температура для носки (°C)
@override@JsonKey(name: 'min_temp') final  double? minTemp;
/// Максимальная температура для носки (°C)
@override@JsonKey(name: 'max_temp') final  double? maxTemp;
/// Уровень теплоты (1-5, где 5 - самый теплый)
@override@JsonKey(name: 'warmth_level') final  int? warmthLevel;
/// Подходит для дождя
@override@JsonKey(name: 'rain_ok') final  bool? rainOk;
/// Подходит для снега
@override@JsonKey(name: 'snow_ok') final  bool? snowOk;
/// Подходит для ветреной погоды
@override@JsonKey(name: 'wind_ok') final  bool? windOk;
/// Количество использований
@override final  int? usage;
/// Материалы (например, ["cotton", "polyester"])
 final  List<String>? _materials;
/// Материалы (например, ["cotton", "polyester"])
@override List<String>? get materials {
  final value = _materials;
  if (value == null) return null;
  if (_materials is EqualUnmodifiableListView) return _materials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Пол: unisex, male, female
@override final  String? gender;
/// Крой: slim, regular, loose, oversized
@override final  String? fit;
/// Узор: solid, striped, checked, printed
@override final  String? pattern;
/// Локальный путь к изображению
@override final  String? localImagePath;
/// Стиль: casual, formal, sport, streetwear
@override final  String? style;
/// Избранное
@override@JsonKey(name: 'is_favorite') final  bool? isFavorite;
/// Архивировано
@override@JsonKey(name: 'is_archived') final  bool? isArchived;
/// Сезон: all_season, spring, summer, autumn, winter
@override final  String? season;
/// ID на сервере
@override@JsonKey(name: 'server_id') final  String? serverId;
/// Есть ли несохраненные изменения
@override final  bool? dirty;
/// Дата последней синхронизации
@override@JsonKey(name: 'last_synced_at') final  DateTime? lastSyncedAt;

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
 String? id, String? name,@JsonKey(name: 'category') String? category,@JsonKey(name: 'subcategory') String? subcategory, String? brand, String? color, String? size, String? imageUrl, String? iconEmoji, String? blurHash,@JsonKey(name: 'min_temp') double? minTemp,@JsonKey(name: 'max_temp') double? maxTemp,@JsonKey(name: 'warmth_level') int? warmthLevel,@JsonKey(name: 'rain_ok') bool? rainOk,@JsonKey(name: 'snow_ok') bool? snowOk,@JsonKey(name: 'wind_ok') bool? windOk, int? usage, List<String>? materials, String? gender, String? fit, String? pattern, String? localImagePath, String? style,@JsonKey(name: 'is_favorite') bool? isFavorite,@JsonKey(name: 'is_archived') bool? isArchived, String? season,@JsonKey(name: 'server_id') String? serverId, bool? dirty,@JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt
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
