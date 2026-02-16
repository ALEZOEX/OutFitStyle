import 'package:flutter/foundation.dart' show kDebugMode;

import '../../config/app_config.dart';
import '../api/api_config.dart';

class Env {
  static const String _envApiHost = String.fromEnvironment('API_HOST');

  static ApiConfig apiConfig() {
    var raw = _envApiHost.isNotEmpty ? _envApiHost : AppConfig.apiBaseUrl;

    // Нормализуем хост для платформы
    raw = ApiConfig.normalizeHostForPlatform(raw);

    // Убираем /api/v1 из хоста, если есть (пусть добавляется в путях)
    if (raw.endsWith('/api/v1')) {
      raw = raw.substring(0, raw.length - '/api/v1'.length);
    }
    if (raw.endsWith('/api')) {
      raw = raw.substring(0, raw.length - '/api'.length);
    }

    if (kDebugMode) {
      // ignore: avoid_print
      // print('✅ API host: $raw'); // Debug print removed for production
    }
    return ApiConfig(apiBase: raw);
  }
}
