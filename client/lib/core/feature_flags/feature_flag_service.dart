import 'package:firebase_remote_config/firebase_remote_config.dart';

class FeatureFlagService {
  static final FeatureFlagService _instance = FeatureFlagService._internal();
  factory FeatureFlagService() => _instance;
  FeatureFlagService._internal();

  late final FirebaseRemoteConfig _remoteConfig;

  static const Map<String, dynamic> _defaultValues = {
    'new_recommendation_algorithm': false,
    'show_outfit_preview': true,
    'enable_social_sharing': false,
    'max_recommendations_per_request': 10,
    'ml_model_version': 'v1.0',
  };

  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;
    
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    
    await _remoteConfig.setDefaults(_defaultValues);
    
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // If fetch fails, use defaults
    }
  }

  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  // Feature flag methods
  bool get isNewRecommendationAlgorithmEnabled => getBool('new_recommendation_algorithm');
  bool get isOutfitPreviewEnabled => getBool('show_outfit_preview');
  bool get isSocialSharingEnabled => getBool('enable_social_sharing');
  int get maxRecommendationsPerRequest => getInt('max_recommendations_per_request');
  String get mlModelVersion => getString('ml_model_version');
}