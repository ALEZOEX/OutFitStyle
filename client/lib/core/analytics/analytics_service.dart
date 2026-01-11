import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  static Future<void> logLogin(String loginMethod) async {
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  static Future<void> logSignUp(String signUpMethod) async {
    await _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  static Future<void> logSelectContent({
    required String contentType,
    required String itemId,
  }) async {
    await _analytics.logSelectContent(
      contentType: contentType,
      itemId: itemId,
    );
  }

  static Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  static Future<void> setUserId(String id) async {
    await _analytics.setUserId(id: id);
  }

  static Future<void> setCurrentScreen({
    String? screenName,
    String? screenClassOverride,
  }) async {
    if (screenName != null) {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClassOverride,
      );
    }
  }
}