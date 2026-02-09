import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/domain/entities/outfit_recommendation.dart';
import 'package:outfitstyle_client/domain/states/generator_state.dart';

class GeneratorController extends StateNotifier<GeneratorState> {
  final Ref _ref;

  GeneratorController(this._ref) : super(GeneratorInitial());

  Future<void> generateOutfit({
    required String occasion,
    required double temperature,
    required String weatherCondition,
  }) async {
    state = GeneratorLoading();
    try {
      // In a real implementation, we would call a service to generate an outfit
      // For now, we'll simulate the result
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock recommendation
      final mockRecommendation = OutfitRecommendation(
        id: 'mock-id-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current-user',
        occasion: occasion,
        temperature: temperature,
        weatherCondition: weatherCondition,
        recommendedItems: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      );
      
      state = GeneratorSuccess(mockRecommendation);
    } catch (e) {
      state = GeneratorError(e.toString());
    }
  }
}