// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Outfit {

 int? get id; String? get name; String? get description;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'clothing_item_ids') List<int> get clothingItemIds; List<OutfitOccasion> get occasions;@JsonKey(name: 'weather_conditions') List<OutfitWeather> get weatherConditions; List<OutfitSeason> get seasons; List<String> get tags;@JsonKey(name: 'is_favorite') bool get isFavorite;@JsonKey(name: 'created_at') DateTime? get createdAt; int get timesWorn; double get comfortRating; DateTime? get addedDate;
/// Create a copy of Outfit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutfitCopyWith<Outfit> get copyWith => _$OutfitCopyWithImpl<Outfit>(this as Outfit, _$identity);

  /// Serializes this Outfit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Outfit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.clothingItemIds, clothingItemIds)&&const DeepCollectionEquality().equals(other.occasions, occasions)&&const DeepCollectionEquality().equals(other.weatherConditions, weatherConditions)&&const DeepCollectionEquality().equals(other.seasons, seasons)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.timesWorn, timesWorn) || other.timesWorn == timesWorn)&&(identical(other.comfortRating, comfortRating) || other.comfortRating == comfortRating)&&(identical(other.addedDate, addedDate) || other.addedDate == addedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,imageUrl,const DeepCollectionEquality().hash(clothingItemIds),const DeepCollectionEquality().hash(occasions),const DeepCollectionEquality().hash(weatherConditions),const DeepCollectionEquality().hash(seasons),const DeepCollectionEquality().hash(tags),isFavorite,createdAt,timesWorn,comfortRating,addedDate);

@override
String toString() {
  return 'Outfit(id: $id, name: $name, description: $description, imageUrl: $imageUrl, clothingItemIds: $clothingItemIds, occasions: $occasions, weatherConditions: $weatherConditions, seasons: $seasons, tags: $tags, isFavorite: $isFavorite, createdAt: $createdAt, timesWorn: $timesWorn, comfortRating: $comfortRating, addedDate: $addedDate)';
}


}

