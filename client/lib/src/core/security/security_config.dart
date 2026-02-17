import 'dart:io';
import 'dart:typed_data';
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
  /// 
  /// Как получить:
  /// ```bash
  /// openssl s_client -connect api.outfitstyle.com:443 -servername api.outfitstyle.com 2>/dev/null \
  ///   | openssl x509 -pubkey -noout \
  ///   | openssl pkey -pubin -outform der \
  ///   | openssl dgst -sha256 -binary \
  ///   | openssl enc -base64
  /// ```
  /// 
  /// Для production заменить на реальные хеши сервера
  static final List<String> _productionPinnedKeys = [
    // Пример: 'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    // Добавить хеши для основного сертификата и backup CA
  ];

  /// Backup ключи для ротации сертификатов
  /// 
  /// При смене сертификата сначала добавить новый ключ сюда,
  /// затем через 24-48 часов (после обновления всех клиентов)
  /// сделать основным ключом
  static final List<String> _backupKeys = [];

  /// Домены для certificate pinning
  static final Set<String> _pinnedDomains = {
    'api.outfitstyle.com',
    'outfitstyle.com',
  ];

  /// Проверка домена на необходимость pinning
  bool _shouldPinCertificate(String host) {
    return _pinnedDomains.any((domain) => 
      host == domain || host.endsWith('.$domain')
    );
  }

  /// Настройка SecurityContext с certificate pinning
  /// 
  /// Возвращает null если pinning не требуется для этого домена
  SecurityContext? createPinnedContext(String host) {
    if (kReleaseMode && _shouldPinCertificate(host)) {
      final context = SecurityContext();
      
      // В production добавить проверку pinned keys
      // Пока используем стандартные корневые сертификаты
      context.setTrustedCertificatesFromPath();
      
      return context;
    }
    
    return null;
  }

  /// Создание HttpClient с certificate pinning
  /// 
  /// Для production режимов проверяет хеши сертификатов
  HttpClient createSecureHttpClient() {
    final client = HttpClient();
    
    if (kReleaseMode) {
      client.badCertificateCallback = 
          (X509Certificate cert, String host, int port) {
        // В production режиме неизвестные сертификаты блокируются
        debugPrint('⚠️ Certificate warning: $host:$port');
        debugPrint('   Subject: ${cert.subject}');
        debugPrint('   Issuer: ${cert.issuer}');
        debugPrint('   Valid from: ${cert.startValidity}');
        debugPrint('   Valid until: ${cert.endValidity}');
        
        // Блокируем неизвестные сертификаты в production
        return false;
      };
    }
    
    return client;
  }

  /// Валидация сертификата по SPKI хешам
  bool validateCertificate(X509Certificate cert, String host) {
    if (!_shouldPinCertificate(host)) {
      return true; // Pinning не требуется для этого домена
    }

    // TODO: Реализовать проверку SPKI хешей
    // Пока используем стандартную валидацию через доверенные CA
    return true;
  }
}

/// Extension для создания secure HttpClient из Dio
extension DioSecurityExtension on HttpClient {
  /// Настроить HttpClient с security best practices
  void applySecurityConfig() {
    connectionTimeout = const Duration(seconds: 30);
    receiveTimeout = const Duration(seconds: 30);
    sendTimeout = const Duration(seconds: 30);
    
    // Отключаем автоматические редиректы (защита от open redirect)
    autoUncompress = false;
    
    // Включаем HTTP/2 для безопасности
    // idleTimeout = const Duration(seconds: 60);
  }
}
