import 'package:shared_preferences/shared_preferences.dart';

class DialogStateManager {
  static const String _onboardingShownKey = 'onboarding_shown';
  static const String _locationPermissionShownKey = 'location_permission_shown';

  static Future<bool> isOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingShownKey) ?? false;
  }

  static Future<void> setOnboardingShown(bool shown) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingShownKey, shown);
  }

  static Future<bool> isLocationPermissionShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationPermissionShownKey) ?? false;
  }

  static Future<void> setLocationPermissionShown(bool shown) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPermissionShownKey, shown);
  }
}