/// @nodoc
abstract mixin class $OutfitCopyWith<$Res>  {
  factory $OutfitCopyWith(Outfit value, $Res Function(Outfit) _then) = _$OutfitCopyWithImpl;
@useResult
$Res call({
 int? id, String? name, String? description,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'clothing_item_ids') List<int> clothingItemIds, List<OutfitOccasion> occasions,@JsonKey(name: 'weather_conditions') List<OutfitWeather> weatherConditions, List<OutfitSeason> seasons, List<String> tags,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'created_at') DateTime? createdAt, int timesWorn, double comfortRating, DateTime? addedDate
});




}
/// @nodoc
class _$OutfitCopyWithImpl<$Res>
    implements $OutfitCopyWith<$Res> {
  _$OutfitCopyWithImpl(this._self, this._then);

  final Outfit _self;
  final $Res Function(Outfit) _then;

/// Create a copy of Outfit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? clothingItemIds = null,Object? occasions = null,Object? weatherConditions = null,Object? seasons = null,Object? tags = null,Object? isFavorite = null,Object? createdAt = freezed,Object? timesWorn = null,Object? comfortRating = null,Object? addedDate = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,clothingItemIds: null == clothingItemIds ? _self.clothingItemIds : clothingItemIds // ignore: cast_nullable_to_non_nullable
as List<int>,occasions: null == occasions ? _self.occasions : occasions // ignore: cast_nullable_to_non_nullable
as List<OutfitOccasion>,weatherConditions: null == weatherConditions ? _self.weatherConditions : weatherConditions // ignore: cast_nullable_to_non_nullable
as List<OutfitWeather>,seasons: null == seasons ? _self.seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<OutfitSeason>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,timesWorn: null == timesWorn ? _self.timesWorn : timesWorn // ignore: cast_nullable_to_non_nullable
as int,comfortRating: null == comfortRating ? _self.comfortRating : comfortRating // ignore: cast_nullable_to_non_nullable
as double,addedDate: freezed == addedDate ? _self.addedDate : addedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Outfit].
extension OutfitPatterns on Outfit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Outfit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Outfit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Outfit value)  $default,){
final _that = this;
switch (_that) {
case _Outfit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Outfit value)?  $default,){
final _that = this;
switch (_that) {
case _Outfit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? name,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'clothing_item_ids')  List<int> clothingItemIds,  List<OutfitOccasion> occasions, @JsonKey(name: 'weather_conditions')  List<OutfitWeather> weatherConditions,  List<OutfitSeason> seasons,  List<String> tags, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'created_at')  DateTime? createdAt,  int timesWorn,  double comfortRating,  DateTime? addedDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Outfit() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.imageUrl,_that.clothingItemIds,_that.occasions,_that.weatherConditions,_that.seasons,_that.tags,_that.isFavorite,_that.createdAt,_that.timesWorn,_that.comfortRating,_that.addedDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? name,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'clothing_item_ids')  List<int> clothingItemIds,  List<OutfitOccasion> occasions, @JsonKey(name: 'weather_conditions')  List<OutfitWeather> weatherConditions,  List<OutfitSeason> seasons,  List<String> tags, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'created_at')  DateTime? createdAt,  int timesWorn,  double comfortRating,  DateTime? addedDate)  $default,) {final _that = this;
switch (_that) {
case _Outfit():
return $default(_that.id,_that.name,_that.description,_that.imageUrl,_that.clothingItemIds,_that.occasions,_that.weatherConditions,_that.seasons,_that.tags,_that.isFavorite,_that.createdAt,_that.timesWorn,_that.comfortRating,_that.addedDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? name,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'clothing_item_ids')  List<int> clothingItemIds,  List<OutfitOccasion> occasions, @JsonKey(name: 'weather_conditions')  List<OutfitWeather> weatherConditions,  List<OutfitSeason> seasons,  List<String> tags, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'created_at')  DateTime? createdAt,  int timesWorn,  double comfortRating,  DateTime? addedDate)?  $default,) {final _that = this;
switch (_that) {
case _Outfit() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.imageUrl,_that.clothingItemIds,_that.occasions,_that.weatherConditions,_that.seasons,_that.tags,_that.isFavorite,_that.createdAt,_that.timesWorn,_that.comfortRating,_that.addedDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Outfit implements Outfit {
  const _Outfit({this.id, this.name, this.description, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'clothing_item_ids') final  List<int> clothingItemIds = const [], final  List<OutfitOccasion> occasions = const [], @JsonKey(name: 'weather_conditions') final  List<OutfitWeather> weatherConditions = const [], final  List<OutfitSeason> seasons = const [], final  List<String> tags = const [], @JsonKey(name: 'is_favorite') this.isFavorite = false, @JsonKey(name: 'created_at') this.createdAt, this.timesWorn = 0, this.comfortRating = 0.0, this.addedDate}): _clothingItemIds = clothingItemIds,_occasions = occasions,_weatherConditions = weatherConditions,_seasons = seasons,_tags = tags;
  factory _Outfit.fromJson(Map<String, dynamic> json) => _$OutfitFromJson(json);

@override final  int? id;
@override final  String? name;
@override final  String? description;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
 final  List<int> _clothingItemIds;
@override@JsonKey(name: 'clothing_item_ids') List<int> get clothingItemIds {
  if (_clothingItemIds is EqualUnmodifiableListView) return _clothingItemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clothingItemIds);
}

 final  List<OutfitOccasion> _occasions;
@override@JsonKey() List<OutfitOccasion> get occasions {
  if (_occasions is EqualUnmodifiableListView) return _occasions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_occasions);
}

 final  List<OutfitWeather> _weatherConditions;
@override@JsonKey(name: 'weather_conditions') List<OutfitWeather> get weatherConditions {
  if (_weatherConditions is EqualUnmodifiableListView) return _weatherConditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weatherConditions);
}

 final  List<OutfitSeason> _seasons;
