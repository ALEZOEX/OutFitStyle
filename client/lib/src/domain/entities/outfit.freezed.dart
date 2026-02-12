// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Outfit _$OutfitFromJson(Map<String, dynamic> json) {
  return _Outfit.fromJson(json);
}

/// @nodoc
mixin _$Outfit {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'clothing_item_ids')
  List<int> get clothingItemIds => throw _privateConstructorUsedError;
  List<OutfitOccasion> get occasions => throw _privateConstructorUsedError;
  @JsonKey(name: 'weather_conditions')
  List<OutfitWeather> get weatherConditions =>
      throw _privateConstructorUsedError;
  List<OutfitSeason> get seasons => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_favorite')
  bool get isFavorite => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  int get timesWorn => throw _privateConstructorUsedError;
  double get comfortRating => throw _privateConstructorUsedError;
  DateTime? get addedDate => throw _privateConstructorUsedError;

  /// Serializes this Outfit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Outfit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutfitCopyWith<Outfit> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitCopyWith<$Res> {
  factory $OutfitCopyWith(Outfit value, $Res Function(Outfit) then) =
      _$OutfitCopyWithImpl<$Res, Outfit>;
  @useResult
  $Res call(
      {int? id,
      String? name,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'clothing_item_ids') List<int> clothingItemIds,
      List<OutfitOccasion> occasions,
      @JsonKey(name: 'weather_conditions')
      List<OutfitWeather> weatherConditions,
      List<OutfitSeason> seasons,
      List<String> tags,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      int timesWorn,
      double comfortRating,
      DateTime? addedDate});
}

/// @nodoc
class _$OutfitCopyWithImpl<$Res, $Val extends Outfit>
    implements $OutfitCopyWith<$Res> {
  _$OutfitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Outfit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? clothingItemIds = null,
    Object? occasions = null,
    Object? weatherConditions = null,
    Object? seasons = null,
    Object? tags = null,
    Object? isFavorite = null,
    Object? createdAt = freezed,
    Object? timesWorn = null,
    Object? comfortRating = null,
    Object? addedDate = freezed,
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
      clothingItemIds: null == clothingItemIds
          ? _value.clothingItemIds
          : clothingItemIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      occasions: null == occasions
          ? _value.occasions
          : occasions // ignore: cast_nullable_to_non_nullable
              as List<OutfitOccasion>,
      weatherConditions: null == weatherConditions
          ? _value.weatherConditions
          : weatherConditions // ignore: cast_nullable_to_non_nullable
              as List<OutfitWeather>,
      seasons: null == seasons
          ? _value.seasons
          : seasons // ignore: cast_nullable_to_non_nullable
              as List<OutfitSeason>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timesWorn: null == timesWorn
          ? _value.timesWorn
          : timesWorn // ignore: cast_nullable_to_non_nullable
              as int,
      comfortRating: null == comfortRating
          ? _value.comfortRating
          : comfortRating // ignore: cast_nullable_to_non_nullable
              as double,
      addedDate: freezed == addedDate
          ? _value.addedDate
          : addedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutfitImplCopyWith<$Res> implements $OutfitCopyWith<$Res> {
  factory _$$OutfitImplCopyWith(
          _$OutfitImpl value, $Res Function(_$OutfitImpl) then) =
      __$$OutfitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? name,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'clothing_item_ids') List<int> clothingItemIds,
      List<OutfitOccasion> occasions,
      @JsonKey(name: 'weather_conditions')
      List<OutfitWeather> weatherConditions,
      List<OutfitSeason> seasons,
      List<String> tags,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      int timesWorn,
      double comfortRating,
      DateTime? addedDate});
}

