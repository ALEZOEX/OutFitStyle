import 'package:outfitstyle_client/src/domain/entities/recommendation.dart';
import 'package:outfitstyle_client/src/domain/repositories/recommendation_repository.dart';

/// UseCase для сохранения рекомендаций
class SaveRecommendationUseCase {
  final RecommendationRepository _repository;

  SaveRecommendationUseCase(this._repository);

  /// Сохранить рекомендацию
  Future<void> call(Recommendation recommendation) async {
    await _repository.saveRecommendation(recommendation);
  }
}