@override@JsonKey() List<OutfitSeason> get seasons {
  if (_seasons is EqualUnmodifiableListView) return _seasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seasons);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(name: 'is_favorite') final  bool isFavorite;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey() final  int timesWorn;
@override@JsonKey() final  double comfortRating;
@override final  DateTime? addedDate;

/// Create a copy of Outfit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutfitCopyWith<_Outfit> get copyWith => __$OutfitCopyWithImpl<_Outfit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutfitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Outfit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._clothingItemIds, _clothingItemIds)&&const DeepCollectionEquality().equals(other._occasions, _occasions)&&const DeepCollectionEquality().equals(other._weatherConditions, _weatherConditions)&&const DeepCollectionEquality().equals(other._seasons, _seasons)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.timesWorn, timesWorn) || other.timesWorn == timesWorn)&&(identical(other.comfortRating, comfortRating) || other.comfortRating == comfortRating)&&(identical(other.addedDate, addedDate) || other.addedDate == addedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,imageUrl,const DeepCollectionEquality().hash(_clothingItemIds),const DeepCollectionEquality().hash(_occasions),const DeepCollectionEquality().hash(_weatherConditions),const DeepCollectionEquality().hash(_seasons),const DeepCollectionEquality().hash(_tags),isFavorite,createdAt,timesWorn,comfortRating,addedDate);

@override
String toString() {
  return 'Outfit(id: $id, name: $name, description: $description, imageUrl: $imageUrl, clothingItemIds: $clothingItemIds, occasions: $occasions, weatherConditions: $weatherConditions, seasons: $seasons, tags: $tags, isFavorite: $isFavorite, createdAt: $createdAt, timesWorn: $timesWorn, comfortRating: $comfortRating, addedDate: $addedDate)';
}


}

/// @nodoc
abstract mixin class _$OutfitCopyWith<$Res> implements $OutfitCopyWith<$Res> {
  factory _$OutfitCopyWith(_Outfit value, $Res Function(_Outfit) _then) = __$OutfitCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? name, String? description,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'clothing_item_ids') List<int> clothingItemIds, List<OutfitOccasion> occasions,@JsonKey(name: 'weather_conditions') List<OutfitWeather> weatherConditions, List<OutfitSeason> seasons, List<String> tags,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'created_at') DateTime? createdAt, int timesWorn, double comfortRating, DateTime? addedDate
});




}
/// @nodoc
class __$OutfitCopyWithImpl<$Res>
    implements _$OutfitCopyWith<$Res> {
  __$OutfitCopyWithImpl(this._self, this._then);

  final _Outfit _self;
  final $Res Function(_Outfit) _then;

/// Create a copy of Outfit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? clothingItemIds = null,Object? occasions = null,Object? weatherConditions = null,Object? seasons = null,Object? tags = null,Object? isFavorite = null,Object? createdAt = freezed,Object? timesWorn = null,Object? comfortRating = null,Object? addedDate = freezed,}) {
  return _then(_Outfit(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,clothingItemIds: null == clothingItemIds ? _self._clothingItemIds : clothingItemIds // ignore: cast_nullable_to_non_nullable
as List<int>,occasions: null == occasions ? _self._occasions : occasions // ignore: cast_nullable_to_non_nullable
as List<OutfitOccasion>,weatherConditions: null == weatherConditions ? _self._weatherConditions : weatherConditions // ignore: cast_nullable_to_non_nullable
as List<OutfitWeather>,seasons: null == seasons ? _self._seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<OutfitSeason>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,timesWorn: null == timesWorn ? _self.timesWorn : timesWorn // ignore: cast_nullable_to_non_nullable
as int,comfortRating: null == comfortRating ? _self.comfortRating : comfortRating // ignore: cast_nullable_to_non_nullable
as double,addedDate: freezed == addedDate ? _self.addedDate : addedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
