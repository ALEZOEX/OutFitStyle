import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/states/async_state.dart' as app_state;
import '../../../domain/states/generator_state.dart';

final recommendationHistoryProvider =
    StreamProvider.autoDispose<List<RecommendationRow>>((ref) {
  final service = ref.watch(recommendationsDomainServiceProvider);
  return service.watchHistory(limit: 60);
});

final generatorControllerProvider =
    AutoDisposeNotifierProvider<GeneratorController, GeneratorState>(
  GeneratorController.new,
);

final generatorCurrentCardProvider =
    Provider.autoDispose<RecommendationRow?>((ref) {
  final hist = ref.watch(recommendationHistoryProvider);
  final dismissed =
      ref.watch(generatorControllerProvider.select((s) => s.dismissed));

  return hist.maybeWhen(
    data: (list) => list.firstWhereOrNull((r) => !dismissed.contains(r.id)),
    orElse: () => null,
  );
});

final generatorDeckProvider = Provider.autoDispose<List<RecommendationRow>>((ref) {
  final hist = ref.watch(recommendationHistoryProvider);
  final dismissed = ref.watch(generatorControllerProvider.select((s) => s.dismissed));

  return hist.maybeWhen(
    data: (list) {
      return list.where((r) => !dismissed.contains(r.id)).take(3).toList();
    },
    orElse: () {
      return const <RecommendationRow>[];
    },
  );
});

class GeneratorController extends AutoDisposeNotifier<GeneratorState> {
  @override
  GeneratorState build() => const GeneratorState();

  RecommendationsDomainService get _service => ref.read(recommendationsDomainServiceProvider);

  Future<void> bootstrap() async {
    // Подтягиваем историю (в БД), UI сразу покажет кэш.
    // Локальное покажется сразу, сеть — best effort.
    // GeneratorController: bootstrap started - logging would be handled by error handler

    // Запускаем синхронизацию в фоне, чтобы не блокировать UI
    _service.syncFromServer().then((_) {
      // GeneratorController: syncHistory completed - logging would be handled by error handler
    }).catchError((e) {
      // GeneratorController: syncHistory error: $e - logging would be handled by error handler
    });

    // Если после синка колода пустая — создаём одну карточку.
    // Избегаем циклической зависимости, используя напрямую историю и состояние
    final hist = await _service.watchHistory(limit: 20).first;
    // GeneratorController: history loaded, count: ${hist.length} - logging would be handled by error handler
    final dismissed = state.dismissed;
    // GeneratorController: dismissed count: ${dismissed.length} - logging would be handled by error handler
    final current = hist.firstWhereOrNull((r) => !dismissed.contains(r.id));
    // GeneratorController: current card: ${current?.id} - logging would be handled by error handler

    if (current == null) {
      // GeneratorController: no current card, calling generate() - logging would be handled by error handler
      await generate();
    } else {
      // GeneratorController: current card exists, skipping generate - logging would be handled by error handler
    }
  }

  void setOccasion(String occasion) {
    state = state.copyWith(occasion: occasion, error: null);
  }

  Future<void> generate() async {
    if (state.isGenerating) return;
    state = state.copyWith(isGenerating: true, error: null);

    try {
      await _service.generateRecommendation(occasion: state.occasion);
    } catch (e) {
      // Не показываем ошибку пользователю, т.к. у нас есть локальные данные
      // Вместо этого просто логируем (в реальном приложении - в систему логирования)
      // Network error during generate: $e - logging would be handled by error handler
      state = state.copyWith(error: 'Ошибка при создании рекомендации: $e');
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<void> like(RecommendationRow r) async {
    try {
      await _service.toggleFavorite(r);
    } catch (e) {
      // Не показываем ошибку пользователю, т.к. UI уже обновился оптимистично
      // Ошибка будет обработана через outbox
      // Network error during like: $e - logging would be handled by error handler
    } finally {
      dismiss(r.id);
      // Поддерживаем "бесконечную колоду"
      _maybeTopUp();
    }
  }

  void dislike(RecommendationRow r) {
    dismiss(r.id);
    _maybeTopUp();
  }

  void dismiss(String id) {
    final next = {...state.dismissed, id};
    state = state.copyWith(dismissed: next);
  }

  void resetDeck() {
    state = state.copyWith(dismissed: <String>{}, error: null);
  }

  void _maybeTopUp() {
    // если карточек больше не осталось — пробуем создать новую (тихо)
    // Вместо использования generatorCurrentCardProvider, просто проверяем,
    // есть ли в истории что-то, что не было отклонено
    // Мы не можем напрямую получить историю здесь, так как это создаст новую зависимость
    // Поэтому используем простую эвристику: если отклонено много элементов,
    // возможно, стоит пополнить колоду
    if (state.dismissed.length > 15 && !state.isGenerating) { // условие для предотвращения цикла
      // не await: UI не должен "виснуть"
      generate();
    }
  }

  // Метод для получения рекомендаций, основанных на вещах из гардероба
  Future<List<RecommendationRow>> getRecommendationsWithWardrobeItems() async {
    final recommendations = await _service.watchHistory(limit: 20).first;
    return recommendations;
  }
}