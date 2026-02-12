import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static Future<void> init() async {
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
  }

  static void logException(dynamic exception, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(exception, stack);
  }

  static void logMessage(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  static void setUserIdentifier(String identifier) {
    FirebaseCrashlytics.instance.setUserIdentifier(identifier);
  }

  static void setCustomKey(String key, Object value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }
}
