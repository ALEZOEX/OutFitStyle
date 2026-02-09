import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:outfitstyle_client/core/services/auth_storage.dart';
import 'package:outfitstyle_client/app/api/api_config.dart';

class ProfileRepository {
  final ApiConfig config;
  final AuthStorage authStorage;
  final http.Client httpClient;

  ProfileRepository(this.config, this.authStorage, this.httpClient);

  Future<Map<String, dynamic>> getMe() async {
    final token = await authStorage.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await httpClient.get(
      Uri.parse('${config.apiBase}/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  void dispose() {
    httpClient.close();
  }
}