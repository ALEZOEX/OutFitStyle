import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_settings.dart';
import 'auth_storage.dart';

class UserSettingsService {
  final String baseUrl;
  final AuthStorage authStorage;

  UserSettingsService({
    required this.baseUrl,
    required this.authStorage,
  });

  Future<UserSettings> fetchSettings() async {
    final token = await authStorage.readAccessToken();
    final userId = await authStorage.readUserId();

    if (token == null || userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    final uri = Uri.parse('$baseUrl/users/$userId/profile');
    final resp = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'Ошибка загрузки профиля: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return UserSettings.fromJson(data);
  }

  Future<UserSettings> updateSettings(UserSettings settings) async {
    final token = await authStorage.readAccessToken();
    final userId = await authStorage.readUserId();

    if (token == null || userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    final uri = Uri.parse('$baseUrl/users/${settings.userId}/profile');
    final resp = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(settings.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'Ошибка сохранения профиля: ${resp.statusCode} ${resp.body}');
    }

    // user_handler.UpdateUserProfile сейчас возвращает:
    // { "message": "Profile updated successfully" }
    // поэтому просто возвращаем те же settings (либо можно вызвать fetchSettings() ещё раз)
    return settings;
  }
}