// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecommendationFeedback _$RecommendationFeedbackFromJson(
    Map<String, dynamic> json) {
  return _RecommendationFeedback.fromJson(json);
}

/// @nodoc
mixin _$RecommendationFeedback {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get recommendationId => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError; // 1-5 stars
  List<String> get tags =>
      throw _privateConstructorUsedError; // positive, negative, neutral tags
  String get comment => throw _privateConstructorUsedError;
  List<String> get likedItems =>
      throw _privateConstructorUsedError; // specific items in the outfit that were liked
  List<String> get dislikedItems =>
      throw _privateConstructorUsedError; // specific items in the outfit that were disliked
  bool get wouldReuse => throw _privateConstructorUsedError;
  bool get wouldRecommend => throw _privateConstructorUsedError;
  List<String> get improvementSuggestions => throw _privateConstructorUsedError;
  FeedbackCategory get category => throw _privateConstructorUsedError;
  FeedbackSource get source => throw _privateConstructorUsedError;
  String get dummyField =>
      throw _privateConstructorUsedError; // Workaround for DateTime default issue
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this RecommendationFeedback to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationFeedback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationFeedbackCopyWith<RecommendationFeedback> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationFeedbackCopyWith<$Res> {
  factory $RecommendationFeedbackCopyWith(RecommendationFeedback value,
          $Res Function(RecommendationFeedback) then) =
      _$RecommendationFeedbackCopyWithImpl<$Res, RecommendationFeedback>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String recommendationId,
      int rating,
      List<String> tags,
      String comment,
      List<String> likedItems,
      List<String> dislikedItems,
      bool wouldReuse,
      bool wouldRecommend,
      List<String> improvementSuggestions,
      FeedbackCategory category,
      FeedbackSource source,
      String dummyField,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$RecommendationFeedbackCopyWithImpl<$Res,
        $Val extends RecommendationFeedback>
    implements $RecommendationFeedbackCopyWith<$Res> {
  _$RecommendationFeedbackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationFeedback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? recommendationId = null,
    Object? rating = null,
    Object? tags = null,
    Object? comment = null,
    Object? likedItems = null,
    Object? dislikedItems = null,
    Object? wouldReuse = null,
    Object? wouldRecommend = null,
    Object? improvementSuggestions = null,
    Object? category = null,
    Object? source = null,
    Object? dummyField = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      recommendationId: null == recommendationId
          ? _value.recommendationId
          : recommendationId // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      likedItems: null == likedItems
          ? _value.likedItems
          : likedItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedItems: null == dislikedItems
          ? _value.dislikedItems
          : dislikedItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      wouldReuse: null == wouldReuse
          ? _value.wouldReuse
          : wouldReuse // ignore: cast_nullable_to_non_nullable
              as bool,
      wouldRecommend: null == wouldRecommend
          ? _value.wouldRecommend
          : wouldRecommend // ignore: cast_nullable_to_non_nullable
              as bool,
      improvementSuggestions: null == improvementSuggestions
          ? _value.improvementSuggestions
          : improvementSuggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as FeedbackCategory,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as FeedbackSource,
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
abstract class _$$RecommendationFeedbackImplCopyWith<$Res>
    implements $RecommendationFeedbackCopyWith<$Res> {
  factory _$$RecommendationFeedbackImplCopyWith(
          _$RecommendationFeedbackImpl value,
          $Res Function(_$RecommendationFeedbackImpl) then) =
      __$$RecommendationFeedbackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String recommendationId,
      int rating,
      List<String> tags,
      String comment,
      List<String> likedItems,
      List<String> dislikedItems,
      bool wouldReuse,
      bool wouldRecommend,
      List<String> improvementSuggestions,
      FeedbackCategory category,
      FeedbackSource source,
      String dummyField,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$RecommendationFeedbackImplCopyWithImpl<$Res>
    extends _$RecommendationFeedbackCopyWithImpl<$Res,
        _$RecommendationFeedbackImpl>
    implements _$$RecommendationFeedbackImplCopyWith<$Res> {
  __$$RecommendationFeedbackImplCopyWithImpl(
      _$RecommendationFeedbackImpl _value,
      $Res Function(_$RecommendationFeedbackImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecommendationFeedback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? recommendationId = null,
    Object? rating = null,
    Object? tags = null,
    Object? comment = null,
    Object? likedItems = null,
    Object? dislikedItems = null,
    Object? wouldReuse = null,
    Object? wouldRecommend = null,
    Object? improvementSuggestions = null,
    Object? category = null,
    Object? source = null,
    Object? dummyField = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$RecommendationFeedbackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      recommendationId: null == recommendationId
          ? _value.recommendationId
          : recommendationId // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      likedItems: null == likedItems
          ? _value._likedItems
          : likedItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedItems: null == dislikedItems
          ? _value._dislikedItems
          : dislikedItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      wouldReuse: null == wouldReuse
          ? _value.wouldReuse
          : wouldReuse // ignore: cast_nullable_to_non_nullable
              as bool,
      wouldRecommend: null == wouldRecommend
          ? _value.wouldRecommend
          : wouldRecommend // ignore: cast_nullable_to_non_nullable
              as bool,
      improvementSuggestions: null == improvementSuggestions
          ? _value._improvementSuggestions
          : improvementSuggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as FeedbackCategory,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as FeedbackSource,
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
class _$RecommendationFeedbackImpl implements _RecommendationFeedback {
  const _$RecommendationFeedbackImpl(
      {this.id = '',
      this.userId = '',
      this.recommendationId = '',
      this.rating = 0,
      final List<String> tags = const <String>[],
      this.comment = '',
      final List<String> likedItems = const <String>[],
      final List<String> dislikedItems = const <String>[],
      this.wouldReuse = false,
      this.wouldRecommend = false,
      final List<String> improvementSuggestions = const <String>[],
      this.category = FeedbackCategory.general,
      this.source = FeedbackSource.user,
      this.dummyField = '',
      this.createdAt,
      this.updatedAt})
      : _tags = tags,
        _likedItems = likedItems,
        _dislikedItems = dislikedItems,
        _improvementSuggestions = improvementSuggestions;

  factory _$RecommendationFeedbackImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationFeedbackImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String userId;
  @override
  @JsonKey()
  final String recommendationId;
  @override
  @JsonKey()
  final int rating;
// 1-5 stars
  final List<String> _tags;
// 1-5 stars
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

// positive, negative, neutral tags
  @override
  @JsonKey()
  final String comment;
  final List<String> _likedItems;
  @override
  @JsonKey()
  List<String> get likedItems {
    if (_likedItems is EqualUnmodifiableListView) return _likedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likedItems);
  }

// specific items in the outfit that were liked
  final List<String> _dislikedItems;
// specific items in the outfit that were liked
  @override
  @JsonKey()
  List<String> get dislikedItems {
    if (_dislikedItems is EqualUnmodifiableListView) return _dislikedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dislikedItems);
  }

// specific items in the outfit that were disliked
  @override
  @JsonKey()
  final bool wouldReuse;
  @override
  @JsonKey()
  final bool wouldRecommend;
  final List<String> _improvementSuggestions;
  @override
  @JsonKey()
  List<String> get improvementSuggestions {
    if (_improvementSuggestions is EqualUnmodifiableListView)
      return _improvementSuggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_improvementSuggestions);
  }

  @override
  @JsonKey()
  final FeedbackCategory category;
  @override
  @JsonKey()
  final FeedbackSource source;
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
    return 'RecommendationFeedback(id: $id, userId: $userId, recommendationId: $recommendationId, rating: $rating, tags: $tags, comment: $comment, likedItems: $likedItems, dislikedItems: $dislikedItems, wouldReuse: $wouldReuse, wouldRecommend: $wouldRecommend, improvementSuggestions: $improvementSuggestions, category: $category, source: $source, dummyField: $dummyField, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationFeedbackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.recommendationId, recommendationId) ||
                other.recommendationId == recommendationId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            const DeepCollectionEquality()
                .equals(other._likedItems, _likedItems) &&
            const DeepCollectionEquality()
                .equals(other._dislikedItems, _dislikedItems) &&
            (identical(other.wouldReuse, wouldReuse) ||
                other.wouldReuse == wouldReuse) &&
            (identical(other.wouldRecommend, wouldRecommend) ||
                other.wouldRecommend == wouldRecommend) &&
            const DeepCollectionEquality().equals(
                other._improvementSuggestions, _improvementSuggestions) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.source, source) || other.source == source) &&
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
      userId,
      recommendationId,
      rating,
      const DeepCollectionEquality().hash(_tags),
      comment,
      const DeepCollectionEquality().hash(_likedItems),
      const DeepCollectionEquality().hash(_dislikedItems),
      wouldReuse,
      wouldRecommend,
      const DeepCollectionEquality().hash(_improvementSuggestions),
      category,
      source,
      dummyField,
      createdAt,
      updatedAt);

  /// Create a copy of RecommendationFeedback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationFeedbackImplCopyWith<_$RecommendationFeedbackImpl>
      get copyWith => __$$RecommendationFeedbackImplCopyWithImpl<
          _$RecommendationFeedbackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationFeedbackImplToJson(
      this,
    );
  }
}

