/// Типы событий аналитики
enum AnalyticsEventType {
  // События, связанные с рекомендациями
  viewRecommendation('view_recommendation'),
  acceptRecommendation('accept_recommendation'),
  rejectRecommendation('reject_recommendation'),
  rateRecommendation('rate_recommendation'),

  // События, связанные с гардеробом
  viewWardrobe('view_wardrobe'),
  addToWardrobe('add_to_wardrobe'),
  removeFromWardrobe('remove_from_wardrobe'),
  updateWardrobeItem('update_wardrobe_item'),

  // События, связанные с погодой
  weatherForecastView('weather_forecast_view'),
  weatherDataRefresh('weather_data_refresh'),

  // События, связанные с аутентификацией
  login('login'),
  logout('logout'),
  register('register'),

  // События, связанные с настройками
  settingsUpdate('settings_update'),
  outfitPreferenceUpdate('outfit_preference_update');

  const AnalyticsEventType(this.value);
  final String value;
}

/// Модель события аналитики
class AnalyticsEvent {
  final AnalyticsEventType type;
  final Map<String, dynamic> properties;
  final DateTime? timestamp;
  final String? userId;

  const AnalyticsEvent({
    required this.type,
    required this.properties,
    this.timestamp,
    this.userId,
  });

  /// Создает копию события с новыми значениями
  AnalyticsEvent copyWith({
    AnalyticsEventType? type,
    Map<String, dynamic>? properties,
    DateTime? timestamp,
    String? userId,
  }) {
    return AnalyticsEvent(
      type: type ?? this.type,
      properties: properties ?? this.properties,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }

  /// Создает событие просмотра рекомендации
  static AnalyticsEvent viewRecommendation({
    required String recommendationId,
    required String outfitType,
    required Map<String, dynamic> weatherData,
    String? userId,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.viewRecommendation,
      properties: {
        'recommendation_id': recommendationId,
        'outfit_type': outfitType,
        'weather_data': weatherData,
      },
      userId: userId,
      timestamp: DateTime.now(),
    );
  }

  /// Создает событие принятия рекомендации
  static AnalyticsEvent acceptRecommendation({
    required String recommendationId,
    required String outfitType,
    required Map<String, dynamic> weatherData,
    String? userId,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.acceptRecommendation,
      properties: {
        'recommendation_id': recommendationId,
        'outfit_type': outfitType,
        'weather_data': weatherData,
      },
      userId: userId,
      timestamp: DateTime.now(),
    );
  }

  /// Создает событие отклонения рекомендации
  static AnalyticsEvent rejectRecommendation({
    required String recommendationId,
    required String outfitType,
    required Map<String, dynamic> weatherData,
    String? userId,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.rejectRecommendation,
      properties: {
        'recommendation_id': recommendationId,
        'outfit_type': outfitType,
        'weather_data': weatherData,
      },
      userId: userId,
      timestamp: DateTime.now(),
    );
  }

  /// Создает событие оценки рекомендации
  static AnalyticsEvent rateRecommendation({
    required String recommendationId,
    required int rating,
    required String outfitType,
    required Map<String, dynamic> weatherData,
    String? userId,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.rateRecommendation,
      properties: {
        'recommendation_id': recommendationId,
        'rating': rating,
        'outfit_type': outfitType,
        'weather_data': weatherData,
      },
      userId: userId,
      timestamp: DateTime.now(),
    );
  }

  /// Создает событие просмотра гардероба
  static AnalyticsEvent viewWardrobe({
    required int itemCount,
    required List<String> categories,
    String? userId,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.viewWardrobe,
      properties: {'item_count': itemCount, 'categories': categories},
      userId: userId,
      timestamp: DateTime.now(),
    );
  }
}
