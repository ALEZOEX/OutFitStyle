import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';
import '../services/wardrobe_service.dart';
import '../services/recommendation_service.dart';
import 'env.dart';
import 'api/api_client.dart';

import '../data/local/app_database.dart';
import '../data/remote/wardrobe_remote_ds.dart';
import '../data/remote/recommendation_remote_ds.dart';
import '../data/repositories/wardrobe_repository.dart';
import '../data/repositories/recommendation_repository.dart';
import '../data/sync/sync_worker.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import 'onboarding/onboarding_providers.dart';

final apiConfigProvider = Provider((ref) => Env.apiConfig());

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final cfg = ref.watch(apiConfigProvider);
  final storage = ref.watch(authStorageProvider);
  return ApiClient(config: cfg, storage: storage);
});

final wardrobeServiceProvider = Provider<WardrobeService>((ref) {
  final cfg = ref.watch(apiConfigProvider);
  final auth = ref.watch(authStorageProvider);
  return WardrobeService(apiConfig: cfg, authStorage: auth, httpClient: http.Client());
});

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final cfg = ref.watch(apiConfigProvider);
  final auth = ref.watch(authStorageProvider);
  return RecommendationService(apiConfig: cfg, authStorage: auth, httpClient: http.Client());
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final wardrobeRemoteDsProvider = Provider<WardrobeRemoteDataSource>((ref) {
  return WardrobeRemoteDataSource(ref.watch(wardrobeServiceProvider));
});

final recommendationRemoteDsProvider = Provider<RecommendationRemoteDataSource>((ref) {
  return RecommendationRemoteDataSource(ref.watch(recommendationServiceProvider));
});

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepository(
    db: ref.watch(appDatabaseProvider),
    remote: ref.watch(wardrobeRemoteDsProvider),
  );
});

final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  return RecommendationRepository(
    db: ref.watch(appDatabaseProvider),
    remote: ref.watch(recommendationRemoteDsProvider),
  );
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  return SyncWorker(
    db: ref.watch(appDatabaseProvider),
    wardrobeRemote: ref.watch(wardrobeRemoteDsProvider),
    recRemote: ref.watch(recommendationRemoteDsProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiConfigProvider),
    ref.watch(authStorageProvider),
    http.Client(),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    ref.watch(apiConfigProvider),
    ref.watch(authStorageProvider),
    http.Client(),
  );
});

final outboxPendingCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.syncOutboxDao.watchPendingCount();
});

enum SessionStatus { unknown, authed } // Убрали guest режим

final sessionProvider = NotifierProvider<SessionController, SessionStatus>(SessionController.new);

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
        state = SessionStatus.unknown; // Вместо guest используем unknown
      }
    } else {
      state = SessionStatus.unknown; // Вместо guest используем unknown
    }
  }

  Future<void> refreshSession() async {
    final repo = ref.read(authRepositoryProvider);
    state = (await repo.isAuthed()) ? SessionStatus.authed : SessionStatus.unknown;
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = SessionStatus.unknown; // Вместо guest используем unknown
  }
}