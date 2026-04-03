import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/notification_settings_repository.dart';
import '../../domain/entities/notification_settings.dart';

/// Ключ для хранения настроек уведомлений в SharedPreferences
const _kNotificationSettingsKey = 'notification_settings';

/// Состояние настроек уведомлений
class NotificationSettingsState {
  /// Текущие настройки
  final NotificationSettings settings;

  /// Состояние загрузки
  final bool isLoading;

  /// Состояние сохранения
  final bool isSaving;

  /// Ошибка
  final String? error;

  /// Флаг наличия несохранённых изменений
  final bool hasUnsavedChanges;

  /// Исходные настройки (для сравнения)
  final NotificationSettings? originalSettings;

  const NotificationSettingsState({
    required this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.hasUnsavedChanges = false,
    this.originalSettings,
  });

  NotificationSettingsState copyWith({
    NotificationSettings? settings,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? hasUnsavedChanges,
    NotificationSettings? originalSettings,
  }) {
    return NotificationSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      originalSettings: originalSettings ?? this.originalSettings,
    );
  }

  /// Создать из настроек
  factory NotificationSettingsState.fromSettings(
    NotificationSettings settings,
  ) {
    return NotificationSettingsState(
      settings: settings,
      originalSettings: settings,
    );
  }
}

/// StateNotifier для управления настройками уведомлений
class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettingsState> {
  final NotificationSettingsRepository _repository;

  NotificationSettingsNotifier({
    required NotificationSettingsRepository repository,
  }) : _repository = repository,
       super(
         const NotificationSettingsState(settings: NotificationSettings()),
       ) {
    _loadSettings();
  }

  /// Загрузить настройки из SharedPreferences или с сервера
  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Сначала пробуем загрузить локальные настройки
      final localSettings = await _loadLocalSettings();

      if (localSettings != null) {
        state = NotificationSettingsState.fromSettings(localSettings);
      }

      // Затем загружаем с сервера (фоновая синхронизация)
      try {
        final serverSettings = await _repository.getSettings();
        state = NotificationSettingsState.fromSettings(serverSettings);
        // Сохраняем локально
        await _saveLocalSettings(serverSettings);
      } catch (e) {
        // Ошибка загрузки с сервера не критична, используем локальные
        debugPrint('Failed to load settings from server: $e');
        if (localSettings != null) {
          state = NotificationSettingsState.fromSettings(localSettings);
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки настроек: $e',
      );
    }

    state = state.copyWith(isLoading: false);
  }

  /// Загрузить локальные настройки из SharedPreferences
  Future<NotificationSettings?> _loadLocalSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_kNotificationSettingsKey);
      if (settingsJson != null && settingsJson.isNotEmpty) {
        final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
        return NotificationSettings.fromMap(decoded);
      }
    } catch (e) {
      debugPrint('Failed to load local settings: $e');
    }
    return null;
  }

  /// Сохранить настройки локально в SharedPreferences
  Future<void> _saveLocalSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kNotificationSettingsKey,
        jsonEncode(settings.toMap()),
      );
    } catch (e) {
      debugPrint('Failed to save local settings: $e');
    }
  }

  /// Обновить глобальные настройки Push
  void updatePushEnabled(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(pushEnabled: value),
      hasUnsavedChanges: true,
    );
  }

  /// Обновить глобальные настройки Email
  void updateEmailEnabled(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(emailEnabled: value),
      hasUnsavedChanges: true,
    );
  }

  /// Обновить глобальные настройки SMS
  void updateSmsEnabled(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(smsEnabled: value),
      hasUnsavedChanges: true,
    );
  }

  // === Push уведомления ===

  void updateWeatherAlerts(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(weatherAlerts: value),
      hasUnsavedChanges: true,
    );
  }

  void updateRecommendationReady(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(recommendationReady: value),
      hasUnsavedChanges: true,
    );
  }

  void updateNewArrivals(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(newArrivals: value),
      hasUnsavedChanges: true,
    );
  }

  void updateAchievementUnlocked(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(achievementUnlocked: value),
      hasUnsavedChanges: true,
    );
  }

  void updatePromotional(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(promotional: value),
      hasUnsavedChanges: true,
    );
  }

  void updateSubscriptionStatus(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(subscriptionStatus: value),
      hasUnsavedChanges: true,
    );
  }

  void updateOutfitReminders(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(outfitReminders: value),
      hasUnsavedChanges: true,
    );
  }

  void updateTripUpdates(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(tripUpdates: value),
      hasUnsavedChanges: true,
    );
  }

  // === Email уведомления ===

  void updateEmailWeatherAlerts(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(emailWeatherAlerts: value),
      hasUnsavedChanges: true,
    );
  }

  void updateEmailRecommendationDigest(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(emailRecommendationDigest: value),
      hasUnsavedChanges: true,
    );
  }

  void updateEmailAchievements(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(emailAchievements: value),
      hasUnsavedChanges: true,
    );
  }

  void updateEmailPromotional(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(emailPromotional: value),
      hasUnsavedChanges: true,
    );
  }

  void updateEmailSubscriptionStatus(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(emailSubscriptionStatus: value),
      hasUnsavedChanges: true,
    );
  }

  void updateEmailNewsletter(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(emailNewsletter: value),
      hasUnsavedChanges: true,
    );
  }

  // === SMS уведомления ===

  void updateSmsWeatherAlerts(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(smsWeatherAlerts: value),
      hasUnsavedChanges: true,
    );
  }

  void updateSmsReminders(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(smsReminders: value),
      hasUnsavedChanges: true,
    );
  }

  void updateSmsSubscriptionStatus(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(smsSubscriptionStatus: value),
      hasUnsavedChanges: true,
    );
  }

  /// Сохранить настройки на сервере
  Future<bool> saveSettings() async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final updatedSettings = await _repository.updateSettings(state.settings);
      state = NotificationSettingsState.fromSettings(
        updatedSettings,
      ).copyWith(isSaving: false);

      // Сохраняем локально
      await _saveLocalSettings(updatedSettings);

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Ошибка сохранения настроек: $e',
      );
      return false;
    }
  }

  /// Сбросить изменения к исходным
  void resetChanges() {
    if (state.originalSettings != null) {
      state = NotificationSettingsState.fromSettings(state.originalSettings!);
    }
  }

  /// Очистить ошибку
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Проверить, есть ли изменения
  bool hasChanges() {
    if (state.originalSettings == null) return false;
    return state.settings != state.originalSettings;
  }
}

// Провайдер для управления настройками уведомлений
// Работает только с локальными настройками (без API зависимости)
final notificationSettingsProvider = StateNotifierProvider<
  NotificationSettingsNotifier,
  NotificationSettingsState
>((ref) {
  return NotificationSettingsNotifier(
    repository: _LocalNotificationSettingsRepository(),
  );
});

/// Локальный репозиторий для настроек уведомлений (без API)
class _LocalNotificationSettingsRepository
    implements NotificationSettingsRepository {
  @override
  Future<NotificationSettings> getSettings() async {
    return NotificationSettings.defaultSettings();
  }

  @override
  Future<NotificationSettings> updateSettings(
    NotificationSettings settings,
  ) async {
    return settings;
  }

  @override
  Future<NotificationSettings> syncWithServer(
    NotificationSettings localSettings,
  ) async {
    return localSettings;
  }
}
