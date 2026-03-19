/// Модель настроек уведомлений пользователя
///
/// Содержит все типы уведомлений, сгруппированные по каналам:
/// - Push уведомления
/// - Email уведомления
/// - SMS уведомления (опционально)
class NotificationSettings {
  /// Push уведомления включены глобально
  final bool pushEnabled;

  /// Email уведомления включены глобально
  final bool emailEnabled;

  /// SMS уведомления включены глобально
  final bool smsEnabled;

  // === Push уведомления по типам ===

  /// Уведомления о погоде и погодных предупреждениях
  final bool weatherAlerts;

  /// Уведомления о готовности рекомендаций
  final bool recommendationReady;

  /// Уведомления о новых поступлениях в гардероб
  final bool newArrivals;

  /// Уведомления о достижениях
  final bool achievementUnlocked;

  /// Промоциональные уведомления
  final bool promotional;

  /// Уведомления о статусе подписки
  final bool subscriptionStatus;

  /// Напоминания о планировании outfits
  final bool outfitReminders;

  /// Уведомления о_trip (поездках)
  final bool tripUpdates;

  // === Email уведомления по типам ===

  /// Email о погоде и погодных предупреждениях
  final bool emailWeatherAlerts;

  /// Email дайджест рекомендаций
  final bool emailRecommendationDigest;

  /// Email о достижениях
  final bool emailAchievements;

  /// Промоциональные email
  final bool emailPromotional;

  /// Email о статусе подписки
  final bool emailSubscriptionStatus;

  /// Newsletter
  final bool emailNewsletter;

  // === SMS уведомления по типам ===

  /// SMS о критических погодных предупреждениях
  final bool smsWeatherAlerts;

  /// SMS о срочных напоминаниях
  final bool smsReminders;

