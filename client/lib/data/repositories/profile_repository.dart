import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../app/api/api_config.dart';
import '../../services/auth_storage.dart';
import '../../services/http_client.dart';

class ProfileRepository {
  final ApiConfig _config;
  final AuthStorage _auth;
  final http.Client _httpClient;

  ProfileRepository(this._config, this._auth, [http.Client? httpClient])
      : _httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> getMe() async {
    try {
      final client = AuthenticatedHttpClient(_httpClient, _config, _auth);
      final response = await client.get(
        Uri.parse('${_config.apiBase}/me'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Get profile failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }

  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> patch) async {
    try {
      final client = AuthenticatedHttpClient(_httpClient, _config, _auth);
      final response = await client.put(
        Uri.parse('${_config.apiBase}/user/preferences'),
        body: jsonEncode(patch),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Update preferences failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Update preferences error: $e');
    }
  }

  Future<Map<String, dynamic>> updateBody(Map<String, dynamic> patch) async {
    try {
      final client = AuthenticatedHttpClient(_httpClient, _config, _auth);
      final response = await client.put(
        Uri.parse('${_config.apiBase}/user/body'),
        body: jsonEncode(patch),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Update body failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Update body error: $e');
    }
  }
}