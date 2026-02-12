// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OutfitRecommendation _$OutfitRecommendationFromJson(Map<String, dynamic> json) {
  return _OutfitRecommendation.fromJson(json);
}

/// @nodoc
mixin _$OutfitRecommendation {
  String? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String>? get recommendedItems => throw _privateConstructorUsedError;
  double? get temperature => throw _privateConstructorUsedError;
  String? get weatherCondition => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this OutfitRecommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OutfitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutfitRecommendationCopyWith<OutfitRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitRecommendationCopyWith<$Res> {
  factory $OutfitRecommendationCopyWith(OutfitRecommendation value,
          $Res Function(OutfitRecommendation) then) =
      _$OutfitRecommendationCopyWithImpl<$Res, OutfitRecommendation>;
  @useResult
  $Res call(
      {String? id,
      String? title,
      String? description,
      String? imageUrl,
      List<String>? recommendedItems,
      double? temperature,
      String? weatherCondition,
      DateTime? createdAt});
}

/// @nodoc
class _$OutfitRecommendationCopyWithImpl<$Res,
        $Val extends OutfitRecommendation>
    implements $OutfitRecommendationCopyWith<$Res> {
  _$OutfitRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OutfitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? recommendedItems = freezed,
    Object? temperature = freezed,
    Object? weatherCondition = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      recommendedItems: freezed == recommendedItems
          ? _value.recommendedItems
          : recommendedItems // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double?,
      weatherCondition: freezed == weatherCondition
          ? _value.weatherCondition
          : weatherCondition // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutfitRecommendationImplCopyWith<$Res>
    implements $OutfitRecommendationCopyWith<$Res> {
  factory _$$OutfitRecommendationImplCopyWith(_$OutfitRecommendationImpl value,
          $Res Function(_$OutfitRecommendationImpl) then) =
      __$$OutfitRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? title,
      String? description,
      String? imageUrl,
      List<String>? recommendedItems,
      double? temperature,
      String? weatherCondition,
      DateTime? createdAt});
}

/// @nodoc
class __$$OutfitRecommendationImplCopyWithImpl<$Res>
    extends _$OutfitRecommendationCopyWithImpl<$Res, _$OutfitRecommendationImpl>
    implements _$$OutfitRecommendationImplCopyWith<$Res> {
  __$$OutfitRecommendationImplCopyWithImpl(_$OutfitRecommendationImpl _value,
      $Res Function(_$OutfitRecommendationImpl) _then)
      : super(_value, _then);

  /// Create a copy of OutfitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? recommendedItems = freezed,
    Object? temperature = freezed,
    Object? weatherCondition = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$OutfitRecommendationImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      recommendedItems: freezed == recommendedItems
          ? _value._recommendedItems
          : recommendedItems // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double?,
      weatherCondition: freezed == weatherCondition
          ? _value.weatherCondition
          : weatherCondition // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OutfitRecommendationImpl implements _OutfitRecommendation {
  const _$OutfitRecommendationImpl(
      {this.id,
      this.title,
      this.description,
      this.imageUrl,
      final List<String>? recommendedItems,
      this.temperature,
      this.weatherCondition,
      this.createdAt})
      : _recommendedItems = recommendedItems;

  factory _$OutfitRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutfitRecommendationImplFromJson(json);

  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? imageUrl;
  final List<String>? _recommendedItems;
  @override
  List<String>? get recommendedItems {
    final value = _recommendedItems;
    if (value == null) return null;
    if (_recommendedItems is EqualUnmodifiableListView)
      return _recommendedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final double? temperature;
  @override
  final String? weatherCondition;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'OutfitRecommendation(id: $id, title: $title, description: $description, imageUrl: $imageUrl, recommendedItems: $recommendedItems, temperature: $temperature, weatherCondition: $weatherCondition, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitRecommendationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._recommendedItems, _recommendedItems) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.weatherCondition, weatherCondition) ||
                other.weatherCondition == weatherCondition) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      imageUrl,
      const DeepCollectionEquality().hash(_recommendedItems),
      temperature,
      weatherCondition,
      createdAt);

  /// Create a copy of OutfitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitRecommendationImplCopyWith<_$OutfitRecommendationImpl>
      get copyWith =>
          __$$OutfitRecommendationImplCopyWithImpl<_$OutfitRecommendationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutfitRecommendationImplToJson(
      this,
    );
  }
}

abstract class _OutfitRecommendation implements OutfitRecommendation {
  const factory _OutfitRecommendation(
      {final String? id,
      final String? title,
      final String? description,
      final String? imageUrl,
      final List<String>? recommendedItems,
      final double? temperature,
      final String? weatherCondition,
      final DateTime? createdAt}) = _$OutfitRecommendationImpl;

  factory _OutfitRecommendation.fromJson(Map<String, dynamic> json) =
      _$OutfitRecommendationImpl.fromJson;

  @override
  String? get id;
  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  List<String>? get recommendedItems;
  @override
  double? get temperature;
  @override
  String? get weatherCondition;
  @override
  DateTime? get createdAt;

  /// Create a copy of OutfitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutfitRecommendationImplCopyWith<_$OutfitRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
