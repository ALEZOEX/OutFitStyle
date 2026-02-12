// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clothing_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClothingItem _$ClothingItemFromJson(Map<String, dynamic> json) {
  return _ClothingItem.fromJson(json);
}

/// @nodoc
mixin _$ClothingItem {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  ClothingCategory get category => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;
  List<ClothingSeason> get seasons => throw _privateConstructorUsedError;
  List<ClothingWeather> get weatherConditions =>
      throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  List<String> get occasions => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  int get timesWorn => throw _privateConstructorUsedError;
  double get comfortRating => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get addedDate => throw _privateConstructorUsedError;
  DateTime? get lastWornDate => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;

  /// Serializes this ClothingItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClothingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClothingItemCopyWith<ClothingItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClothingItemCopyWith<$Res> {
  factory $ClothingItemCopyWith(
          ClothingItem value, $Res Function(ClothingItem) then) =
      _$ClothingItemCopyWithImpl<$Res, ClothingItem>;
  @useResult
  $Res call(
      {int? id,
      String? name,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<String> tags,
      ClothingCategory category,
      String? color,
      String? brand,
      String? material,
      List<ClothingSeason> seasons,
      List<ClothingWeather> weatherConditions,
      bool isFavorite,
      bool isArchived,
      List<String> occasions,
      int usageCount,
      int timesWorn,
      double comfortRating,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? addedDate,
      DateTime? lastWornDate,
      double? price,
      String? size});
}

/// @nodoc
class _$ClothingItemCopyWithImpl<$Res, $Val extends ClothingItem>
    implements $ClothingItemCopyWith<$Res> {
  _$ClothingItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClothingItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? tags = null,
    Object? category = null,
    Object? color = freezed,
    Object? brand = freezed,
    Object? material = freezed,
    Object? seasons = null,
    Object? weatherConditions = null,
    Object? isFavorite = null,
    Object? isArchived = null,
    Object? occasions = null,
    Object? usageCount = null,
    Object? timesWorn = null,
    Object? comfortRating = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? addedDate = freezed,
    Object? lastWornDate = freezed,
    Object? price = freezed,
    Object? size = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ClothingCategory,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      seasons: null == seasons
          ? _value.seasons
          : seasons // ignore: cast_nullable_to_non_nullable
              as List<ClothingSeason>,
      weatherConditions: null == weatherConditions
          ? _value.weatherConditions
          : weatherConditions // ignore: cast_nullable_to_non_nullable
              as List<ClothingWeather>,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      occasions: null == occasions
          ? _value.occasions
          : occasions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      timesWorn: null == timesWorn
          ? _value.timesWorn
          : timesWorn // ignore: cast_nullable_to_non_nullable
              as int,
      comfortRating: null == comfortRating
          ? _value.comfortRating
          : comfortRating // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      addedDate: freezed == addedDate
          ? _value.addedDate
          : addedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastWornDate: freezed == lastWornDate
          ? _value.lastWornDate
          : lastWornDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClothingItemImplCopyWith<$Res>
    implements $ClothingItemCopyWith<$Res> {
  factory _$$ClothingItemImplCopyWith(
          _$ClothingItemImpl value, $Res Function(_$ClothingItemImpl) then) =
      __$$ClothingItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? name,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<String> tags,
      ClothingCategory category,
      String? color,
      String? brand,
      String? material,
      List<ClothingSeason> seasons,
      List<ClothingWeather> weatherConditions,
      bool isFavorite,
      bool isArchived,
      List<String> occasions,
      int usageCount,
      int timesWorn,
      double comfortRating,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? addedDate,
      DateTime? lastWornDate,
      double? price,
      String? size});
}

