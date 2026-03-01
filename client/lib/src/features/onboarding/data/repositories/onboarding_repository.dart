import 'package:dio/dio.dart';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart';
import 'package:outfitstyle_client/src/features/onboarding/data/models/onboarding_data.dart';

/// Репозиторий для работы с данными онбординга
class OnboardingRepository {
  final ApiClient _apiClient;
  final AuthStorage _authStorage;

  OnboardingRepository({
    required ApiClient apiClient,
    required AuthStorage authStorage,
  })  : _apiClient = apiClient,
        _authStorage = authStorage;

  /// Отправка предпочтений пользователя на сервер
  /// POST /api/v1/user/preferences
  Future<bool> savePreferences(OnboardingData data) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/user/preferences',
        data: data.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      // Логируем ошибку
      print('[OnboardingRepository] Ошибка сохранения предпочтений: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      print('[OnboardingRepository] DioException: ${e.message}');
      return false;
    } catch (e) {
      print('[OnboardingRepository] Неизвестная ошибка: $e');
      return false;
    }
  }

  /// Получение предпочтений пользователя с сервера
  /// GET /api/v1/user/preferences
  Future<OnboardingData?> getPreferences() async {
    try {
      final response = await _apiClient.get('/api/v1/user/preferences');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return OnboardingData.fromJson(data);
      }

      return null;
    } on DioException catch (e) {
      print('[OnboardingRepository] Ошибка получения предпочтений: ${e.message}');
      return null;
    } catch (e) {
      print('[OnboardingRepository] Неизвестная ошибка: $e');
      return null;
    }
  }

  /// Автоопределение города по IP (используем внешний API)
  Future<Map<String, dynamic>?> detectCityByIp() async {
    try {
      // Используем ipapi.co для определения города по IP
      final response = await _apiClient.raw.get(
        'https://ipapi.co/json/',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'city': data['city'] as String?,
          'lat': data['latitude'] as double?,
          'lon': data['longitude'] as double?,
          'country': data['country_name'] as String?,
        };
      }

      return null;
    } catch (e) {
      print('[OnboardingRepository] Ошибка определения города по IP: $e');
      return null;
    }
  }
}
