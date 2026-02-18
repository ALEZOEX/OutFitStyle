import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'recommendation_feedback.freezed.dart';
part 'recommendation_feedback.g.dart';

@freezed
abstract class RecommendationFeedback with _$RecommendationFeedback {
  const factory RecommendationFeedback({
    @Default('') String id,
    @Default('') String userId,
    @Default('') String recommendationId,
    @Default(0) int rating, // 1-5 stars
    @Default(<String>[]) List<String> tags, // positive, negative, neutral tags
    @Default('') String comment,
    @Default(<String>[])
    List<String> likedItems, // specific items in the outfit that were liked
    @Default(<String>[])
    List<String>
        dislikedItems, // specific items in the outfit that were disliked
    @Default(false) bool wouldReuse,
    @Default(false) bool wouldRecommend,
    @Default(<String>[]) List<String> improvementSuggestions,
    @Default(FeedbackCategory.general) FeedbackCategory category,
    @Default(FeedbackSource.user) FeedbackSource source,
    @Default('') String dummyField, // Workaround for DateTime default issue
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RecommendationFeedback;

  factory RecommendationFeedback.empty() => RecommendationFeedback(
        id: Uuid().v4(),
        userId: '',
        recommendationId: '',
        rating: 0,
        tags: const [],
        comment: '',
        likedItems: const [],
        dislikedItems: const [],
        wouldReuse: false,
        wouldRecommend: false,
        improvementSuggestions: const [],
        category: FeedbackCategory.general,
        source: FeedbackSource.user,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  factory RecommendationFeedback.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFeedbackFromJson(json);
}

enum FeedbackCategory {
  accuracy('Точность рекомендаций'),
  style('Стиль'),
  comfort('Комфорт'),
  weatherMatch('Соответствие погоде'),
  occasionMatch('Соответствие случаю'),
  price('Цена'),
  availability('Доступность'),
  general('Общее');

  const FeedbackCategory(this.displayName);
  final String displayName;
}

enum FeedbackSource {
  user('Пользователь'),
  system('Система'),
  ai('AI анализ');

  const FeedbackSource(this.displayName);
  final String displayName;
}
