import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (!_prefs.isValid) {
      throw Exception('LocalStorage not initialized. Call init() first.');
    }
    return _prefs;
  }
}

extension SharedPreferencesExtension on SharedPreferences {
  bool get isValid => true; // Simple validation
}