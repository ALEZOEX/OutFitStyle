import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import 'package:outfitstyle_client/src/features/onboarding/data/models/onboarding_data.dart';
import 'package:outfitstyle_client/src/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:outfitstyle_client/src/features/onboarding/onboarding_storage.dart';
import 'package:outfitstyle_client/src/storage/auth_storage.dart';

/// Провайдер хранилища онбординга
final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return OnboardingStorage();
});

/// Провайдер репозитория онбординга
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final authStorage = ref.read(authStorageProvider);
  final apiClient = ref.read(apiClientProvider);
  return OnboardingRepository(
    apiClient: apiClient,
    authStorage: authStorage,
  );
});

/// Провайдер состояния онбординга (завершён или нет)
final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final storage = ref.read(onboardingStorageProvider);
  return storage.isDone();
});

/// Провайдер для быстрой проверки статуса онбординга (синхронный)
final isOnboardingDoneProvider = Provider<bool>((ref) {
  final result = ref.watch(onboardingDoneProvider);
  return result.when(
    data: (done) => done,
    error: (_, __) => false,
    loading: () => false,
  );
});

/// Провайдер данных онбординга
final onboardingDataProvider = FutureProvider<OnboardingData?>((ref) async {
  final storage = ref.read(onboardingStorageProvider);
  return storage.getOnboardingData();
});

/// Состояние менеджера онбординга
class OnboardingState {
  final int currentPage;
  final OnboardingData data;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const OnboardingState({
    this.currentPage = 0,
    this.data = const OnboardingData(),
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  OnboardingState copyWith({
    int? currentPage,
    OnboardingData? data,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

/// Нотификер для управления состоянием онбординга
final onboardingNotifierProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(
    storage: ref.read(onboardingStorageProvider),
    repository: ref.read(onboardingRepositoryProvider),
  );
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final OnboardingStorage _storage;
  final OnboardingRepository _repository;

  OnboardingNotifier({
    required OnboardingStorage storage,
    required OnboardingRepository repository,
  })  : _storage = storage,
        _repository = repository,
        super(const OnboardingState());

  /// Переход на следующую страницу
  void nextPage() {
    if (state.currentPage < 4) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  /// Переход на предыдущую страницу
  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  /// Переход на конкретную страницу
  void goToPage(int page) {
    if (page >= 0 && page <= 4) {
      state = state.copyWith(currentPage: page);
    }
  }

  /// Установка города
  void setCity({
    required int cityId,
    required String cityName,
    required double cityLat,
    required double cityLon,
  }) {
    state = state.copyWith(
      data: state.data.copyWith(
        cityId: cityId,
        cityName: cityName,
        cityLat: cityLat,
        cityLon: cityLon,
      ),
    );
  }

  /// Добавление/удаление стиля
  void toggleStylePreference(String styleValue) {
    final currentStyles = List<String>.from(state.data.stylePreferences);
    if (currentStyles.contains(styleValue)) {
      currentStyles.remove(styleValue);
    } else {
      currentStyles.add(styleValue);
    }
    state = state.copyWith(
      data: state.data.copyWith(stylePreferences: currentStyles),
    );
  }

  /// Установка диапазона бюджета
  void setBudgetRange(String? budgetRange) {
    state = state.copyWith(
      data: state.data.copyWith(budgetRange: budgetRange),
    );
  }

  /// Установка любимых брендов
  void setFavoriteBrands(String brands) {
    state = state.copyWith(
      data: state.data.copyWith(favoriteBrands: brands),
    );
  }

  /// Проверка валидности текущей страницы
  bool get canProceed {
    switch (state.currentPage) {
      case 0: // Приветствие - всегда можно продолжить
        return true;
      case 1: // Город - обязателен
        return state.data.cityId != null;
      case 2: // Стили - минимум 3
        return state.data.stylePreferences.length >= 3;
      case 3: // Предпочтения - бюджет опционален
        return true;
      case 4: // Завершение
        return true;
      default:
        return false;
    }
  }

  /// Автоопределение города по IP
  Future<Map<String, dynamic>?> detectCityByIp() async {
    return _repository.detectCityByIp();
  }

  /// Завершение онбординга и отправка данных на сервер
  Future<bool> completeOnboarding() async {
    // Проверка валидности данных
    if (!state.data.isValid) {
      state = state.copyWith(error: 'Не все обязательные поля заполнены');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // Сохранение локально
      await _storage.saveOnboardingData(state.data);
      await _storage.setDone();

      // Отправка на сервер (не блокирующая, если ошибка - продолжаем)
      try {
        await _repository.savePreferences(state.data);
      } catch (e) {
        // Логируем ошибку, но не прерываем процесс
        print('[OnboardingNotifier] Ошибка отправки на сервер: $e');
      }

      state = state.copyWith(currentPage: 4, isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Ошибка сохранения: ${e.toString()}',
      );
      return false;
    }
  }

  /// Сброс состояния
  void reset() {
    state = const OnboardingState();
  }

  /// Очистка всех данных (для тестирования)
  Future<void> clearAll() async {
    await _storage.clearAll();
    reset();
  }
}
