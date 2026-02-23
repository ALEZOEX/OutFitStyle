/// Конфигурация безопасности для HTTP клиента
/// Web-версия (certificate pinning не поддерживается)
class SecurityConfig {
  static final SecurityConfig _instance = SecurityConfig._internal();

  factory SecurityConfig() {
    return _instance;
  }

  SecurityConfig._internal();

  /// Web не поддерживает certificate pinning
  bool validateCertificate(dynamic cert, String host) {
    return true;
  }
}

/// Extension для HttpClient (web-версия - пустая)
extension HttpClientSecurityExtension on dynamic {
  void applySecurityConfig() {
    // No-op для web
  }
}
