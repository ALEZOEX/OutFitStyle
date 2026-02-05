import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/auth_storage.dart';
import '../domain/services/recommendations_domain_service.dart';
import '../domain/services/wardrobe_domain_service.dart'; // Обновленный импорт
import '../domain/entities/recommendation_entity.dart';
import '../domain/entities/wardrobe_entity.dart' as domain;
import 'env.dart';
import 'api/api_client.dart';
import 'session.dart';

import '../data/local/app_database.dart';
import '../data/remote/wardrobe_remote_ds.dart';
import '../data/remote/recommendations_remote_ds.dart';
import '../data/repositories/wardrobe_repository.dart';
import '../data/repositories/recommendations_repository.dart'; // Обновленный импорт
import '../data/sync/sync_worker.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/image_store.dart';
import '../features/recommendations/presentation/recommendations_controller.dart';
import '../features/wardrobe/presentation/wardrobe_controller.dart';
import '../features/admin/presentation/admin_controller.dart';
import '../features/profile/presentation/profile_controller.dart';
import '../features/generator/presentation/generator_controller.dart';
import '../domain/states/generator_state.dart';
import '../features/settings/presentation/settings_controller.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/onboarding/presentation/onboarding_controller.dart';
import '../storage/local_storage.dart';
import '../domain/states/recommendations_state.dart';
import '../domain/states/wardrobe_state.dart';
import '../domain/states/settings_state.dart';
import '../domain/states/auth_state.dart';
import '../domain/states/onboarding_state.dart';
import '../domain/states/profile_state.dart';
import '../domain/states/ui_states.dart'; // Contains AdminState

final apiConfigProvider = Provider((ref) => Env.apiConfig());

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

final imageStoreProvider = Provider<ImageStore>((ref) {
  return ImageStore();
});

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final cfg = ref.watch(apiConfigProvider);
  final storage = ref.watch(authStorageProvider);
  return ApiClient(config: cfg, storage: storage);
});

// AdminService is not defined, commenting out for now
// final adminServiceProvider = Provider<AdminService>((ref) {
//   final cfg = ref.watch(apiConfigProvider);
//   final auth = ref.watch(authStorageProvider);
//   return AdminService(cfg, auth, http.Client());
// });

final wardrobeRemoteDsProvider = Provider<WardrobeRemoteDataSource>((ref) {
  return WardrobeRemoteDataSource(ref.watch(apiClientProvider));
});

final recommendationsRemoteDsProvider =
    Provider<RecommendationsRemoteDataSource>((ref) {
  return RecommendationsRemoteDataSource(
      ref.watch(apiClientProvider));
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(wardrobeRemoteDsProvider),
  );
});

final recommendationsRepositoryProvider =
    Provider<RecommendationsRepository>((ref) {
  return RecommendationsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(recommendationsRemoteDsProvider),
  );
});

final recommendationsDomainServiceProvider =
    Provider<RecommendationsDomainService>((ref) {
  return RecommendationsDomainService(
    ref.watch(recommendationsRepositoryProvider),
  );
});

final wardrobeDomainServiceProvider = Provider<WardrobeDomainService>((ref) {
  return WardrobeDomainService(
    ref.watch(wardrobeRepositoryProvider),
  );
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  return SyncWorker(
    db: ref.watch(appDatabaseProvider),
    wardrobeRemote: ref.watch(wardrobeRemoteDsProvider),
    recRemote: ref.watch(recommendationsRemoteDsProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = AuthRepository(
    ref.watch(apiConfigProvider),
    ref.watch(authStorageProvider),
    http.Client(),
  );

  ref.onDispose(() => repo.dispose());

  return repo;
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final repo = ProfileRepository(
    ref.watch(apiConfigProvider),
    ref.watch(authStorageProvider),
    http.Client(),
  );

  ref.onDispose(() => repo.dispose());

  return repo;
});

final outboxPendingCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.syncOutboxDao.watchPendingCount();
});

// Добавляем недостающие провайдеры для контроллеров
final recommendationsControllerProvider =
    StateNotifierProvider<RecommendationsController, RecommendationsState>(
        (ref) {
  return RecommendationsController(ref);
});

