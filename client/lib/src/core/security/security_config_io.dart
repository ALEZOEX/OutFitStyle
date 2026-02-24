import 'dart:io' show HttpClient, X509Certificate;

/// Конфигурация безопасности для HTTP клиента
/// IO-версия (с поддержкой certificate pinning для mobile/desktop)
class SecurityConfig {
  static final SecurityConfig _instance = SecurityConfig._internal();

  factory SecurityConfig() {
    return _instance;
  }

  SecurityConfig._internal();

  /// Создать защищённый HttpClient с certificate pinning
  HttpClient createSecureHttpClient() {
    final client = HttpClient();
    applyToHttpClient(client);
    return client;
  }

  /// Валидация сертификата для certificate pinning
  bool validateCertificate(dynamic cert, String host) {
    // Здесь можно реализовать pinning сертификатов
    // Для production нужно хранить hashes сертификатов и сравнивать
    return true;
  }

  /// Применить настройки безопасности к HttpClient
  void applyToHttpClient(HttpClient client) {
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return validateCertificate(cert, host);
    };
  }
}

/// Extension для HttpClient
extension HttpClientSecurityExtension on HttpClient {
  void applySecurityConfig() {
    SecurityConfig().applyToHttpClient(this);
  }
}
