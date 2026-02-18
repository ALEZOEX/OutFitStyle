// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'recommendation.dart';

part 'recommendation_history.freezed.dart';
part 'recommendation_history.g.dart';

// Конвертер для Recommendation
class RecommendationConverter
    implements JsonConverter<Recommendation?, Object?> {
  const RecommendationConverter();

  @override
  Recommendation? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      return Recommendation.fromJson(json);
    }
    return null;
  }

  @override
  Object? toJson(Recommendation? object) {
    return object?.toJson();
  }
}

@freezed
abstract class RecommendationHistory with _$RecommendationHistory {
  const factory RecommendationHistory({
    int? id,
    int? userId,
    @JsonKey(name: 'recommendation')
    @RecommendationConverter()
    Recommendation? recommendation,
    @Default(false) bool isUsed,
    @Default(false) bool isLiked,
    @Default(false) bool isSaved,
    @Default(0) int rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RecommendationHistory;

  factory RecommendationHistory.fromJson(Map<String, dynamic> json) =>
      _$RecommendationHistoryFromJson(json);
}
