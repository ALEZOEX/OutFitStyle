// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personalized_recommendation_algorithm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PersonalizedRecommendationAlgorithm
    _$PersonalizedRecommendationAlgorithmFromJson(Map<String, dynamic> json) {
  return _PersonalizedRecommendationAlgorithm.fromJson(json);
}

/// @nodoc
mixin _$PersonalizedRecommendationAlgorithm {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  RecommendationAlgorithmType get type => throw _privateConstructorUsedError;
  double get accuracy => throw _privateConstructorUsedError;
  double get precision => throw _privateConstructorUsedError;
  double get recall => throw _privateConstructorUsedError;
  double get f1Score => throw _privateConstructorUsedError;
  List<String> get featuresUsed => throw _privateConstructorUsedError;
  List<String> get weights =>
      throw _privateConstructorUsedError; // feature weights
  PersonalizationLevel get personalizationLevel =>
      throw _privateConstructorUsedError;
  int get trainingSamples => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get dummyField =>
      throw _privateConstructorUsedError; // Workaround for DateTime default issue
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PersonalizedRecommendationAlgorithm to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PersonalizedRecommendationAlgorithm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonalizedRecommendationAlgorithmCopyWith<
          PersonalizedRecommendationAlgorithm>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalizedRecommendationAlgorithmCopyWith<$Res> {
  factory $PersonalizedRecommendationAlgorithmCopyWith(
          PersonalizedRecommendationAlgorithm value,
          $Res Function(PersonalizedRecommendationAlgorithm) then) =
      _$PersonalizedRecommendationAlgorithmCopyWithImpl<$Res,
          PersonalizedRecommendationAlgorithm>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      RecommendationAlgorithmType type,
      double accuracy,
      double precision,
      double recall,
      double f1Score,
      List<String> featuresUsed,
      List<String> weights,
      PersonalizationLevel personalizationLevel,
      int trainingSamples,
      bool isActive,
      bool isDefault,
      List<String> tags,
      String dummyField,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PersonalizedRecommendationAlgorithmCopyWithImpl<$Res,
        $Val extends PersonalizedRecommendationAlgorithm>
    implements $PersonalizedRecommendationAlgorithmCopyWith<$Res> {
  _$PersonalizedRecommendationAlgorithmCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PersonalizedRecommendationAlgorithm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? accuracy = null,
    Object? precision = null,
    Object? recall = null,
    Object? f1Score = null,
    Object? featuresUsed = null,
    Object? weights = null,
    Object? personalizationLevel = null,
    Object? trainingSamples = null,
    Object? isActive = null,
    Object? isDefault = null,
    Object? tags = null,
    Object? dummyField = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecommendationAlgorithmType,
      accuracy: null == accuracy
          ? _value.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double,
      precision: null == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as double,
      recall: null == recall
          ? _value.recall
          : recall // ignore: cast_nullable_to_non_nullable
              as double,
      f1Score: null == f1Score
          ? _value.f1Score
          : f1Score // ignore: cast_nullable_to_non_nullable
              as double,
      featuresUsed: null == featuresUsed
          ? _value.featuresUsed
          : featuresUsed // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weights: null == weights
          ? _value.weights
          : weights // ignore: cast_nullable_to_non_nullable
              as List<String>,
      personalizationLevel: null == personalizationLevel
          ? _value.personalizationLevel
          : personalizationLevel // ignore: cast_nullable_to_non_nullable
              as PersonalizationLevel,
      trainingSamples: null == trainingSamples
          ? _value.trainingSamples
          : trainingSamples // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dummyField: null == dummyField
          ? _value.dummyField
          : dummyField // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonalizedRecommendationAlgorithmImplCopyWith<$Res>
    implements $PersonalizedRecommendationAlgorithmCopyWith<$Res> {
  factory _$$PersonalizedRecommendationAlgorithmImplCopyWith(
          _$PersonalizedRecommendationAlgorithmImpl value,
          $Res Function(_$PersonalizedRecommendationAlgorithmImpl) then) =
      __$$PersonalizedRecommendationAlgorithmImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      RecommendationAlgorithmType type,
      double accuracy,
      double precision,
      double recall,
      double f1Score,
      List<String> featuresUsed,
      List<String> weights,
      PersonalizationLevel personalizationLevel,
      int trainingSamples,
      bool isActive,
      bool isDefault,
      List<String> tags,
      String dummyField,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PersonalizedRecommendationAlgorithmImplCopyWithImpl<$Res>
    extends _$PersonalizedRecommendationAlgorithmCopyWithImpl<$Res,
        _$PersonalizedRecommendationAlgorithmImpl>
    implements _$$PersonalizedRecommendationAlgorithmImplCopyWith<$Res> {
  __$$PersonalizedRecommendationAlgorithmImplCopyWithImpl(
      _$PersonalizedRecommendationAlgorithmImpl _value,
      $Res Function(_$PersonalizedRecommendationAlgorithmImpl) _then)
      : super(_value, _then);

  /// Create a copy of PersonalizedRecommendationAlgorithm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? accuracy = null,
    Object? precision = null,
    Object? recall = null,
    Object? f1Score = null,
    Object? featuresUsed = null,
    Object? weights = null,
    Object? personalizationLevel = null,
    Object? trainingSamples = null,
    Object? isActive = null,
    Object? isDefault = null,
    Object? tags = null,
    Object? dummyField = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PersonalizedRecommendationAlgorithmImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecommendationAlgorithmType,
      accuracy: null == accuracy
          ? _value.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double,
      precision: null == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as double,
      recall: null == recall
          ? _value.recall
          : recall // ignore: cast_nullable_to_non_nullable
              as double,
      f1Score: null == f1Score
          ? _value.f1Score
          : f1Score // ignore: cast_nullable_to_non_nullable
              as double,
      featuresUsed: null == featuresUsed
          ? _value._featuresUsed
          : featuresUsed // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weights: null == weights
          ? _value._weights
          : weights // ignore: cast_nullable_to_non_nullable
              as List<String>,
      personalizationLevel: null == personalizationLevel
          ? _value.personalizationLevel
          : personalizationLevel // ignore: cast_nullable_to_non_nullable
              as PersonalizationLevel,
      trainingSamples: null == trainingSamples
          ? _value.trainingSamples
          : trainingSamples // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dummyField: null == dummyField
          ? _value.dummyField
          : dummyField // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonalizedRecommendationAlgorithmImpl
    implements _PersonalizedRecommendationAlgorithm {
  const _$PersonalizedRecommendationAlgorithmImpl(
      {this.id = '',
      this.name = '',
      this.description = '',
      this.type = RecommendationAlgorithmType.collaborativeFiltering,
      this.accuracy = 0.0,
      this.precision = 0.0,
      this.recall = 0.0,
      this.f1Score = 0.0,
      final List<String> featuresUsed = const <String>[],
      final List<String> weights = const <String>[],
      this.personalizationLevel = PersonalizationLevel.high,
      this.trainingSamples = 0,
      this.isActive = false,
      this.isDefault = false,
      final List<String> tags = const <String>[],
      this.dummyField = '',
      this.createdAt,
      this.updatedAt})
      : _featuresUsed = featuresUsed,
        _weights = weights,
        _tags = tags;

  factory _$PersonalizedRecommendationAlgorithmImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$PersonalizedRecommendationAlgorithmImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final RecommendationAlgorithmType type;
  @override
  @JsonKey()
  final double accuracy;
  @override
  @JsonKey()
  final double precision;
  @override
  @JsonKey()
  final double recall;
  @override
  @JsonKey()
  final double f1Score;
  final List<String> _featuresUsed;
  @override
  @JsonKey()
  List<String> get featuresUsed {
    if (_featuresUsed is EqualUnmodifiableListView) return _featuresUsed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_featuresUsed);
  }

  final List<String> _weights;
  @override
  @JsonKey()
  List<String> get weights {
    if (_weights is EqualUnmodifiableListView) return _weights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weights);
  }

// feature weights
  @override
  @JsonKey()
  final PersonalizationLevel personalizationLevel;
  @override
  @JsonKey()
  final int trainingSamples;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isDefault;
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
  final String dummyField;
// Workaround for DateTime default issue
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PersonalizedRecommendationAlgorithm(id: $id, name: $name, description: $description, type: $type, accuracy: $accuracy, precision: $precision, recall: $recall, f1Score: $f1Score, featuresUsed: $featuresUsed, weights: $weights, personalizationLevel: $personalizationLevel, trainingSamples: $trainingSamples, isActive: $isActive, isDefault: $isDefault, tags: $tags, dummyField: $dummyField, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalizedRecommendationAlgorithmImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.precision, precision) ||
                other.precision == precision) &&
            (identical(other.recall, recall) || other.recall == recall) &&
            (identical(other.f1Score, f1Score) || other.f1Score == f1Score) &&
            const DeepCollectionEquality()
                .equals(other._featuresUsed, _featuresUsed) &&
            const DeepCollectionEquality().equals(other._weights, _weights) &&
            (identical(other.personalizationLevel, personalizationLevel) ||
                other.personalizationLevel == personalizationLevel) &&
            (identical(other.trainingSamples, trainingSamples) ||
                other.trainingSamples == trainingSamples) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.dummyField, dummyField) ||
                other.dummyField == dummyField) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      type,
      accuracy,
      precision,
      recall,
      f1Score,
      const DeepCollectionEquality().hash(_featuresUsed),
      const DeepCollectionEquality().hash(_weights),
      personalizationLevel,
      trainingSamples,
      isActive,
      isDefault,
      const DeepCollectionEquality().hash(_tags),
      dummyField,
      createdAt,
      updatedAt);

  /// Create a copy of PersonalizedRecommendationAlgorithm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalizedRecommendationAlgorithmImplCopyWith<
          _$PersonalizedRecommendationAlgorithmImpl>
      get copyWith => __$$PersonalizedRecommendationAlgorithmImplCopyWithImpl<
          _$PersonalizedRecommendationAlgorithmImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonalizedRecommendationAlgorithmImplToJson(
      this,
    );
  }
}

