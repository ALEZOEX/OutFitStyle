import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static const _kDone = 'onboarding_done_v1';

  Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDone) ?? false;
  }

  Future<void> setDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDone, true);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDone);
  }
}