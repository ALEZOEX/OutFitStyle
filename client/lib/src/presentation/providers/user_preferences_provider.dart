import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/user_preference.dart';

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreference>(
      (ref) => UserPreferencesNotifier(),
    );

class UserPreferencesNotifier extends StateNotifier<UserPreference> {
  UserPreferencesNotifier() : super(const UserPreference());

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user_preferences');

    if (jsonString != null) {
      try {
        state = UserPreference.fromJson(jsonDecode(jsonString));
      } catch (_) {
        state = const UserPreference();
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_preferences', jsonEncode(state.toJson()));
  }

  Future<void> updateAndSave(UserPreference preferences) async {
    state = preferences;
    await _save();
  }

  void updatePreferredTemperature(String value) {
    state = state.copyWith(preferredTemperature: value);
  }

  void updatePreferredColors(List<String> value) {
    state = state.copyWith(preferredColors: value);
  }

  void updatePreferredStyles(List<String> value) {
    state = state.copyWith(preferredStyles: value);
  }

  void updatePreferredBrands(List<String> value) {
    state = state.copyWith(preferredBrands: value);
  }

  void updateExcludedItems(List<String> value) {
    state = state.copyWith(excludedItems: value);
  }

  void updatePrefersNaturalMaterials(bool value) {
    state = state.copyWith(prefersNaturalMaterials: value);
  }

  void updatePrefersSyntheticMaterials(bool value) {
    state = state.copyWith(prefersSyntheticMaterials: value);
  }

  void updateSensitiveToCold(bool value) {
    state = state.copyWith(sensitiveToCold: value);
  }

  void updateSensitiveToHeat(bool value) {
    state = state.copyWith(sensitiveToHeat: value);
  }

  void updateOccasionsOfInterest(List<String> value) {
    state = state.copyWith(occasionsOfInterest: value);
  }
}
