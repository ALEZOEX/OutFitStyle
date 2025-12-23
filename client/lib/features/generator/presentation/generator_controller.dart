import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/recommendation_repository.dart';

class GeneratorState {
  final String occasion; // daily/date/office/walk...
  final bool isGenerating;
  final String? error;
  final Set<String> dismissed; // session-only

  const GeneratorState({
    required this.occasion,
    required this.isGenerating,
    required this.dismissed,
    this.error,
  });

  GeneratorState copyWith({
    String? occasion,
    bool? isGenerating,
    String? error,
    Set<String>? dismissed,
  }) {
    return GeneratorState(
      occasion: occasion ?? this.occasion,
      isGenerating: isGenerating ?? this.isGenerating,
      dismissed: dismissed ?? this.dismissed,
      error: error,
    );
  }

  factory GeneratorState.initial() => const GeneratorState(
        occasion: 'daily',
        isGenerating: false,
        dismissed: <String>{},
        error: null,
      );
}

final recommendationHistoryProvider =
    StreamProvider.autoDispose<List<RecommendationRow>>((ref) {
  final repo = ref.watch(recommendationRepositoryProvider);
  return repo.watchHistory(limit: 60);
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
    data: (list) => list.where((r) => !dismissed.contains(r.id)).take(3).toList(),
    orElse: () => const <RecommendationRow>[],
  );
});

class GeneratorController extends AutoDisposeNotifier<GeneratorState> {
  @override
  GeneratorState build() => GeneratorState.initial();

  RecommendationRepository get _repo => ref.read(recommendationRepositoryProvider);

  Future<void> bootstrap() async {
    // Подтягиваем историю (в БД), UI сразу покажет кэш.
    // Локальное покажется сразу, сеть — best effort.
    try { await _repo.syncHistory(pages: 1, limit: 20); } catch (_) {}
    // Если после синка колода пустая — создаём одну карточку.
    final current = ref.read(generatorCurrentCardProvider);
    if (current == null) {
      await generate();
    }
  }

  void setOccasion(String occasion) {
    state = state.copyWith(occasion: occasion, error: null);
  }

  Future<void> generate() async {
    if (state.isGenerating) return;
    state = state.copyWith(isGenerating: true, error: null);

    try {
      await _repo.createNew(occasion: state.occasion);
    } catch (e) {
      // Не показываем ошибку пользователю, т.к. у нас есть локальные данные
      // Вместо этого просто логируем (в реальном приложении - в систему логирования)
      // ignore: avoid_print
      print('Network error during generate: $e');
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<void> like(RecommendationRow r) async {
    try {
      await _repo.toggleFavorite(r);
    } catch (e) {
      // Не показываем ошибку пользователю, т.к. UI уже обновился оптимистично
      // Ошибка будет обработана через outbox
      // ignore: avoid_print
      print('Network error during like: $e');
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
    final current = ref.read(generatorCurrentCardProvider);
    if (current == null && !state.isGenerating) {
      // не await: UI не должен "виснуть"
      generate();
    }
  }
}