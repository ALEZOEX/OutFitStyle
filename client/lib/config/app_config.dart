import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

import '../app/platform_flags.dart'
    if (dart.library.io) '../app/platform_flags_io.dart'
    if (dart.library.html) '../app/platform_flags_web.dart';

class AppConfig {
  static const String _prodHost = 'https://api.outfitstyle.com';
  static const int _port = 80;

  // Можно переопределять без правок кода:
  // flutter run --dart-define=API_HOST=http://192.168.1.100:80
  static const String _hostOverride = String.fromEnvironment('API_HOST');

  // Для реального устройства:
  // flutter run --dart-define=LOCAL_IP=192.168.1.100 --dart-define=USE_LOCAL_IP=true
  static const String _localIp = String.fromEnvironment(
    'LOCAL_IP',
    defaultValue: '192.168.1.100',
  );
  static const bool _useLocalIp = bool.fromEnvironment(
    'USE_LOCAL_IP',
    defaultValue: false,
  );

  static String get apiHost {
    if (_hostOverride.isNotEmpty) return _hostOverride;

    if (!kDebugMode) return _prodHost;

    // Allow environment-based override for debug builds too
    final debugHost = String.fromEnvironment('DEBUG_API_HOST', defaultValue: '');
    if (debugHost.isNotEmpty) return debugHost;

    if (kIsWeb) return 'http://localhost:$_port';

    if (isAndroid) {
      final host = _useLocalIp ? _localIp : '10.0.2.2'; // эмулятор Android
      return 'http://$host:$_port';
    }

    if (isIOS) {
      final host = _useLocalIp ? _localIp : 'localhost'; // симулятор iOS
      return 'http://$host:$_port';
    }

    return 'http://localhost:$_port';
  }
}
