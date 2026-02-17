import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      // Set the Flutter error handler to use Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        if (kReleaseMode) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        } else {
          FlutterError.presentError(details);
        }
      };

      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        if (kReleaseMode) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };

      // Enable crashlytics reporting
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      _initialized = true;
    } catch (e) {
      debugPrint('⚠️ Crashlytics init failed: $e');
      // Use default error handler
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
