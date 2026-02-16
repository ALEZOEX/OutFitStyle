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
  static const String baseUrl = 'https://api.outfitstyle.com';
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