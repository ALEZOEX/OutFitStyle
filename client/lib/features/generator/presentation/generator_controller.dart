import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/generator_state.dart';
import '../../../app/di.dart';

class GeneratorController extends StateNotifier<GeneratorState> {
  final Ref _ref;

  GeneratorController(this._ref) : super(const GeneratorState());

  Future<void> bootstrap() async {
    // Initialize the generator
  }

  Future<void> resetDeck() async {
    // Reset the generator deck
    _ref.read(generatorDeckProvider.notifier).update((state) => []);
    // Also reset the state
    state = state.copyWith(dismissed: <String>{});
  }

  Future<void> setOccasion(String occasion) async {
    state = state.copyWith(occasion: occasion);
  }

  Future<void> generate() async {
    state = state.copyWith(isGenerating: true);
    try {
      // Логика генерации аутфита
      final repo = _ref.read(recommendationsRepositoryProvider);
      final occasion = state.occasion;

      // Получаем рекомендации
      final recommendations = await repo.getRecommendationsForOccasion(occasion);

      // Обновляем колоду
      _ref.read(generatorDeckProvider.notifier).update((state) {
        return [...state, ...recommendations.where((rec) => !state.any((existing) => existing.id == rec.id))];
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<void> like(String recommendationId) async {
    // Логика лайка
    final repo = _ref.read(recommendationsRepositoryProvider);
    await repo.updateFavoriteStatus(recommendationId, true);

    // Удаляем из колоды
    _removeFromDeck(recommendationId);
  }

  Future<void> dislike(String recommendationId) async {
    // Логика дизлайка
    final repo = _ref.read(recommendationsRepositoryProvider);
    await repo.updateFavoriteStatus(recommendationId, false);

    // Удаляем из колоды
    _removeFromDeck(recommendationId);
  }

  void _removeFromDeck(String recommendationId) {
    // Добавляем в список отклоненных
    state = state.copyWith(dismissed: {...state.dismissed, recommendationId});

    // Удаляем из колоды
    _ref.read(generatorDeckProvider.notifier).update((state) {
      return state.where((item) => item.id != recommendationId).toList();
    });
  }
}
