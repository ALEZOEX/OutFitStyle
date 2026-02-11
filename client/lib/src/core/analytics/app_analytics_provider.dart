import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_analytics_service.dart';
import 'analytics_providers.dart';

/// Провайдер для сервиса аналитики приложения
final appAnalyticsServiceProvider = Provider<AppAnalyticsService>((ref) {
  final combinedAnalyticsService = ref.watch(analyticsServiceProvider);
  return AppAnalyticsService(combinedAnalyticsService);
});
