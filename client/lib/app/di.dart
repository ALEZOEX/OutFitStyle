import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../core/services/auth_service.dart';
import '../core/services/auth_storage.dart';
import '../domain/services/recommendations_domain_service.dart';
import '../domain/services/wardrobe_domain_service.dart';
import '../domain/entities/outfit_recommendation.dart';
import '../domain/entities/wardrobe.dart';
import '../domain/repositories/i_wardrobe_repository.dart';
import '../domain/repositories/i_recommendations_repository.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_weather_repository.dart';
import 'env.dart';
import 'api/api_config.dart'; // Updated import
import '../data/remote/api_client.dart' hide ApiConfig;
import 'session.dart';

import '../data/local/app_database.dart';
import '../data/datasources/remote/wardrobe_remote_datasource.dart';
import '../data/datasources/remote/recommendations_remote_datasource.dart';
import '../data/datasources/remote/weather_remote_datasource.dart';
import '../data/repositories/wardrobe_repository.dart';
import '../data/repositories/recommendations_repository.dart';
import '../data/repositories/weather_repository.dart';
import '../data/sync/sync_worker.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../core/services/image_store.dart';
import '../features/recommendations/presentation/controllers/recommendations_controller.dart';
import '../features/wardrobe/presentation/controllers/wardrobe_controller.dart';
import '../features/admin/presentation/controllers/admin_controller.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import '../features/generator/presentation/controllers/generator_controller.dart';
import '../domain/states/generator_state.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../core/storage/local_storage.dart';
import '../domain/states/recommendations_state.dart';
import '../domain/states/wardrobe_state.dart';
import '../domain/states/settings_state.dart';
import '../domain/states/auth_state.dart';
import '../domain/states/onboarding_state.dart';
import '../domain/states/profile_state.dart';
import '../domain/states/admin_state.dart';

final apiConfigProvider = Provider<ApiConfig>((ref) => Env.apiConfig());

final loggerProvider = Provider((ref) => Logger());

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

final weatherRemoteDsProvider = Provider<IWeatherRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WeatherRemoteDataSource(apiClient);
});

final wardrobeRemoteDsProvider = Provider<IWardrobeRemoteDataSource>((ref) {
  return WardrobeRemoteDataSource(ref.watch(apiClientProvider));
});

final recommendationsRemoteDsProvider =
    Provider<IRecommendationsRemoteDataSource>((ref) {
  return RecommendationsRemoteDataSource(
      ref.watch(apiClientProvider));
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final weatherRepositoryProvider = Provider<IWeatherRepository>((ref) {
  return WeatherRepository(
    apiClient: ref.watch(apiClientProvider),
    sharedPreferences: ref.watch(sharedPreferencesProvider.future),
  );
});

final wardrobeRepositoryProvider = Provider<IWardrobeRepository>((ref) {
  return WardrobeRepository(
    apiClient: ref.watch(apiClientProvider),
  );
});

final recommendationsRepositoryProvider =
    Provider<IRecommendationsRepository>((ref) {
  return RecommendationsRepository(
    apiClient: ref.watch(apiClientProvider),
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

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final repo = AuthRepository(
    ref.watch(apiConfigProvider),
    ref.watch(authStorageProvider),
    http.Client(),
  );

  ref.onDispose(() => (repo as AuthRepository).dispose());

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

// Добавляем недостающие провайдеры для контроллеров
final recommendationsControllerProvider =
    StateNotifierProvider<RecommendationsController, RecommendationsState>(
        (ref) {
  return RecommendationsController(ref);
});

final wardrobeStreamProvider = StreamProvider<List<WardrobeItem>>((ref) {
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

final localStorageProvider = Provider((ref) async {
  await LocalStorage.init(); // Initialize LocalStorage
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
final onboardingStorageProvider = Provider((ref) async {
  await LocalStorage.init(); // Initialize LocalStorage
  return LocalStorage.prefs;
});

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
