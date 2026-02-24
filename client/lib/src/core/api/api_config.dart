/// Конфигурация API
class ApiConfig {
  final String apiBase;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const ApiConfig({
    required this.apiBase,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 10),
  });

  /// Статические значения по умолчанию
  /// Для локальной разработки: http://localhost:8080
  /// Для Android эмулятора: http://10.0.2.2:8080
  /// Для production: https://outfitstyle.ru/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://outfitstyle.ru/api/v1',
  );
  static const Duration defaultConnectTimeout = Duration(seconds: 10);
  static const Duration defaultReceiveTimeout = Duration(seconds: 10);

  /// Нормализует хост для платформы (добавляет http:// если нет)
  static String normalizeHostForPlatform(String host) {
    if (host.isEmpty) return baseUrl;
    if (!host.startsWith('http://') && !host.startsWith('https://')) {
      return 'https://$host';
    }
    return host;
  }
}