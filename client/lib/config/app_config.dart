import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class AppConfig {
  // API ключ для сервиса погоды
  static const String weatherApiKey = 'your_weather_api_key';

  // Базовый URL для сервиса погоды
  static const String weatherBaseUrl = 'api.openweathermap.org';

  // Shopping API URL
  static String get shoppingApiUrl {
    if (!kDebugMode) {
      return 'https://shopping.outfitstyle.com';
    }

    if (kIsWeb) {
      return 'http://localhost:5002';
    } else if (Platform.isAndroid) {
      if (_useRealDevice) {
        return 'http://$_localNetworkIp:5002';
      } else {
        return 'http://10.0.2.2:5002';
      }
    } else if (Platform.isIOS) {
      if (_useRealDevice) {
        return 'http://$_localNetworkIp:5002';
      } else {
        return 'http://localhost:5002';
      }
    } else {
      return 'http://localhost:5002';
    }
  }

  // ============================================
  // 🔧 НАСТРОЙКИ ДЛЯ РАЗРАБОТКИ
  // ============================================

  // Твой IP адрес из ipconfig (Ethernet адаптер)
  static const String _localNetworkIp = '192.168.1.63';

  // Используешь ли реальное Android/iOS устройство?
  // true  = реальное устройство (телефон/планшет)
  // false = эмулятор/симулятор
  static const bool _useRealDevice = false;

  // ============================================
  // 🌐 URL НАСТРОЙКИ
  // ============================================

  // Development API
  static const String _devApiUrl = 'http://localhost:8080';

  // Production API (когда будет сервер в интернете)
  static const String _prodApiUrl = 'https://api.outfitstyle.com';

  // Marketplace Service URL
  static String get marketplaceServiceUrl {
    if (!kDebugMode) {
      return 'https://marketplace.outfitstyle.com';
    }

    if (kIsWeb) {
      return 'http://localhost:5001';
    } else if (Platform.isAndroid) {
      if (_useRealDevice) {
        return 'http://$_localNetworkIp:5001';
      } else {
        return 'http://10.0.2.2:5001';
      }
    } else if (Platform.isIOS) {
      if (_useRealDevice) {
        return 'http://$_localNetworkIp:5001';
      } else {
        return 'http://localhost:5001';
      }
    } else {
      return 'http://localhost:5001';
    }
  }

  // ============================================
  // 🎯 АВТОМАТИЧЕСКИЙ ВЫБОР URL
  // ============================================

  static String get apiBaseUrl {
    // Если релизная сборка - используем production
    if (!kDebugMode) {
      return _prodApiUrl;
    }

    // Режим разработки - выбираем по платформе
    if (kIsWeb) {
      // Web (Chrome, Edge, Firefox и т.д.)
      return _devApiUrl;
    } else if (Platform.isAndroid) {
      // Android
      if (_useRealDevice) {
        // Реальное Android устройство
        return 'http://$_localNetworkIp/api/v1';
      } else {
        // Android эмулятор
        return 'http://10.0.2.2/api/v1';
      }
    } else if (Platform.isIOS) {
      // iOS
      if (_useRealDevice) {
        // Реальное iOS устройство
        return 'http://$_localNetworkIp:8080';
      } else {
        // iOS симулятор
        return _devApiUrl;
      }
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Desktop приложения
      return _devApiUrl;
    } else {
      // Fallback на всякий случай
      return _devApiUrl;
    }
  }

  // ============================================
  // ⚙️ ДРУГИЕ НАСТРОЙКИ
  // ============================================

  // Таймаут для HTTP запросов (в секундах)
  static const int requestTimeout = 30;

  // Включить логирование в консоль?
  static const bool enableLogging = true;

  // Версия приложения
  static const String appVersion = '1.0.0';
  static const String appName = 'OutfitStyle';

  // ============================================
  // 📊 ИНФОРМАЦИЯ О КОНФИГУРАЦИИ
  // ============================================

  // Получить всю информацию о текущей конфигурации
  static Map<String, dynamic> get info => {
        'platform': _platformName,
        'apiUrl': apiBaseUrl,
        'isDebug': kDebugMode,
        'isRealDevice': _useRealDevice,
        'version': appVersion,
      };

  // Название текущей платформы
  static String get _platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  // ============================================
  // 🖨️ ПЕЧАТЬ КОНФИГУРАЦИИ (для отладки)
  // ============================================


}