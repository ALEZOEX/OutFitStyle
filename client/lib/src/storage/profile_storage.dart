import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Данные для заполнения профиля пользователя
class CompleteProfileData {
  final String displayName;
  final String email;
  final String? photoPath;
  final String? photoUrl;

  const CompleteProfileData({
    required this.displayName,
    required this.email,
    this.photoPath,
    this.photoUrl,
  });

  /// Создать из JSON
  factory CompleteProfileData.fromJson(Map<String, dynamic> json) {
    return CompleteProfileData(
      displayName: json['display_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoPath: json['photo_path'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  /// Преобразовать в JSON
  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'email': email,
      'photo_path': photoPath,
      'photo_url': photoUrl,
    };
  }

  /// Создать копию с изменениями
  CompleteProfileData copyWith({
    String? displayName,
    String? email,
    String? photoPath,
    String? photoUrl,
  }) {
    return CompleteProfileData(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoPath: photoPath ?? this.photoPath,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

/// Хранилище данных профиля в SharedPreferences
class ProfileStorage {
  static const String _keyProfileData = 'profile_data';
  static const String _keyIsProfileComplete = 'is_profile_complete';
  static const String _keyUserId = 'user_id';

  final SharedPreferences _prefs;

  ProfileStorage(this._prefs);

  /// Сохранить данные профиля
  Future<void> saveProfileData(CompleteProfileData data) async {
    await _prefs.setString(_keyProfileData, jsonEncode(data.toJson()));
  }

  /// Загрузить данные профиля
  Future<CompleteProfileData?> getProfileData() async {
    final dataStr = _prefs.getString(_keyProfileData);
    if (dataStr == null || dataStr.isEmpty) {
      return null;
    }
    try {
      final json = jsonDecode(dataStr) as Map<String, dynamic>;
      return CompleteProfileData.fromJson(json);
    } catch (e) {
      print('[ProfileStorage] Ошибка парсинга данных профиля: $e');
      return null;
    }
  }

  /// Очистить данные профиля
  Future<void> clearProfileData() async {
    await _prefs.remove(_keyProfileData);
  }

  /// Установить флаг завершения профиля
  Future<void> setProfileComplete(bool isComplete) async {
    await _prefs.setBool(_keyIsProfileComplete, isComplete);
  }

  /// Проверить, завершен ли профиль
  bool get isProfileComplete {
    return _prefs.getBool(_keyIsProfileComplete) ?? false;
  }

  /// Сохранить ID пользователя
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_keyUserId, userId);
  }

  /// Получить ID пользователя
  String? get userId => _prefs.getString(_keyUserId);

  /// Очистить все данные профиля
  Future<void> clear() async {
    await _prefs.remove(_keyProfileData);
    await _prefs.remove(_keyIsProfileComplete);
    await _prefs.remove(_keyUserId);
  }
}
