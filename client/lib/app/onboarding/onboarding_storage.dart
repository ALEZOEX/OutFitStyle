import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static const _kDone = 'onboarding_done_v1';

  Future<bool> isDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kDone) ?? false;
  }

  Future<void> setDone() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDone, true);
  }

  Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kDone);
  }
}