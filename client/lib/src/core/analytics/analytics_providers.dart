import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import 'combined_analytics_service.dart';
import 'firebase_analytics_service.dart';
import 'local_analytics_service.dart';
import 'local_analytics_database.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Провайдеры для сервисов аналитики

/// Провайдер для локального хранилища аналитики
final localAnalyticsStorageProvider = Provider<LocalAnalyticsStorage>((ref) {
  return LocalAnalyticsStorage();
});

/// Провайдер для Dio клиента аналитики
final analyticsDioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

/// Провайдер для сервиса локальной аналитики
final localAnalyticsServiceProvider = Provider<LocalAnalyticsService>((ref) {
  return LocalAnalyticsService(
    storage: ref.watch(localAnalyticsStorageProvider),
    dio: ref.watch(analyticsDioProvider),
    connectivity: Connectivity(),
  );
});

/// Провайдер для Firebase сервиса аналитики
final firebaseAnalyticsServiceProvider =
    Provider<FirebaseAnalyticsService>((ref) {
  return FirebaseAnalyticsService();
});

/// Провайдер для комбинированного сервиса аналитики
final analyticsServiceProvider = Provider<CombinedAnalyticsService>((ref) {
  return CombinedAnalyticsService(
    firebaseService: ref.watch(firebaseAnalyticsServiceProvider),
    localService: ref.watch(localAnalyticsServiceProvider),
  );
});
