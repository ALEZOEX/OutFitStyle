// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OutfitItem {
  int? get id => throw _privateConstructorUsedError;
  int? get outfitId => throw _privateConstructorUsedError;
  int? get clothingItemId => throw _privateConstructorUsedError;
  ClothingItem? get clothingItem => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isPrimary => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutfitItemCopyWith<OutfitItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitItemCopyWith<$Res> {
  factory $OutfitItemCopyWith(
          OutfitItem value, $Res Function(OutfitItem) then) =
      _$OutfitItemCopyWithImpl<$Res, OutfitItem>;
  @useResult
  $Res call(
      {int? id,
      int? outfitId,
      int? clothingItemId,
      ClothingItem? clothingItem,
      int sortOrder,
      bool isPrimary,
      Map<String, dynamic> metadata});

  $ClothingItemCopyWith<$Res>? get clothingItem;
}

/// @nodoc
class _$OutfitItemCopyWithImpl<$Res, $Val extends OutfitItem>
    implements $OutfitItemCopyWith<$Res> {
  _$OutfitItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? outfitId = freezed,
    Object? clothingItemId = freezed,
    Object? clothingItem = freezed,
    Object? sortOrder = null,
    Object? isPrimary = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      outfitId: freezed == outfitId
          ? _value.outfitId
          : outfitId // ignore: cast_nullable_to_non_nullable
              as int?,
      clothingItemId: freezed == clothingItemId
          ? _value.clothingItemId
          : clothingItemId // ignore: cast_nullable_to_non_nullable
              as int?,
      clothingItem: freezed == clothingItem
          ? _value.clothingItem
          : clothingItem // ignore: cast_nullable_to_non_nullable
              as ClothingItem?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClothingItemCopyWith<$Res>? get clothingItem {
    if (_value.clothingItem == null) {
      return null;
    }

    return $ClothingItemCopyWith<$Res>(_value.clothingItem!, (value) {
      return _then(_value.copyWith(clothingItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OutfitItemImplCopyWith<$Res>
    implements $OutfitItemCopyWith<$Res> {
  factory _$$OutfitItemImplCopyWith(
          _$OutfitItemImpl value, $Res Function(_$OutfitItemImpl) then) =
      __$$OutfitItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int? outfitId,
      int? clothingItemId,
      ClothingItem? clothingItem,
      int sortOrder,
      bool isPrimary,
      Map<String, dynamic> metadata});

  @override
  $ClothingItemCopyWith<$Res>? get clothingItem;
}

/// @nodoc
class __$$OutfitItemImplCopyWithImpl<$Res>
    extends _$OutfitItemCopyWithImpl<$Res, _$OutfitItemImpl>
    implements _$$OutfitItemImplCopyWith<$Res> {
  __$$OutfitItemImplCopyWithImpl(
      _$OutfitItemImpl _value, $Res Function(_$OutfitItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? outfitId = freezed,
    Object? clothingItemId = freezed,
    Object? clothingItem = freezed,
    Object? sortOrder = null,
    Object? isPrimary = null,
    Object? metadata = null,
  }) {
    return _then(_$OutfitItemImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      outfitId: freezed == outfitId
          ? _value.outfitId
          : outfitId // ignore: cast_nullable_to_non_nullable
              as int?,
      clothingItemId: freezed == clothingItemId
          ? _value.clothingItemId
          : clothingItemId // ignore: cast_nullable_to_non_nullable
              as int?,
      clothingItem: freezed == clothingItem
          ? _value.clothingItem
          : clothingItem // ignore: cast_nullable_to_non_nullable
              as ClothingItem?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$OutfitItemImpl implements _OutfitItem {
  const _$OutfitItemImpl(
      {this.id,
      this.outfitId,
      this.clothingItemId,
      this.clothingItem,
      this.sortOrder = 0,
      this.isPrimary = false,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  @override
  final int? id;
  @override
  final int? outfitId;
  @override
  final int? clothingItemId;
  @override
  final ClothingItem? clothingItem;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isPrimary;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'OutfitItem(id: $id, outfitId: $outfitId, clothingItemId: $clothingItemId, clothingItem: $clothingItem, sortOrder: $sortOrder, isPrimary: $isPrimary, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.outfitId, outfitId) ||
                other.outfitId == outfitId) &&
            (identical(other.clothingItemId, clothingItemId) ||
                other.clothingItemId == clothingItemId) &&
            (identical(other.clothingItem, clothingItem) ||
                other.clothingItem == clothingItem) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      outfitId,
      clothingItemId,
      clothingItem,
      sortOrder,
      isPrimary,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitItemImplCopyWith<_$OutfitItemImpl> get copyWith =>
      __$$OutfitItemImplCopyWithImpl<_$OutfitItemImpl>(this, _$identity);
}

abstract class _OutfitItem implements OutfitItem {
  const factory _OutfitItem(
      {final int? id,
      final int? outfitId,
      final int? clothingItemId,
      final ClothingItem? clothingItem,
      final int sortOrder,
      final bool isPrimary,
      final Map<String, dynamic> metadata}) = _$OutfitItemImpl;

  @override
  int? get id;
  @override
  int? get outfitId;
  @override
  int? get clothingItemId;
  @override
  ClothingItem? get clothingItem;
  @override
  int get sortOrder;
  @override
  bool get isPrimary;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutfitItemImplCopyWith<_$OutfitItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
