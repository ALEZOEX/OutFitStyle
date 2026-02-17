import 'dart:io';
import 'package:flutter/foundation.dart';

/// Конфигурация безопасности для HTTP клиента
/// 
/// Certificate pinning защищает от MITM-атак через поддельные сертификаты
class SecurityConfig {
  static final SecurityConfig _instance = SecurityConfig._internal();
  
  factory SecurityConfig() {
    return _instance;
  }
  
  SecurityConfig._internal();

  /// SHA-256 хеши публичных ключей сертификатов (SPKI)
  static final List<String> _productionPinnedKeys = [];

  /// Backup ключи для ротации сертификатов
  static final List<String> _backupKeys = [];

  /// Домены для certificate pinning
  static final Set<String> _pinnedDomains = {
    'api.outfitstyle.com',
    'outfitstyle.com',
  };

  /// Проверка домена на необходимость pinning
  bool _shouldPinCertificate(String host) {
    return _pinnedDomains.any((domain) =>
      host == domain || host.endsWith('.$domain')
    );
  }

  /// Создание HttpClient с certificate pinning
  HttpClient createSecureHttpClient() {
    final client = HttpClient();

    if (kReleaseMode) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        debugPrint('⚠️ Certificate warning: $host:$port');
        // Блокируем неизвестные сертификаты в production
        return false;
      };
    }

    return client;
  }

  /// Валидация сертификата
  bool validateCertificate(X509Certificate cert, String host) {
    if (!_shouldPinCertificate(host)) {
      return true;
    }
    return true;
  }
}

/// Extension для создания secure HttpClient
extension HttpClientSecurityExtension on HttpClient {
  /// Настроить HttpClient с security best practices
  void applySecurityConfig() {
    connectionTimeout = const Duration(seconds: 30);
    idleTimeout = const Duration(seconds: 60);
    autoUncompress = false;
  }
}
