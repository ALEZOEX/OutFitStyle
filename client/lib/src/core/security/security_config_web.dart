/// Конфигурация безопасности для HTTP клиента
/// Web-версия (certificate pinning не поддерживается в браузере)
class SecurityConfig {
  static final SecurityConfig _instance = SecurityConfig._internal();

  factory SecurityConfig() {
    return _instance;
  }

  SecurityConfig._internal();

  /// Web не поддерживает создание custom HttpClient
  /// Возвращает null, т.к. в Web используется браузерный HTTP стек
  dynamic createSecureHttpClient() {
    throw UnsupportedError(
      'createSecureHttpClient не поддерживается в Web. '
      'Используйте стандартный http.Client из package:http.',
    );
  }

  /// Web не поддерживает certificate pinning
  /// Всегда возвращает true (валидация выполняется браузером)
  bool validateCertificate(dynamic cert, String host) {
    return true;
  }
}

/// Extension для HttpClient (web-версия - пустая)
/// dart:html HttpClient не поддерживает badCertificateCallback
extension HttpClientSecurityExtension on Object {
  void applySecurityConfig() {
    // No-op для web: браузер сам выполняет валидацию сертификатов
  }
}