/// @nodoc
class __$$OutfitImplCopyWithImpl<$Res>
    extends _$OutfitCopyWithImpl<$Res, _$OutfitImpl>
    implements _$$OutfitImplCopyWith<$Res> {
  __$$OutfitImplCopyWithImpl(
      _$OutfitImpl _value, $Res Function(_$OutfitImpl) _then)
      : super(_value, _then);

  /// Create a copy of Outfit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? clothingItemIds = null,
    Object? occasions = null,
    Object? weatherConditions = null,
    Object? seasons = null,
    Object? tags = null,
    Object? isFavorite = null,
    Object? createdAt = freezed,
    Object? timesWorn = null,
    Object? comfortRating = null,
    Object? addedDate = freezed,
  }) {
    return _then(_$OutfitImpl(
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
      clothingItemIds: null == clothingItemIds
          ? _value._clothingItemIds
          : clothingItemIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      occasions: null == occasions
          ? _value._occasions
          : occasions // ignore: cast_nullable_to_non_nullable
              as List<OutfitOccasion>,
      weatherConditions: null == weatherConditions
          ? _value._weatherConditions
          : weatherConditions // ignore: cast_nullable_to_non_nullable
              as List<OutfitWeather>,
      seasons: null == seasons
          ? _value._seasons
          : seasons // ignore: cast_nullable_to_non_nullable
              as List<OutfitSeason>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timesWorn: null == timesWorn
          ? _value.timesWorn
          : timesWorn // ignore: cast_nullable_to_non_nullable
              as int,
      comfortRating: null == comfortRating
          ? _value.comfortRating
          : comfortRating // ignore: cast_nullable_to_non_nullable
              as double,
      addedDate: freezed == addedDate
          ? _value.addedDate
          : addedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OutfitImpl implements _Outfit {
  const _$OutfitImpl(
      {this.id,
      this.name,
      this.description,
      @JsonKey(name: 'image_url') this.imageUrl,
      @JsonKey(name: 'clothing_item_ids')
      final List<int> clothingItemIds = const [],
      final List<OutfitOccasion> occasions = const [],
      @JsonKey(name: 'weather_conditions')
      final List<OutfitWeather> weatherConditions = const [],
      final List<OutfitSeason> seasons = const [],
      final List<String> tags = const [],
      @JsonKey(name: 'is_favorite') this.isFavorite = false,
      @JsonKey(name: 'created_at') this.createdAt,
      this.timesWorn = 0,
      this.comfortRating = 0.0,
      this.addedDate})
      : _clothingItemIds = clothingItemIds,
        _occasions = occasions,
        _weatherConditions = weatherConditions,
        _seasons = seasons,
        _tags = tags;

  factory _$OutfitImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutfitImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final List<int> _clothingItemIds;
  @override
  @JsonKey(name: 'clothing_item_ids')
  List<int> get clothingItemIds {
    if (_clothingItemIds is EqualUnmodifiableListView) return _clothingItemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_clothingItemIds);
  }

  final List<OutfitOccasion> _occasions;
  @override
  @JsonKey()
  List<OutfitOccasion> get occasions {
    if (_occasions is EqualUnmodifiableListView) return _occasions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_occasions);
  }

  final List<OutfitWeather> _weatherConditions;
  @override
  @JsonKey(name: 'weather_conditions')
  List<OutfitWeather> get weatherConditions {
    if (_weatherConditions is EqualUnmodifiableListView)
      return _weatherConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weatherConditions);
  }

  final List<OutfitSeason> _seasons;
  @override
  @JsonKey()
  List<OutfitSeason> get seasons {
    if (_seasons is EqualUnmodifiableListView) return _seasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasons);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey()
  final int timesWorn;
  @override
  @JsonKey()
  final double comfortRating;
  @override
  final DateTime? addedDate;

  @override
  String toString() {
    return 'Outfit(id: $id, name: $name, description: $description, imageUrl: $imageUrl, clothingItemIds: $clothingItemIds, occasions: $occasions, weatherConditions: $weatherConditions, seasons: $seasons, tags: $tags, isFavorite: $isFavorite, createdAt: $createdAt, timesWorn: $timesWorn, comfortRating: $comfortRating, addedDate: $addedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._clothingItemIds, _clothingItemIds) &&
            const DeepCollectionEquality()
                .equals(other._occasions, _occasions) &&
            const DeepCollectionEquality()
                .equals(other._weatherConditions, _weatherConditions) &&
            const DeepCollectionEquality().equals(other._seasons, _seasons) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.timesWorn, timesWorn) ||
                other.timesWorn == timesWorn) &&
            (identical(other.comfortRating, comfortRating) ||
                other.comfortRating == comfortRating) &&
            (identical(other.addedDate, addedDate) ||
                other.addedDate == addedDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      imageUrl,
      const DeepCollectionEquality().hash(_clothingItemIds),
      const DeepCollectionEquality().hash(_occasions),
      const DeepCollectionEquality().hash(_weatherConditions),
      const DeepCollectionEquality().hash(_seasons),
      const DeepCollectionEquality().hash(_tags),
      isFavorite,
      createdAt,
      timesWorn,
      comfortRating,
      addedDate);

  /// Create a copy of Outfit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitImplCopyWith<_$OutfitImpl> get copyWith =>
      __$$OutfitImplCopyWithImpl<_$OutfitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutfitImplToJson(
      this,
    );
  }
}

abstract class _Outfit implements Outfit {
  const factory _Outfit(
      {final int? id,
      final String? name,
      final String? description,
      @JsonKey(name: 'image_url') final String? imageUrl,
      @JsonKey(name: 'clothing_item_ids') final List<int> clothingItemIds,
      final List<OutfitOccasion> occasions,
      @JsonKey(name: 'weather_conditions')
      final List<OutfitWeather> weatherConditions,
      final List<OutfitSeason> seasons,
      final List<String> tags,
      @JsonKey(name: 'is_favorite') final bool isFavorite,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      final int timesWorn,
      final double comfortRating,
      final DateTime? addedDate}) = _$OutfitImpl;

  factory _Outfit.fromJson(Map<String, dynamic> json) = _$OutfitImpl.fromJson;

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
  @JsonKey(name: 'clothing_item_ids')
  List<int> get clothingItemIds;
  @override
  List<OutfitOccasion> get occasions;
  @override
  @JsonKey(name: 'weather_conditions')
  List<OutfitWeather> get weatherConditions;
  @override
  List<OutfitSeason> get seasons;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'is_favorite')
  bool get isFavorite;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  int get timesWorn;
  @override
  double get comfortRating;
  @override
  DateTime? get addedDate;

  /// Create a copy of Outfit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutfitImplCopyWith<_$OutfitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
