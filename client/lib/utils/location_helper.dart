import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  /// Проверяет, включены ли сервисы геолокации
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Запрашивает разрешение на доступ к местоположению
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Получает текущую позицию пользователя
  static Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      // Обрабатываем все возможные исключения
      return null;
    }
  }

  /// Получает город по координатам
  static Future<String?> getCityFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return placemark.locality ?? placemark.administrativeArea;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Открывает настройки локации устройства
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Открывает настройки приложения
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}