final wardrobeStreamProvider = StreamProvider<List<domain.WardrobeEntry>>((ref) {
  final repo = ref.watch(wardrobeRepositoryProvider);
  return repo.watchWardrobe(); // По умолчанию не включает архивные элементы
});

final wardrobeControllerProvider =
    StateNotifierProvider<WardrobeController, WardrobeState>((ref) {
  return WardrobeController(ref);
});


final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

final localStorageProvider = Provider((ref) {
  return LocalStorage.prefs;
});

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController();
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController();
});

final generatorControllerProvider =
    StateNotifierProvider<GeneratorController, GeneratorState>((ref) {
  return GeneratorController(ref);
});

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  return AdminController();
});

// Добавляем недостающие провайдеры

// Провайдер для сегодняшних рекомендаций
final homeTodayRecProvider = StreamProvider<List<RecommendationRow>>((ref) {
  final repo = ref.watch(recommendationsRepositoryProvider);
  return repo.watchTodayLatest().map((rec) {
    if (rec != null) {
      return [rec];
    } else {
      // Если нет сегодняшней рекомендации, возвращаем пустой список
      return [];
    }
  });
});

// Провайдер для потока рекомендаций
final recommendationsStreamProvider = StreamProvider<List<RecommendationRow>>((ref) {
  final repo = ref.watch(recommendationsRepositoryProvider);
  return repo.watchHistory(limit: 50); // Ограничиваем количество для производительности
});

// Провайдеры для профиля пользователя
final meProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  try {
    return await repo.getMe();
  } catch (e) {
    // Возвращаем null или заглушку в случае ошибки
    return null;
  }
});

final isAdminProvider = FutureProvider.autoDispose((ref) async {
  final user = await ref.watch(meProvider.future);
  // В реальном приложении проверка админских прав будет зависеть от структуры пользователя
  // Здесь используем простую проверку - если email содержит 'admin'
  return user != null && (user['role'] == 'admin' || user['email']?.contains('admin') == true);
});

// Провайдер для управления темой
final themeModeProvider = StateProvider((ref) => ThemeMode.system);

// Провайдеры для онбординга
final onboardingStorageProvider = Provider((ref) => LocalStorage.prefs);

final onboardingDoneProvider = StateProvider<bool>((ref) {
  // Получаем значение из хранилища
  final storage = ref.watch(onboardingStorageProvider);
  return storage.getBool('onboarding_done') ?? false;
});

// Административные провайдеры
final adminStatsProvider = FutureProvider.autoDispose((ref) async {
  final controller = ref.watch(adminControllerProvider.notifier);
  // Вызываем метод контроллера для получения статистики
  return await controller.getStats();
});

final adminUsersProvider = FutureProvider.autoDispose((ref) async {
  final controller = ref.watch(adminControllerProvider.notifier);
  // Вызываем метод контроллера для получения пользователей
  return await controller.getUsers();
});

// Провайдер для генератора образов
final generatorDeckProvider = StateProvider<List<RecommendationRow>>((ref) => []);

final sessionProvider =
    NotifierProvider<SessionController, SessionStatus>(SessionController.new);

class SessionController extends Notifier<SessionStatus> {
  @override
  SessionStatus build() {
    _load();
    return SessionStatus.unknown;
  }

  Future<void> _load() async {
    final repo = ref.read(authRepositoryProvider);
    final isAuthenticated = await repo.isAuthed();

    if (isAuthenticated) {
      // Если пользователь уже аутентифицирован, проверяем валидность токена
      try {
        // Попробуем выполнить silent login для проверки токена
        final authService = AuthService(
          apiBase: ref.read(apiConfigProvider).apiBase,
          authStorage: ref.read(authStorageProvider),
          httpClient: http.Client(),
        );
        await authService.silentLogin();
        state = SessionStatus.authed;
      } catch (e) {
        // Если токен недействителен, сбрасываем сессию
        await ref.read(authStorageProvider).clearSession();
        state = SessionStatus.unknown;
      }
    } else {
      state = SessionStatus.unknown; // Вместо guest используем unknown
    }
  }

  Future<void> refreshSession() async {
    final repo = ref.read(authRepositoryProvider);
    state =
        (await repo.isAuthed()) ? SessionStatus.authed : SessionStatus.unknown;
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = SessionStatus.unknown; // Вместо guest используем unknown
  }
}
