import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../security/security_config.dart';
import 'api_config.dart';

/// Factory для создания HTTP клиентов с security best practices
class HttpClientFactory {
  /// Создание защищённого HTTP клиента
  /// 
  /// В production режиме:
  /// - Certificate pinning для доверенных доменов
  /// - Блокировка неизвестных сертификатов
  /// - Таймауты для защиты от hanging connections
  static http.Client createSecureClient({
    ApiConfig? config,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    final securityConfig = SecurityConfig();
    
    if (kReleaseMode) {
      // Production режим: строгая безопасность
      final httpClient = securityConfig.createSecureHttpClient();
      httpClient.connectionTimeout = connectTimeout ?? const Duration(seconds: 10);
      httpClient.receiveTimeout = receiveTimeout ?? const Duration(seconds: 10);
      httpClient.applySecurityConfig();
      
      return http.Client.fromHttpClient(httpClient);
    } else {
      // Development режим: обычные сертификаты для удобства
      return http.Client();
    }
  }

  /// Создание HttpClient для WebSocket подключений
  static WebSocket createWebSocket(String url) {
    final securityConfig = SecurityConfig();
    
    if (kReleaseMode) {
      final httpClient = securityConfig.createSecureHttpClient();
      return WebSocket(url, protocols: [], customClient: httpClient);
    }
    
    return WebSocket(url);
  }
}
