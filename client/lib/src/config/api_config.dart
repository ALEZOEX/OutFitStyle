/// Конфигурация API для приложения
class ApiConfig {
  /// Базовый URL для внутреннего API сервера
  /// В продакшене будет реальный URL сервера
  /// В разработке может быть локальный URL или URL тестового сервера
  static String get baseUrl {
    // В реальном приложении можно использовать Environment Variables
    // или конфигурационные файлы для разных сред
    const environment =
        String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

    switch (environment) {
      case 'production':
        return 'https://api.outfitstyle.app'; // Пример продакшен URL
      case 'staging':
        return 'https://staging-api.outfitstyle.app'; // Пример стейджинг URL
      default:
        // Для разработки можно использовать локальный сервер
        // или IP-адрес хост-машины, если сервер запущен на хосте
        return 'http://10.0.2.2:8080'; // Для эмулятора Android
      // return 'http://localhost:8080'; // Для физических устройств или iOS
    }
  }

  /// Путь к погодному API
  static String get weatherApiPath => '/api/v1/weather';

  /// Полный URL для погодного API
  static String get weatherApiUrl => '$baseUrl$weatherApiPath';
}
