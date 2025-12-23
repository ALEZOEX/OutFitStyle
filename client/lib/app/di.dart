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
import 'onboarding/onboarding_storage.dart';
import 'session/session_controller.dart';

final apiConfigProvider = Provider((ref) => Env.apiConfig());

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final cfg = ref.watch(apiConfigProvider);
  final storage = ref.watch(authStorageProvider);
  return ApiClient(config: cfg, storage: storage, enableLogging: false);
});

final wardrobeServiceProvider = Provider<WardrobeService>((ref) {
  final cfg = ref.watch(apiConfigProvider);
  final auth = ref.watch(authStorageProvider);
  return WardrobeService(baseUrl: cfg.apiBase.toString(), authStorage: auth);
});

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final cfg = ref.watch(apiConfigProvider);
  final auth = ref.watch(authStorageProvider);
  return RecommendationService(baseUrl: cfg.apiBase.toString(), authStorage: auth);
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

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(authStorageProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) => OnboardingStorage());

final outboxPendingCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.syncOutboxDao.watchPendingCount();
});