abstract class _PersonalizedRecommendationAlgorithm
    implements PersonalizedRecommendationAlgorithm {
  const factory _PersonalizedRecommendationAlgorithm(
      {final String id,
      final String name,
      final String description,
      final RecommendationAlgorithmType type,
      final double accuracy,
      final double precision,
      final double recall,
      final double f1Score,
      final List<String> featuresUsed,
      final List<String> weights,
      final PersonalizationLevel personalizationLevel,
      final int trainingSamples,
      final bool isActive,
      final bool isDefault,
      final List<String> tags,
      final String dummyField,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$PersonalizedRecommendationAlgorithmImpl;

  factory _PersonalizedRecommendationAlgorithm.fromJson(
          Map<String, dynamic> json) =
      _$PersonalizedRecommendationAlgorithmImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  RecommendationAlgorithmType get type;
  @override
  double get accuracy;
  @override
  double get precision;
  @override
  double get recall;
  @override
  double get f1Score;
  @override
  List<String> get featuresUsed;
  @override
  List<String> get weights; // feature weights
  @override
  PersonalizationLevel get personalizationLevel;
  @override
  int get trainingSamples;
  @override
  bool get isActive;
  @override
  bool get isDefault;
  @override
  List<String> get tags;
  @override
  String get dummyField; // Workaround for DateTime default issue
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PersonalizedRecommendationAlgorithm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonalizedRecommendationAlgorithmImplCopyWith<
          _$PersonalizedRecommendationAlgorithmImpl>
      get copyWith => throw _privateConstructorUsedError;
}
