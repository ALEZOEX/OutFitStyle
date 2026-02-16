import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/states/generator_state.dart';
import '../../../../data/repositories/recommendations_repository.dart';

/// Контроллер генератора нарядов
class GeneratorController extends StateNotifier<GeneratorState> {
  final RecommendationsRepository _recommendationsRepository;

  GeneratorController({required RecommendationsRepository recommendationsRepository})
      : _recommendationsRepository = recommendationsRepository,
        super(const GeneratorState());

  /// Генерация наряда на основе параметров
  Future<void> generateOutfit({
    required double latitude,
    required double longitude,
    required String occasion,
    required List<String> preferredStyles,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final recommendation = await _recommendationsRepository.generateRecommendation(
        excludedItems: [],
        latitude: latitude,
        longitude: longitude,
        occasion: occasion,
        preferredStyles: preferredStyles,
        userId: userId,
      );

      state = state.copyWith(
        isLoading: false,
        generatedOutfit: recommendation.toJson(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}