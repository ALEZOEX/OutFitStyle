import 'analytics_event.dart';

/// Абстрактный интерфейс сервиса аналитики
abstract class IAnalyticsService {
  /// Логирование события аналитики
  Future<void> logEvent(AnalyticsEvent event);

  /// Логирование простого события по имени
  Future<void> logEventSimple(String eventName,
      {Map<String, dynamic>? parameters});

  /// Логирование просмотра экрана
  Future<void> logScreenView(String screenName);

  /// Логирование ошибки
  Future<void> logError(String error, {String? stackTrace});

  /// Логирование исключения
  Future<void> logException(Exception exception, {String? stackTrace});

  /// Логирование покупки
  Future<void> logPurchase({
    required double amount,
    required String currency,
    String? itemId,
    String? itemName,
  });

  /// Установка userId
  Future<void> setUserId(String? userId);

  /// Установка свойства пользователя
  Future<void> setUserProperty(String name, String value);

  /// Получение текущего userId
  String? getUserId();

  /// Освобождение ресурсов
  Future<void> dispose();
}

/// Статический класс-обёртка для обратной совместимости
class AnalyticsService {
  static IAnalyticsService? _instance;

  /// Установить экземпляр сервиса аналитики
  static void setInstance(IAnalyticsService instance) {
    _instance = instance;
  }

  /// Получить экземпляр сервиса аналитики
  static IAnalyticsService get instance {
    if (_instance == null) {
      throw StateError('AnalyticsService instance not initialized. '
          'Call AnalyticsService.setInstance() first.');
    }
    return _instance!;
  }
}