/// @nodoc
class __$$ClothingItemImplCopyWithImpl<$Res>
    extends _$ClothingItemCopyWithImpl<$Res, _$ClothingItemImpl>
    implements _$$ClothingItemImplCopyWith<$Res> {
  __$$ClothingItemImplCopyWithImpl(
      _$ClothingItemImpl _value, $Res Function(_$ClothingItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClothingItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? tags = null,
    Object? category = null,
    Object? color = freezed,
    Object? brand = freezed,
    Object? material = freezed,
    Object? seasons = null,
    Object? weatherConditions = null,
    Object? isFavorite = null,
    Object? isArchived = null,
    Object? occasions = null,
    Object? usageCount = null,
    Object? timesWorn = null,
    Object? comfortRating = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? addedDate = freezed,
    Object? lastWornDate = freezed,
    Object? price = freezed,
    Object? size = freezed,
  }) {
    return _then(_$ClothingItemImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ClothingCategory,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      seasons: null == seasons
          ? _value._seasons
          : seasons // ignore: cast_nullable_to_non_nullable
              as List<ClothingSeason>,
      weatherConditions: null == weatherConditions
          ? _value._weatherConditions
          : weatherConditions // ignore: cast_nullable_to_non_nullable
              as List<ClothingWeather>,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      occasions: null == occasions
          ? _value._occasions
          : occasions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      timesWorn: null == timesWorn
          ? _value.timesWorn
          : timesWorn // ignore: cast_nullable_to_non_nullable
              as int,
      comfortRating: null == comfortRating
          ? _value.comfortRating
          : comfortRating // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      addedDate: freezed == addedDate
          ? _value.addedDate
          : addedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastWornDate: freezed == lastWornDate
          ? _value.lastWornDate
          : lastWornDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClothingItemImpl implements _ClothingItem {
  const _$ClothingItemImpl(
      {this.id,
      this.name,
      this.description,
      @JsonKey(name: 'image_url') this.imageUrl,
      final List<String> tags = const [],
      this.category = ClothingCategory.tops,
      this.color,
      this.brand,
      this.material,
      final List<ClothingSeason> seasons = const [],
      final List<ClothingWeather> weatherConditions = const [],
      this.isFavorite = false,
      this.isArchived = false,
      final List<String> occasions = const [],
      this.usageCount = 0,
      this.timesWorn = 0,
      this.comfortRating = 0.0,
      this.createdAt,
      this.updatedAt,
      this.addedDate,
      this.lastWornDate,
      this.price,
      this.size})
      : _tags = tags,
        _seasons = seasons,
        _weatherConditions = weatherConditions,
        _occasions = occasions;

  factory _$ClothingItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClothingItemImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final ClothingCategory category;
  @override
  final String? color;
  @override
  final String? brand;
  @override
  final String? material;
  final List<ClothingSeason> _seasons;
  @override
  @JsonKey()
  List<ClothingSeason> get seasons {
    if (_seasons is EqualUnmodifiableListView) return _seasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasons);
  }

  final List<ClothingWeather> _weatherConditions;
  @override
  @JsonKey()
  List<ClothingWeather> get weatherConditions {
    if (_weatherConditions is EqualUnmodifiableListView)
      return _weatherConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weatherConditions);
  }

  @override
  @JsonKey()
  final bool isFavorite;
  @override
  @JsonKey()
  final bool isArchived;
  final List<String> _occasions;
  @override
  @JsonKey()
  List<String> get occasions {
    if (_occasions is EqualUnmodifiableListView) return _occasions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_occasions);
  }

  @override
  @JsonKey()
  final int usageCount;
  @override
  @JsonKey()
  final int timesWorn;
  @override
  @JsonKey()
  final double comfortRating;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? addedDate;
  @override
  final DateTime? lastWornDate;
  @override
  final double? price;
  @override
  final String? size;

  @override
  String toString() {
    return 'ClothingItem(id: $id, name: $name, description: $description, imageUrl: $imageUrl, tags: $tags, category: $category, color: $color, brand: $brand, material: $material, seasons: $seasons, weatherConditions: $weatherConditions, isFavorite: $isFavorite, isArchived: $isArchived, occasions: $occasions, usageCount: $usageCount, timesWorn: $timesWorn, comfortRating: $comfortRating, createdAt: $createdAt, updatedAt: $updatedAt, addedDate: $addedDate, lastWornDate: $lastWornDate, price: $price, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClothingItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.material, material) ||
                other.material == material) &&
            const DeepCollectionEquality().equals(other._seasons, _seasons) &&
            const DeepCollectionEquality()
                .equals(other._weatherConditions, _weatherConditions) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            const DeepCollectionEquality()
                .equals(other._occasions, _occasions) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.timesWorn, timesWorn) ||
                other.timesWorn == timesWorn) &&
            (identical(other.comfortRating, comfortRating) ||
                other.comfortRating == comfortRating) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.addedDate, addedDate) ||
                other.addedDate == addedDate) &&
            (identical(other.lastWornDate, lastWornDate) ||
                other.lastWornDate == lastWornDate) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        imageUrl,
        const DeepCollectionEquality().hash(_tags),
        category,
        color,
        brand,
        material,
        const DeepCollectionEquality().hash(_seasons),
        const DeepCollectionEquality().hash(_weatherConditions),
        isFavorite,
        isArchived,
        const DeepCollectionEquality().hash(_occasions),
        usageCount,
        timesWorn,
        comfortRating,
        createdAt,
        updatedAt,
        addedDate,
        lastWornDate,
        price,
        size
      ]);

  /// Create a copy of ClothingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClothingItemImplCopyWith<_$ClothingItemImpl> get copyWith =>
      __$$ClothingItemImplCopyWithImpl<_$ClothingItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClothingItemImplToJson(
      this,
    );
  }
}

abstract class _ClothingItem implements ClothingItem {
  const factory _ClothingItem(
      {final int? id,
      final String? name,
      final String? description,
      @JsonKey(name: 'image_url') final String? imageUrl,
      final List<String> tags,
      final ClothingCategory category,
      final String? color,
      final String? brand,
      final String? material,
      final List<ClothingSeason> seasons,
      final List<ClothingWeather> weatherConditions,
      final bool isFavorite,
      final bool isArchived,
      final List<String> occasions,
      final int usageCount,
      final int timesWorn,
      final double comfortRating,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final DateTime? addedDate,
      final DateTime? lastWornDate,
      final double? price,
      final String? size}) = _$ClothingItemImpl;

  factory _ClothingItem.fromJson(Map<String, dynamic> json) =
      _$ClothingItemImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  List<String> get tags;
  @override
  ClothingCategory get category;
  @override
  String? get color;
  @override
  String? get brand;
  @override
  String? get material;
  @override
  List<ClothingSeason> get seasons;
  @override
  List<ClothingWeather> get weatherConditions;
  @override
  bool get isFavorite;
  @override
  bool get isArchived;
  @override
  List<String> get occasions;
  @override
  int get usageCount;
  @override
  int get timesWorn;
  @override
  double get comfortRating;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get addedDate;
  @override
  DateTime? get lastWornDate;
  @override
  double? get price;
  @override
  String? get size;

  /// Create a copy of ClothingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClothingItemImplCopyWith<_$ClothingItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
