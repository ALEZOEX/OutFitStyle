import 'analytics_event.dart';
import 'combined_analytics_service.dart';

/// Сервис аналитики приложения OutfitStyle
/// Обеспечивает централизованное управление событиями аналитики
class AppAnalyticsService {
  final CombinedAnalyticsService _analyticsService;

  AppAnalyticsService(this._analyticsService);

  /// Логирование просмотра рекомендации
  Future<void> logViewRecommendation({
    required String recommendationId,
    required String outfitType,
    required Map<String, dynamic> weatherData,
  }) async {
    final event = AnalyticsEvent.viewRecommendation(
      recommendationId: recommendationId,
      outfitType: outfitType,
      weatherData: weatherData,
    );
    await _analyticsService.logEvent(event);
  }

  /// Логирование принятия рекомендации
  Future<void> logAcceptRecommendation({
    required String recommendationId,
    required String outfitType,
    required Map<String, dynamic> weatherData,
  }) async {
    final event = AnalyticsEvent.acceptRecommendation(
      recommendationId: recommendationId,
      outfitType: outfitType,
      weatherData: weatherData,
    );
    await _analyticsService.logEvent(event);
  }

  /// Логирование отклонения рекомендации
  Future<void> logRejectRecommendation({
    required String recommendationId,
    required String outfitType,
    required Map<String, dynamic> weatherData,
  }) async {
    final event = AnalyticsEvent.rejectRecommendation(
      recommendationId: recommendationId,
      outfitType: outfitType,
      weatherData: weatherData,
    );
    await _analyticsService.logEvent(event);
  }

  /// Логирование оценки рекомендации
  Future<void> logRateRecommendation({
    required String recommendationId,
    required int rating,
    required String outfitType,
    required Map<String, dynamic> weatherData,
  }) async {
    final event = AnalyticsEvent.rateRecommendation(
      recommendationId: recommendationId,
      rating: rating,
      outfitType: outfitType,
      weatherData: weatherData,
    );
    await _analyticsService.logEvent(event);
  }

  /// Логирование просмотра гардероба
  Future<void> logViewWardrobe({
    required int itemCount,
    required List<String> categories,
  }) async {
    final event = AnalyticsEvent.viewWardrobe(
      itemCount: itemCount,
      categories: categories,
    );
    await _analyticsService.logEvent(event);
  }

  /// Логирование добавления вещи в гардероб
  Future<void> logAddToWardrobe({
    required String itemId,
    required String category,
    required String brand,
  }) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.addToWardrobe,
      properties: {
        'item_id': itemId,
        'category': category,
        'brand': brand,
      },
    );
    await _analyticsService.logEvent(event);
  }

  /// Логирование удаления вещи из гардероба
  Future<void> logRemoveFromWardrobe({
    required String itemId,
    required String category,
  }) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.removeFromWardrobe,
      properties: {
        'item_id': itemId,
        'category': category,
      },
    );
    await _analyticsService.logEvent(event);
  }

  /// Логирование обновления вещи в гардеробе
  Future<void> logUpdateWardrobeItem({
    required String itemId,
    required String category,
    required Map<String, dynamic> changes,
  }) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.updateWardrobeItem,
      properties: {
        'item_id': itemId,
        'category': category,
        'changes': changes,
      },
    );
    await _analyticsService.logEvent(event);
  }

  /// Логирование просмотра прогноза погоды
  Future<void> logWeatherForecastView({
    required String location,
    required Map<String, dynamic> forecastData,
  }) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.weatherForecastView,
      properties: {
        'location': location,
        'forecast_data': forecastData,
      },
    );
    await _analyticsService.logEvent(event);
  }

  /// Логирование обновления данных о погоде
  Future<void> logWeatherDataRefresh({
    required String location,
    required Map<String, dynamic> weatherData,
  }) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.weatherDataRefresh,
      properties: {
        'location': location,
        'weather_data': weatherData,
      },
    );
    await _analyticsService.logEvent(event);
  }

  /// Установить ID пользователя для аналитики
  Future<void> setUserId(String? userId) async {
    await _analyticsService.setUserId(userId);
  }

  /// Синхронизировать локальные события аналитики
  Future<void> syncLocalEvents() async {
    await _analyticsService.syncLocalEvents();
  }

  /// Получить количество неотправленных событий
  Future<int> getUnsentEventsCount() async {
    return await _analyticsService.getUnsentEventsCount();
  }
}
