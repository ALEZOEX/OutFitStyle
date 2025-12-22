import 'dart:typed_data';

import 'api_service.dart';
import 'auth_storage.dart';

class UserSettingsService {
  final ApiService _api;

  UserSettingsService({
    required String baseUrl,
    required AuthStorage authStorage,
  }) : _api = ApiService(baseUrl: baseUrl, authStorage: authStorage);

  Future<Map<String, dynamic>> getMyProfile() async {
    final data = await _api.getJson('/user/profile') as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? gender,
    String? birthDate, // YYYY-MM-DD
    String? defaultLocation,
    double? defaultLatitude,
    double? defaultLongitude,
    String? timezone,
    String? locale,
  }) async {
    final body = <String, dynamic>{
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (defaultLocation != null) 'default_location': defaultLocation,
      if (defaultLatitude != null) 'default_latitude': defaultLatitude,
      if (defaultLongitude != null) 'default_longitude': defaultLongitude,
      if (timezone != null) 'timezone': timezone,
      if (locale != null) 'locale': locale,
    };

    final data = await _api.putJson('/user/profile', body: body) as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> prefsPatch) async {
    final data = await _api.putJson('/user/preferences', body: prefsPatch) as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> updateProfilePatch(Map<String, dynamic> patch) async {
    final data = await _api.putJson('/user/profile', body: patch) as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> updateBodyMeasurements(Map<String, dynamic> patch) async {
    final data = await _api.putJson('/user/body-measurements', body: patch) as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> exportUserData() async {
    final data = await _api.getJson('/user/export') as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> deleteAccount({required String password}) async {
    final data = await _api.deleteJson('/user/account', body: {'password': password}) as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> listSessions() async {
    final data = await _api.getJson('/user/sessions') as Map<String, dynamic>;
    return data;
  }

  Future<void> deleteSession(String sessionId) async {
    await _api.deleteJson('/user/sessions/$sessionId');
  }

  Future<Map<String, dynamic>> uploadAvatarBytes({
    required Uint8List bytes,
    required String filename,
    String contentType = 'image/jpeg',
  }) async {
    final data = await _api.uploadMultipartBytes(
      path: '/user/avatar',
      fieldName: 'file',
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    ) as Map<String, dynamic>;
    return data;
  }
}