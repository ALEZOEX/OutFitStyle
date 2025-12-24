import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  final String apiBase;

  const ApiConfig({
    required this.apiBase,
  });

  /// Нормализует хост для платформы (особенно важно для Android эмулятора)
  static String normalizeHostForPlatform(String rawHost) {
    if (kIsWeb) return rawHost;

    // Для Android эмулятора: localhost -> 10.0.2.2
    if (Platform.isAndroid && (rawHost.contains('localhost') || rawHost.contains('127.0.0.1'))) {
      return rawHost.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
    }

    return rawHost;
  }
}