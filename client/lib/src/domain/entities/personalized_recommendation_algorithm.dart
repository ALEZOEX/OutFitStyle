import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'personalized_recommendation_algorithm.freezed.dart';
part 'personalized_recommendation_algorithm.g.dart';

@freezed
abstract class PersonalizedRecommendationAlgorithm
    with _$PersonalizedRecommendationAlgorithm {
  const factory PersonalizedRecommendationAlgorithm({
    @Default('') String id,
    @Default('') String name,
    @Default('') String description,
    @Default(RecommendationAlgorithmType.collaborativeFiltering)
    RecommendationAlgorithmType type,
    @Default(0.0) double accuracy,
    @Default(0.0) double precision,
    @Default(0.0) double recall,
    @Default(0.0) double f1Score,
    @Default(<String>[]) List<String> featuresUsed,
    @Default(<String>[]) List<String> weights, // feature weights
    @Default(PersonalizationLevel.high)
    PersonalizationLevel personalizationLevel,
    @Default(0) int trainingSamples,
    @Default(false) bool isActive,
    @Default(false) bool isDefault,
    @Default(<String>[]) List<String> tags,
    @Default('') String dummyField, // Workaround for DateTime default issue
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PersonalizedRecommendationAlgorithm;

  factory PersonalizedRecommendationAlgorithm.empty() =>
      PersonalizedRecommendationAlgorithm(
        id: Uuid().v4(),
        name: 'Default Algorithm',
        description: 'Default recommendation algorithm',
        type: RecommendationAlgorithmType.collaborativeFiltering,
        accuracy: 0.0,
        precision: 0.0,
        recall: 0.0,
        f1Score: 0.0,
        featuresUsed: const [],
        weights: const [],
        personalizationLevel: PersonalizationLevel.high,
        trainingSamples: 0,
        isActive: true,
        isDefault: true,
        tags: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  factory PersonalizedRecommendationAlgorithm.fromJson(
    Map<String, dynamic> json,
  ) => _$PersonalizedRecommendationAlgorithmFromJson(json);
}

enum RecommendationAlgorithmType {
  collaborativeFiltering('Коллаборативная фильтрация'),
  contentBased('Контент-базированная'),
  matrixFactorization('Факторизация матрицы'),
  deepLearning('Глубокое обучение'),
  hybrid('Гибридная'),
  knowledgeBased('Знание-ориентированная'),
  demographicFiltering('Демографическая фильтрация'),
  popularityBased('На основе популярности');

  const RecommendationAlgorithmType(this.displayName);
  final String displayName;
}

enum PersonalizationLevel {
  low('Низкая'),
  medium('Средняя'),
  high('Высокая'),
  extreme('Экстремальная');

  const PersonalizationLevel(this.displayName);
  final String displayName;
}