  /// SMS о статусе подписки
  final bool smsSubscriptionStatus;

  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = false,
    this.smsEnabled = false,
    this.weatherAlerts = true,
    this.recommendationReady = true,
    this.newArrivals = true,
    this.achievementUnlocked = true,
    this.promotional = false,
    this.subscriptionStatus = true,
    this.outfitReminders = true,
    this.tripUpdates = true,
    this.emailWeatherAlerts = false,
    this.emailRecommendationDigest = false,
    this.emailAchievements = false,
    this.emailPromotional = false,
    this.emailSubscriptionStatus = true,
    this.emailNewsletter = false,
    this.smsWeatherAlerts = false,
    this.smsReminders = false,
    this.smsSubscriptionStatus = false,
  });

  /// Создать копию с изменёнными полями
  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? weatherAlerts,
    bool? recommendationReady,
    bool? newArrivals,
    bool? achievementUnlocked,
    bool? promotional,
    bool? subscriptionStatus,
    bool? outfitReminders,
    bool? tripUpdates,
    bool? emailWeatherAlerts,
    bool? emailRecommendationDigest,
    bool? emailAchievements,
    bool? emailPromotional,
    bool? emailSubscriptionStatus,
    bool? emailNewsletter,
    bool? smsWeatherAlerts,
    bool? smsReminders,
    bool? smsSubscriptionStatus,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      weatherAlerts: weatherAlerts ?? this.weatherAlerts,
      recommendationReady: recommendationReady ?? this.recommendationReady,
      newArrivals: newArrivals ?? this.newArrivals,
      achievementUnlocked: achievementUnlocked ?? this.achievementUnlocked,
      promotional: promotional ?? this.promotional,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      outfitReminders: outfitReminders ?? this.outfitReminders,
      tripUpdates: tripUpdates ?? this.tripUpdates,
      emailWeatherAlerts: emailWeatherAlerts ?? this.emailWeatherAlerts,
      emailRecommendationDigest:
          emailRecommendationDigest ?? this.emailRecommendationDigest,
      emailAchievements: emailAchievements ?? this.emailAchievements,
      emailPromotional: emailPromotional ?? this.emailPromotional,
      emailSubscriptionStatus:
          emailSubscriptionStatus ?? this.emailSubscriptionStatus,
      emailNewsletter: emailNewsletter ?? this.emailNewsletter,
      smsWeatherAlerts: smsWeatherAlerts ?? this.smsWeatherAlerts,
      smsReminders: smsReminders ?? this.smsReminders,
      smsSubscriptionStatus:
          smsSubscriptionStatus ?? this.smsSubscriptionStatus,
    );
  }

  /// Преобразовать в Map для отправки на сервер
  Map<String, dynamic> toMap() {
    return {
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'sms_enabled': smsEnabled,
      'weather_alerts': weatherAlerts,
      'recommendation_ready': recommendationReady,
      'new_arrivals': newArrivals,
      'achievement_unlocked': achievementUnlocked,
      'promotional': promotional,
      'subscription_status': subscriptionStatus,
      'outfit_reminders': outfitReminders,
      'trip_updates': tripUpdates,
      'email_weather_alerts': emailWeatherAlerts,
      'email_recommendation_digest': emailRecommendationDigest,
      'email_achievements': emailAchievements,
      'email_promotional': emailPromotional,
      'email_subscription_status': emailSubscriptionStatus,
      'email_newsletter': emailNewsletter,
      'sms_weather_alerts': smsWeatherAlerts,
      'sms_reminders': smsReminders,
      'sms_subscription_status': smsSubscriptionStatus,
    };
  }

  /// Создать из Map с сервера
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      pushEnabled: map['push_enabled'] as bool? ?? true,
      emailEnabled: map['email_enabled'] as bool? ?? false,
      smsEnabled: map['sms_enabled'] as bool? ?? false,
      weatherAlerts: map['weather_alerts'] as bool? ?? true,
      recommendationReady: map['recommendation_ready'] as bool? ?? true,
      newArrivals: map['new_arrivals'] as bool? ?? true,
      achievementUnlocked: map['achievement_unlocked'] as bool? ?? true,
      promotional: map['promotional'] as bool? ?? false,
      subscriptionStatus: map['subscription_status'] as bool? ?? true,
      outfitReminders: map['outfit_reminders'] as bool? ?? true,
      tripUpdates: map['trip_updates'] as bool? ?? true,
      emailWeatherAlerts: map['email_weather_alerts'] as bool? ?? false,
      emailRecommendationDigest:
          map['email_recommendation_digest'] as bool? ?? false,
      emailAchievements: map['email_achievements'] as bool? ?? false,
      emailPromotional: map['email_promotional'] as bool? ?? false,
      emailSubscriptionStatus:
          map['email_subscription_status'] as bool? ?? true,
      emailNewsletter: map['email_newsletter'] as bool? ?? false,
      smsWeatherAlerts: map['sms_weather_alerts'] as bool? ?? false,
      smsReminders: map['sms_reminders'] as bool? ?? false,
      smsSubscriptionStatus: map['sms_subscription_status'] as bool? ?? false,
    );
  }

  /// Создать настройки по умолчанию
  factory NotificationSettings.defaultSettings() {
    return const NotificationSettings();
  }

  @override
  String toString() =>
      'NotificationSettings(pushEnabled: $pushEnabled, emailEnabled: $emailEnabled)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.pushEnabled == pushEnabled &&
        other.emailEnabled == emailEnabled &&
        other.smsEnabled == smsEnabled &&
        other.weatherAlerts == weatherAlerts &&
        other.recommendationReady == recommendationReady &&
        other.newArrivals == newArrivals &&
        other.achievementUnlocked == achievementUnlocked &&
        other.promotional == promotional &&
        other.subscriptionStatus == subscriptionStatus &&
        other.outfitReminders == outfitReminders &&
        other.tripUpdates == tripUpdates &&
        other.emailWeatherAlerts == emailWeatherAlerts &&
        other.emailRecommendationDigest == emailRecommendationDigest &&
        other.emailAchievements == emailAchievements &&
        other.emailPromotional == emailPromotional &&
        other.emailSubscriptionStatus == emailSubscriptionStatus &&
        other.emailNewsletter == emailNewsletter &&
        other.smsWeatherAlerts == smsWeatherAlerts &&
        other.smsReminders == smsReminders &&
        other.smsSubscriptionStatus == smsSubscriptionStatus;
  }

  @override
  int get hashCode => Object.hash(
    pushEnabled,
    emailEnabled,
    smsEnabled,
    weatherAlerts,
    recommendationReady,
    newArrivals,
    achievementUnlocked,
    promotional,
    subscriptionStatus,
    outfitReminders,
    tripUpdates,
    emailWeatherAlerts,
    emailRecommendationDigest,
    emailAchievements,
    emailPromotional,
    emailSubscriptionStatus,
    emailNewsletter,
    smsWeatherAlerts,
    smsReminders,
    smsSubscriptionStatus,
  );
}
