import 'package:dio/dio.dart';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import 'package:outfitstyle_client/src/features/onboarding/data/models/onboarding_data.dart';
import 'package:outfitstyle_client/src/utils/logger.dart';

class OnboardingRepository {
  final ApiClient _apiClient;

  OnboardingRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<bool> savePreferences(OnboardingData data) async {
    try {
      final response = await _apiClient.put(
        '/api/v1/user/preferences',
        data: data.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      AppLogger.warning('Failed to save preferences: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      AppLogger.error('DioException while saving preferences', e);
      return false;
    } catch (e) {
      AppLogger.error('Error saving preferences', e);
      return false;
    }
  }

  Future<OnboardingData?> getPreferences() async {
    try {
      final response = await _apiClient.get('/api/v1/user/preferences');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return OnboardingData.fromJson(data);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error('Error getting preferences', e);
      return null;
    } catch (e) {
      AppLogger.error('Error getting preferences', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> detectCityByIp() async {
    try {
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
      AppLogger.error('Error detecting city by IP', e);
      return null;
    }
  }
}
