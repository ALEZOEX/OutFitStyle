import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Данные о местоположении пользователя
class UserLocation {
  final double latitude;
  final double longitude;
  final String? cityName;
  final DateTime updatedAt;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.cityName,
    required this.updatedAt,
  });

  /// Москва по умолчанию
  static UserLocation get moscow => UserLocation(
    latitude: 55.7558,
    longitude: 37.6173,
    cityName: 'Москва',
    updatedAt: DateTime.now(),
  );

  UserLocation copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    DateTime? updatedAt,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: json['latitude'] as double? ?? 55.7558,
      longitude: json['longitude'] as double? ?? 37.6173,
      cityName: json['cityName'] as String?,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
    );
  }
}

/// Провайдер местоположения пользователя
final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, UserLocation>(
      (ref) => UserLocationNotifier(),
    );

class UserLocationNotifier extends StateNotifier<UserLocation> {
  UserLocationNotifier() : super(UserLocation.moscow) {
    _loadLocation();
  }

  /// Загрузить местоположение из хранилища
  Future<void> _loadLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('user_location');
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = UserLocation.fromJson(json);
      }
    } catch (e) {
      // При ошибке используем Москву по умолчанию
      state = UserLocation.moscow;
    }
  }

  /// Установить местоположение
  Future<void> setLocation(double lat, double lon, String cityName) async {
    state = state.copyWith(
      latitude: lat,
      longitude: lon,
      cityName: cityName,
      updatedAt: DateTime.now(),
    );
    await _saveLocation();
  }

  /// Установить местоположение из координат
  Future<void> setCoordinates(double lat, double lon) async {
    state = state.copyWith(
      latitude: lat,
      longitude: lon,
      updatedAt: DateTime.now(),
    );
    await _saveLocation();
  }

  /// Сохранить местоположение
  Future<void> _saveLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_location', jsonEncode(state.toJson()));
    } catch (e) {
      // Игнорируем ошибку сохранения
    }
  }

  /// Сбросить местоположение к Москве
  Future<void> resetToDefault() async {
    state = UserLocation.moscow;
    await _saveLocation();
  }
}
