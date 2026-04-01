import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/states/generator_state.dart';
import '../../../../data/repositories/recommendations_repository.dart';
import '../../../../utils/logger.dart';

/// Контроллер генератора нарядов
class GeneratorController extends StateNotifier<GeneratorState> {
  final RecommendationsRepository _recommendationsRepository;

  GeneratorController({
    required RecommendationsRepository recommendationsRepository,
  }) : _recommendationsRepository = recommendationsRepository,
       super(const GeneratorState());

  /// Генерация наряда на основе параметров
  Future<void> generateOutfit({
    required double latitude,
    required double longitude,
    required String occasion,
    required List<String> preferredStyles,
    required String userId,
  }) async {
    AppLogger.info('[GeneratorController] generateOutfit вызван');
    AppLogger.info('[GeneratorController] latitude: $latitude, longitude: $longitude');
    AppLogger.info('[GeneratorController] occasion: $occasion, preferredStyles: $preferredStyles');
    AppLogger.info('[GeneratorController] userId: $userId');
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      AppLogger.info('[GeneratorController] Вызов recommendationsRepository.generateRecommendation...');
      final recommendation = await _recommendationsRepository
          .generateRecommendation(
            excludedItems: [],
            latitude: latitude,
            longitude: longitude,
            occasion: occasion,
            preferredStyles: preferredStyles,
            userId: userId,
          );

      AppLogger.info('[GeneratorController] Рекомендация получена: ${recommendation.toJson()}');
      state = state.copyWith(
        isLoading: false,
        generatedOutfit: recommendation.toJson(),
      );
      AppLogger.info('[GeneratorController] Состояние обновлено успешно');
    } catch (e, stackTrace) {
      AppLogger.error('[GeneratorController] Ошибка генерации: $e', e, stackTrace);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
