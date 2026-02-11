import 'analytics_event.dart';

/// Абстрактный интерфейс для сервиса аналитики
abstract class AnalyticsService {
  /// Отправить событие аналитики
  Future<void> logEvent(AnalyticsEvent event);

  /// Отправить событие аналитики с простыми параметрами
  Future<void> logEventSimple(String eventName,
      {Map<String, dynamic>? parameters});

  /// Отправить событие просмотра экрана
  Future<void> logScreenView(String screenName);

  /// Отправить событие ошибки
  Future<void> logError(String error, {String? stackTrace});

  /// Отправить событие исключения
  Future<void> logException(Exception exception, {String? stackTrace});

  /// Отправить событие покупки (если применимо)
  Future<void> logPurchase({
    required double amount,
    required String currency,
    String? itemId,
    String? itemName,
  });

  /// Установить ID пользователя
  Future<void> setUserId(String? userId);

  /// Установить свойства пользователя
  Future<void> setUserProperty(String name, String value);

  /// Получить ID текущего пользователя
  String? getUserId();

  /// Завершить работу сервиса
  Future<void> dispose();
}
