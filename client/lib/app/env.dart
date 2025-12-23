import 'package:flutter/foundation.dart' show kDebugMode;
import '../../config/app_config.dart';
import 'api/api_config.dart';

class Env {
  /// Передавай так:
  /// flutter run --dart-define=API_HOST=http://10.0.2.2:8080
  static const String _envApiHost = String.fromEnvironment('API_HOST');

  static ApiConfig apiConfig() {
    final raw = _envApiHost.isNotEmpty ? _envApiHost : AppConfig.apiHost;

    final parsed = Uri.parse(raw);

    // Подстрахуемся, если кто-то сунул /api/v1 в API_HOST:
    final sanitized = parsed.path.endsWith('/api/v1')
        ? parsed.replace(path: parsed.path.substring(0, parsed.path.length - '/api/v1'.length))
        : parsed.replace(path: ''); // host должен быть без path

    final host = normalizeHostForPlatform(sanitized);
    if (kDebugMode) {
      // ignore: avoid_print
      print('✅ API host: $host');
      // ignore: avoid_print
      print('✅ API base: ${ApiConfig(host: host).apiBase}');
    }
    return ApiConfig(host: host);
  }
}