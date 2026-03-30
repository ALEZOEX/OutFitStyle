import 'package:shared_preferences/shared_preferences.dart';
import 'data/models/onboarding_data.dart' as models;
import '../../utils/logger.dart';

/// Хранилище данных онбординга в SharedPreferences
class OnboardingStorage {
  static const _kDone = 'onboarding_done_v1';
  static const _kCityId = 'onboarding_city_id';
  static const _kCityName = 'onboarding_city_name';
  static const _kCityLat = 'onboarding_city_lat';
  static const _kCityLon = 'onboarding_city_lon';
  static const _kStylePreferences = 'onboarding_style_preferences';
  static const _kBudgetRange = 'onboarding_budget_range';
  static const _kFavoriteBrands = 'onboarding_favorite_brands';

  Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    final isDone = prefs.getBool(_kDone) ?? false;
    AppLogger.info('OnboardingStorage.isDone() = $isDone');
    return isDone;
  }

  Future<void> setDone() async {
    AppLogger.info('OnboardingStorage.setDone() - setting flag to true');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDone, true);
    final verified = prefs.getBool(_kDone) ?? false;
    AppLogger.info('OnboardingStorage.setDone() - verified = $verified');
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDone);
  }

  /// Сохранение данных онбординга
  Future<void> saveOnboardingData(models.OnboardingData data) async {
    final prefs = await SharedPreferences.getInstance();

    if (data.cityId != null) {
      await prefs.setInt(_kCityId, data.cityId!);
    }
    if (data.cityName != null) {
      await prefs.setString(_kCityName, data.cityName!);
    }
    if (data.cityLat != null) {
      await prefs.setDouble(_kCityLat, data.cityLat!);
    }
    if (data.cityLon != null) {
      await prefs.setDouble(_kCityLon, data.cityLon!);
    }
    if (data.stylePreferences.isNotEmpty) {
      await prefs.setStringList(_kStylePreferences, data.stylePreferences);
    }
    if (data.budgetRange != null) {
      await prefs.setString(_kBudgetRange, data.budgetRange!);
    }
    if (data.favoriteBrands != null) {
      await prefs.setString(_kFavoriteBrands, data.favoriteBrands!);
    }
  }

  /// Получение сохранённых данных онбординга
  Future<models.OnboardingData?> getOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();

    // Если онбординг не пройден, возвращаем null
    final isDone = prefs.getBool(_kDone) ?? false;
    if (!isDone) return null;

    final stylePrefs = prefs.getStringList(_kStylePreferences) ?? [];

    return models.OnboardingData(
      cityId: prefs.getInt(_kCityId),
      cityName: prefs.getString(_kCityName),
      cityLat: prefs.getDouble(_kCityLat),
      cityLon: prefs.getDouble(_kCityLon),
      stylePreferences: stylePrefs,
      budgetRange: prefs.getString(_kBudgetRange),
      favoriteBrands: prefs.getString(_kFavoriteBrands),
    );
  }

  /// Очистка всех данных онбординга (для тестирования или сброса)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDone);
    await prefs.remove(_kCityId);
    await prefs.remove(_kCityName);
    await prefs.remove(_kCityLat);
    await prefs.remove(_kCityLon);
    await prefs.remove(_kStylePreferences);
    await prefs.remove(_kBudgetRange);
    await prefs.remove(_kFavoriteBrands);
  }

  /// Проверка, есть ли сохранённый город
  Future<bool> hasCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kCityName);
  }

  /// Проверка, есть ли сохранённые предпочтения стилей
  Future<bool> hasStylePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final styles = prefs.getStringList(_kStylePreferences);
    return styles != null && styles.isNotEmpty;
  }
}
