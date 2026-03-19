/// Конфигурация API для приложения
class ApiConfig {
  /// Базовый URL для API сервера
  /// Устанавливается через --dart-define=API_BASE_URL при сборке
  /// Для web: '' (пустая строка, запросы будут относительными: /api/v1/...)
  /// Для mobile: полный URL сервера (например, 'http://10.0.2.2:8080')
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  /// Путь к погодному API
  static String get weatherApiPath => '/api/v1/weather';

  /// Полный URL для погодного API
  static String get weatherApiUrl => '$baseUrl$weatherApiPath';
}
