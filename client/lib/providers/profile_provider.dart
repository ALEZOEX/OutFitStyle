import 'package:flutter/foundation.dart';
import '../services/user_settings_service.dart';

class ProfileProvider extends ChangeNotifier {
  final UserSettingsService _svc;

  ProfileProvider(this._svc);

  Map<String, dynamic>? profile; // { user, stats, subscription? }
  bool isLoading = false;
  String? error;

  Map<String, dynamic>? get user => (profile?['user'] as Map?)?.cast<String, dynamic>();
  Map<String, dynamic>? get stats => (profile?['stats'] as Map?)?.cast<String, dynamic>();

  Future<void> load() async {
    error = null;
    isLoading = true;
    notifyListeners();
    try {
      profile = await _svc.getMyProfile();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePreferences(Map<String, dynamic> patch) async {
    error = null;
    notifyListeners();
    try {
      profile = await _svc.updatePreferences(patch);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateBodyMeasurements(Map<String, dynamic> patch) async {
    error = null;
    notifyListeners();
    try {
      profile = await _svc.updateBodyMeasurements(patch);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfilePatch(Map<String, dynamic> patch) async {
    error = null;
    notifyListeners();
    try {
      profile = await _svc.updateProfilePatch(patch);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}