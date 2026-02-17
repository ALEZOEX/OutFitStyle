import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;
import 'package:flutter/foundation.dart';

import '../security/security_config.dart';

/// Factory для создания HTTP клиентов с security best practices
class HttpClientFactory {
  /// Создание защищённого HTTP клиента
  static http.Client createSecureClient() {
    final securityConfig = SecurityConfig();

    if (kReleaseMode) {
      // Production режим: строгая безопасность
      final httpClient = securityConfig.createSecureHttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 30);
      httpClient.applySecurityConfig();

      return io_client.IOClient(httpClient);
    } else {
      // Development режим: обычные сертификаты для удобства
      return http.Client();
    }
  }
}
