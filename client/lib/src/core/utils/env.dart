import 'package:flutter/foundation.dart' show kDebugMode;

import '../../config/app_config.dart';
import '../api/api_config.dart';

class Env {
  static const String _envApiHost = String.fromEnvironment('API_HOST');

  static ApiConfig apiConfig() {
    var raw = _envApiHost.isNotEmpty ? _envApiHost : AppConfig.apiBaseUrl;

    // Нормализуем хост для платформы
    raw = ApiConfig.normalizeHostForPlatform(raw);

    if (kDebugMode) {
      // ignore: avoid_print
      // print('✅ API host: $raw'); // Debug print removed for production
    }
    return ApiConfig(apiBase: raw);
  }
}
