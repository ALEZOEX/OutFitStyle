// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OutfitItem {

 int? get id; int? get outfitId; int? get clothingItemId; ClothingItem? get clothingItem; int get sortOrder; bool get isPrimary; Map<String, dynamic> get metadata;
/// Create a copy of OutfitItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutfitItemCopyWith<OutfitItem> get copyWith => _$OutfitItemCopyWithImpl<OutfitItem>(this as OutfitItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutfitItem&&(identical(other.id, id) || other.id == id)&&(identical(other.outfitId, outfitId) || other.outfitId == outfitId)&&(identical(other.clothingItemId, clothingItemId) || other.clothingItemId == clothingItemId)&&(identical(other.clothingItem, clothingItem) || other.clothingItem == clothingItem)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,outfitId,clothingItemId,clothingItem,sortOrder,isPrimary,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'OutfitItem(id: $id, outfitId: $outfitId, clothingItemId: $clothingItemId, clothingItem: $clothingItem, sortOrder: $sortOrder, isPrimary: $isPrimary, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $OutfitItemCopyWith<$Res>  {
  factory $OutfitItemCopyWith(OutfitItem value, $Res Function(OutfitItem) _then) = _$OutfitItemCopyWithImpl;
@useResult
$Res call({
 int? id, int? outfitId, int? clothingItemId, ClothingItem? clothingItem, int sortOrder, bool isPrimary, Map<String, dynamic> metadata
});


$ClothingItemCopyWith<$Res>? get clothingItem;

}
/// @nodoc
class _$OutfitItemCopyWithImpl<$Res>
    implements $OutfitItemCopyWith<$Res> {
  _$OutfitItemCopyWithImpl(this._self, this._then);

  final OutfitItem _self;
  final $Res Function(OutfitItem) _then;

/// Create a copy of OutfitItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? outfitId = freezed,Object? clothingItemId = freezed,Object? clothingItem = freezed,Object? sortOrder = null,Object? isPrimary = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,outfitId: freezed == outfitId ? _self.outfitId : outfitId // ignore: cast_nullable_to_non_nullable
as int?,clothingItemId: freezed == clothingItemId ? _self.clothingItemId : clothingItemId // ignore: cast_nullable_to_non_nullable
as int?,clothingItem: freezed == clothingItem ? _self.clothingItem : clothingItem // ignore: cast_nullable_to_non_nullable
as ClothingItem?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}
/// Create a copy of OutfitItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClothingItemCopyWith<$Res>? get clothingItem {
    if (_self.clothingItem == null) {
    return null;
  }

  return $ClothingItemCopyWith<$Res>(_self.clothingItem!, (value) {
    return _then(_self.copyWith(clothingItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [OutfitItem].
extension OutfitItemPatterns on OutfitItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutfitItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutfitItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutfitItem value)  $default,){
final _that = this;
switch (_that) {
case _OutfitItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutfitItem value)?  $default,){
final _that = this;
switch (_that) {
case _OutfitItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? outfitId,  int? clothingItemId,  ClothingItem? clothingItem,  int sortOrder,  bool isPrimary,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutfitItem() when $default != null:
return $default(_that.id,_that.outfitId,_that.clothingItemId,_that.clothingItem,_that.sortOrder,_that.isPrimary,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? outfitId,  int? clothingItemId,  ClothingItem? clothingItem,  int sortOrder,  bool isPrimary,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _OutfitItem():
return $default(_that.id,_that.outfitId,_that.clothingItemId,_that.clothingItem,_that.sortOrder,_that.isPrimary,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? outfitId,  int? clothingItemId,  ClothingItem? clothingItem,  int sortOrder,  bool isPrimary,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _OutfitItem() when $default != null:
return $default(_that.id,_that.outfitId,_that.clothingItemId,_that.clothingItem,_that.sortOrder,_that.isPrimary,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc


class _OutfitItem implements OutfitItem {
  const _OutfitItem({this.id, this.outfitId, this.clothingItemId, this.clothingItem, this.sortOrder = 0, this.isPrimary = false, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata;
  

@override final  int? id;
@override final  int? outfitId;
@override final  int? clothingItemId;
@override final  ClothingItem? clothingItem;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool isPrimary;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of OutfitItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutfitItemCopyWith<_OutfitItem> get copyWith => __$OutfitItemCopyWithImpl<_OutfitItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutfitItem&&(identical(other.id, id) || other.id == id)&&(identical(other.outfitId, outfitId) || other.outfitId == outfitId)&&(identical(other.clothingItemId, clothingItemId) || other.clothingItemId == clothingItemId)&&(identical(other.clothingItem, clothingItem) || other.clothingItem == clothingItem)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,outfitId,clothingItemId,clothingItem,sortOrder,isPrimary,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'OutfitItem(id: $id, outfitId: $outfitId, clothingItemId: $clothingItemId, clothingItem: $clothingItem, sortOrder: $sortOrder, isPrimary: $isPrimary, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$OutfitItemCopyWith<$Res> implements $OutfitItemCopyWith<$Res> {
  factory _$OutfitItemCopyWith(_OutfitItem value, $Res Function(_OutfitItem) _then) = __$OutfitItemCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? outfitId, int? clothingItemId, ClothingItem? clothingItem, int sortOrder, bool isPrimary, Map<String, dynamic> metadata
});


@override $ClothingItemCopyWith<$Res>? get clothingItem;

}
/// @nodoc
class __$OutfitItemCopyWithImpl<$Res>
    implements _$OutfitItemCopyWith<$Res> {
  __$OutfitItemCopyWithImpl(this._self, this._then);

  final _OutfitItem _self;
  final $Res Function(_OutfitItem) _then;

/// Create a copy of OutfitItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? outfitId = freezed,Object? clothingItemId = freezed,Object? clothingItem = freezed,Object? sortOrder = null,Object? isPrimary = null,Object? metadata = null,}) {
  return _then(_OutfitItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,outfitId: freezed == outfitId ? _self.outfitId : outfitId // ignore: cast_nullable_to_non_nullable
as int?,clothingItemId: freezed == clothingItemId ? _self.clothingItemId : clothingItemId // ignore: cast_nullable_to_non_nullable
as int?,clothingItem: freezed == clothingItem ? _self.clothingItem : clothingItem // ignore: cast_nullable_to_non_nullable
as ClothingItem?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

/// Create a copy of OutfitItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClothingItemCopyWith<$Res>? get clothingItem {
    if (_self.clothingItem == null) {
    return null;
  }

  return $ClothingItemCopyWith<$Res>(_self.clothingItem!, (value) {
    return _then(_self.copyWith(clothingItem: value));
  });
}
}

// dart format on
