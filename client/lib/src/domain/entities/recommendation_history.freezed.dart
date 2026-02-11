// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecommendationHistory _$RecommendationHistoryFromJson(
    Map<String, dynamic> json) {
  return _RecommendationHistory.fromJson(json);
}

/// @nodoc
mixin _$RecommendationHistory {
  int? get id => throw _privateConstructorUsedError;
  int? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'recommendation')
  @RecommendationConverter()
  Recommendation? get recommendation => throw _privateConstructorUsedError;
  bool get isUsed => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;
  bool get isSaved => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this RecommendationHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationHistoryCopyWith<RecommendationHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationHistoryCopyWith<$Res> {
  factory $RecommendationHistoryCopyWith(RecommendationHistory value,
          $Res Function(RecommendationHistory) then) =
      _$RecommendationHistoryCopyWithImpl<$Res, RecommendationHistory>;
  @useResult
  $Res call(
      {int? id,
      int? userId,
      @JsonKey(name: 'recommendation')
      @RecommendationConverter()
      Recommendation? recommendation,
      bool isUsed,
      bool isLiked,
      bool isSaved,
      int rating,
      DateTime? createdAt,
      DateTime? updatedAt});

  $RecommendationCopyWith<$Res>? get recommendation;
}

/// @nodoc
class _$RecommendationHistoryCopyWithImpl<$Res,
        $Val extends RecommendationHistory>
    implements $RecommendationHistoryCopyWith<$Res> {
  _$RecommendationHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? recommendation = freezed,
    Object? isUsed = null,
    Object? isLiked = null,
    Object? isSaved = null,
    Object? rating = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      recommendation: freezed == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as Recommendation?,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
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

  /// Create a copy of RecommendationHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationCopyWith<$Res>? get recommendation {
    if (_value.recommendation == null) {
      return null;
    }

    return $RecommendationCopyWith<$Res>(_value.recommendation!, (value) {
      return _then(_value.copyWith(recommendation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecommendationHistoryImplCopyWith<$Res>
    implements $RecommendationHistoryCopyWith<$Res> {
  factory _$$RecommendationHistoryImplCopyWith(
          _$RecommendationHistoryImpl value,
          $Res Function(_$RecommendationHistoryImpl) then) =
      __$$RecommendationHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int? userId,
      @JsonKey(name: 'recommendation')
      @RecommendationConverter()
      Recommendation? recommendation,
      bool isUsed,
      bool isLiked,
      bool isSaved,
      int rating,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $RecommendationCopyWith<$Res>? get recommendation;
}

/// @nodoc
class __$$RecommendationHistoryImplCopyWithImpl<$Res>
    extends _$RecommendationHistoryCopyWithImpl<$Res,
        _$RecommendationHistoryImpl>
    implements _$$RecommendationHistoryImplCopyWith<$Res> {
  __$$RecommendationHistoryImplCopyWithImpl(_$RecommendationHistoryImpl _value,
      $Res Function(_$RecommendationHistoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecommendationHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? recommendation = freezed,
    Object? isUsed = null,
    Object? isLiked = null,
    Object? isSaved = null,
    Object? rating = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$RecommendationHistoryImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      recommendation: freezed == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as Recommendation?,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$RecommendationHistoryImpl implements _RecommendationHistory {
  const _$RecommendationHistoryImpl(
      {this.id,
      this.userId,
      @JsonKey(name: 'recommendation')
      @RecommendationConverter()
      this.recommendation,
      this.isUsed = false,
      this.isLiked = false,
      this.isSaved = false,
      this.rating = 0,
      this.createdAt,
      this.updatedAt});

  factory _$RecommendationHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationHistoryImplFromJson(json);

  @override
  final int? id;
  @override
  final int? userId;
  @override
  @JsonKey(name: 'recommendation')
  @RecommendationConverter()
  final Recommendation? recommendation;
  @override
  @JsonKey()
  final bool isUsed;
  @override
  @JsonKey()
  final bool isLiked;
  @override
  @JsonKey()
  final bool isSaved;
  @override
  @JsonKey()
  final int rating;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'RecommendationHistory(id: $id, userId: $userId, recommendation: $recommendation, isUsed: $isUsed, isLiked: $isLiked, isSaved: $isSaved, rating: $rating, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, recommendation,
      isUsed, isLiked, isSaved, rating, createdAt, updatedAt);

  /// Create a copy of RecommendationHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationHistoryImplCopyWith<_$RecommendationHistoryImpl>
      get copyWith => __$$RecommendationHistoryImplCopyWithImpl<
          _$RecommendationHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationHistoryImplToJson(
      this,
    );
  }
}

abstract class _RecommendationHistory implements RecommendationHistory {
  const factory _RecommendationHistory(
      {final int? id,
      final int? userId,
      @JsonKey(name: 'recommendation')
      @RecommendationConverter()
      final Recommendation? recommendation,
      final bool isUsed,
      final bool isLiked,
      final bool isSaved,
      final int rating,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$RecommendationHistoryImpl;

  factory _RecommendationHistory.fromJson(Map<String, dynamic> json) =
      _$RecommendationHistoryImpl.fromJson;

  @override
  int? get id;
  @override
  int? get userId;
  @override
  @JsonKey(name: 'recommendation')
  @RecommendationConverter()
  Recommendation? get recommendation;
  @override
  bool get isUsed;
  @override
  bool get isLiked;
  @override
  bool get isSaved;
  @override
  int get rating;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of RecommendationHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationHistoryImplCopyWith<_$RecommendationHistoryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
