import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class ABTestService {
  static final ABTestService _instance = ABTestService._internal();
  factory ABTestService() => _instance;
  ABTestService._internal();

  late SharedPreferences _prefs;
  final Random _random = Random();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getVariant(String testName, List<String> variants,
      {double allocation = 0.5}) {
    final storedVariant = _prefs.getString('ab_$testName');

    if (storedVariant != null) {
      return storedVariant;
    }

    // Simple A/B test: 50% allocation to each variant
    final shouldAssign = _random.nextDouble() < allocation;
    final variant = shouldAssign ? variants[0] : variants[1];

    _prefs.setString('ab_$testName', variant);
    return variant;
  }

  // Specific A/B tests
  String getRecommendationAlgorithmVariant() {
    return getVariant('recommendation_algorithm', ['current', 'new'],
        allocation: 0.5);
  }

  String getUITestVariant() {
    return getVariant('ui_layout', ['standard', 'alternative'],
        allocation: 0.5);
  }

  String getOnboardingVariant() {
    return getVariant('onboarding_flow', ['simple', 'guided'], allocation: 0.5);
  }

  // Track conversion
  void trackConversion(String testName, String variant, String action) {
    final key = 'ab_conversion_${testName}_$variant';
    final currentValue = _prefs.getInt(key) ?? 0;
    _prefs.setInt(key, currentValue + 1);
  }

  // Get conversion data for analysis
  Map<String, int> getConversionData(String testName) {
    final result = <String, int>{};
    for (final variant in ['current', 'new']) {
      final key = 'ab_conversion_${testName}_$variant';
      result[variant] = _prefs.getInt(key) ?? 0;
    }
    return result;
  }
}
