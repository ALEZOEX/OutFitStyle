import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit_rating.freezed.dart';
part 'outfit_rating.g.dart';

/// Оценка рекомендации одежды пользователем
/// Рейтинг 1-5 звёзд конвертируется в quality_score от -10 до +10
@freezed
abstract class OutfitRating with _$OutfitRating {
  const factory OutfitRating({
    @Default(0) int id,
    @Default('') String userId,
    @Default('') String recommendationId,
    @Default(<int>[]) List<int> outfitItems, // ID вещей в наряде
    @Default(0) int rating, // 1-5 звёзд
    @Default(0) int qualityScore, // -10 до +10
    String? feedback, // Текстовый отзыв
    @Default(null) ThermalFeedback? thermalFeedback, // "too_hot", "too_cold", "just_right"
    DateTime? createdAt,
  }) = _OutfitRating;

  factory OutfitRating.fromJson(Map<String, dynamic> json) =>
      _$OutfitRatingFromJson(json);

  /// Конвертирует рейтинг 1-5 в quality_score -10..+10
  static int ratingToQualityScore(int rating) {
    if (rating < 1 || rating > 5) return 0;
    return (rating - 3) * 5;
  }

  /// Конвертирует quality_score -10..+10 обратно в рейтинг 1-5
  static int qualityScoreToRating(int qualityScore) {
    final rating = (qualityScore ~/ 5) + 3;
    if (rating < 1) return 1;
    if (rating > 5) return 5;
    return rating;
  }
}

/// Extension для дополнительных методов OutfitRating
extension OutfitRatingExtension on OutfitRating {
  /// Положительная ли оценка (rating >= 4)
  bool get isPositive => rating >= 4;

  /// Отрицательная ли оценка (rating <= 2)
  bool get isNegative => rating <= 2;

  /// Нейтральная ли оценка (rating == 3)
  bool get isNeutral => rating == 3;
}

/// Статистика качества рекомендации
@freezed
abstract class RecommendationQuality with _$RecommendationQuality {
  const factory RecommendationQuality({
    @Default('') String recommendationId,
    @Default(0.0) double avgRating, // Средний рейтинг 1-5
    @Default(0.0) double avgQualityScore, // Средний quality_score -10..+10
    @Default(0) int ratingCount, // Количество оценок
    @Default(0) int positiveCount, // Количество положительных (4-5)
    @Default(0) int negativeCount, // Количество отрицательных (1-2)
    int? userRating, // Оценка текущего пользователя (если есть)
  }) = _RecommendationQuality;

  factory RecommendationQuality.fromJson(Map<String, dynamic> json) =>
      _$RecommendationQualityFromJson(json);

  /// Пустой объект статистики
  factory RecommendationQuality.empty({String? recommendationId}) {
    return RecommendationQuality(
      recommendationId: recommendationId ?? '',
      avgRating: 0.0,
      avgQualityScore: 0.0,
      ratingCount: 0,
      positiveCount: 0,
      negativeCount: 0,
      userRating: null,
    );
  }
}

/// Статистика оценок пользователя
@freezed
abstract class UserRatingStats with _$UserRatingStats {
  const factory UserRatingStats({
    @Default('') String userId,
    @Default(0) int totalRatings,
    @Default(0.0) double avgRating,
    @Default(0.0) double avgQualityScore,
    @Default(0) int positiveRatings,
    @Default(0) int negativeRatings,
    DateTime? lastRatedAt,
  }) = _UserRatingStats;

  factory UserRatingStats.fromJson(Map<String, dynamic> json) =>
      _$UserRatingStatsFromJson(json);

  factory UserRatingStats.empty() => const UserRatingStats(
        userId: '',
        totalRatings: 0,
        avgRating: 0.0,
        avgQualityScore: 0.0,
        positiveRatings: 0,
        negativeRatings: 0,
        lastRatedAt: null,
      );
}

/// Термальная обратная связь
enum ThermalFeedback {
  @JsonValue('too_hot')
  tooHot('Слишком жарко'),
  @JsonValue('too_cold')
  tooCold('Слишком холодно'),
  @JsonValue('just_right')
  justRight('В самый раз');

  const ThermalFeedback(this.displayName);
  final String displayName;

  static ThermalFeedback? fromString(String? value) {
    if (value == null) return null;
    return ThermalFeedback.values.firstWhere(
      (e) => e.name == value.replaceAll('_', ''),
      orElse: () => justRight,
    );
  }
}
