import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      // Установить обработчик ошибок Flutter для использования Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        if (kReleaseMode) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        } else {
          FlutterError.presentError(details);
        }
      };

      // Передать все необработанные асинхронные ошибки, которые не обработаны Flutter, в Crashlytics
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        if (kReleaseMode) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };

      // Включить отчеты Crashlytics
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      _initialized = true;
    } catch (e) {
      debugPrint('⚠️ Crashlytics init failed: $e');
      // Использовать обработчик ошибок по умолчанию
      FlutterError.presentError = FlutterError.presentError;
    }
  }

  static void logException(dynamic exception, StackTrace stack) {
    try {
      FirebaseCrashlytics.instance.recordError(exception, stack);
    } catch (_) {}
  }

  static void logMessage(String message) {
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (_) {}
  }

  static void setUserIdentifier(String identifier) {
    try {
      FirebaseCrashlytics.instance.setUserIdentifier(identifier);
    } catch (_) {}
  }

  static void setCustomKey(String key, Object value) {
    try {
      FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (_) {}
  }
}