abstract class _RecommendationFeedback implements RecommendationFeedback {
  const factory _RecommendationFeedback(
      {final String id,
      final String userId,
      final String recommendationId,
      final int rating,
      final List<String> tags,
      final String comment,
      final List<String> likedItems,
      final List<String> dislikedItems,
      final bool wouldReuse,
      final bool wouldRecommend,
      final List<String> improvementSuggestions,
      final FeedbackCategory category,
      final FeedbackSource source,
      final String dummyField,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$RecommendationFeedbackImpl;

  factory _RecommendationFeedback.fromJson(Map<String, dynamic> json) =
      _$RecommendationFeedbackImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get recommendationId;
  @override
  int get rating; // 1-5 stars
  @override
  List<String> get tags; // positive, negative, neutral tags
  @override
  String get comment;
  @override
  List<String> get likedItems; // specific items in the outfit that were liked
  @override
  List<String>
      get dislikedItems; // specific items in the outfit that were disliked
  @override
  bool get wouldReuse;
  @override
  bool get wouldRecommend;
  @override
  List<String> get improvementSuggestions;
  @override
  FeedbackCategory get category;
  @override
  FeedbackSource get source;
  @override
  String get dummyField; // Workaround for DateTime default issue
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of RecommendationFeedback
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationFeedbackImplCopyWith<_$RecommendationFeedbackImpl>
      get copyWith => throw _privateConstructorUsedError;
}
