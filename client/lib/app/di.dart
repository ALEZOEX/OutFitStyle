import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
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
  // Передаём baseUrl без /api/v1 - сервис сам добавит
  return WardrobeService(baseUrl: cfg.apiBase, authStorage: auth);
});

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final cfg = ref.watch(apiConfigProvider);
  final auth = ref.watch(authStorageProvider);
  // Передаём baseUrl без /api/v1 - сервис сам добавит
  return RecommendationService(baseUrl: cfg.apiBase, authStorage: auth);
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
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    ref.watch(apiConfigProvider),
    ref.watch(authStorageProvider),
  );
});

final outboxPendingCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.syncOutboxDao.watchPendingCount();
});

enum SessionStatus { unknown, authed, guest }

final sessionProvider = NotifierProvider<SessionController, SessionStatus>(SessionController.new);

class SessionController extends Notifier<SessionStatus> {
  @override
  SessionStatus build() {
    _load();
    return SessionStatus.unknown;
  }

  Future<void> _load() async {
    final repo = ref.read(authRepositoryProvider);
    state = (await repo.isAuthed()) ? SessionStatus.authed : SessionStatus.guest;
  }

  Future<void> refreshSession() async {
    final repo = ref.read(authRepositoryProvider);
    state = (await repo.isAuthed()) ? SessionStatus.authed : SessionStatus.guest;
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = SessionStatus.guest;
  }
}