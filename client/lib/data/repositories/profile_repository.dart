import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../app/api/api_config.dart';
import '../../services/auth_storage.dart';

class ProfileRepository {
  final ApiConfig _config;
  final AuthStorage _auth;

  ProfileRepository(this._config, this._auth);

  Future<Map<String, dynamic>> getMe() async {
    try {
      final token = await _auth.readAccessToken();
      final response = await http.get(
        Uri.parse('${_config.apiBase}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
      final token = await _auth.readAccessToken();
      final response = await http.patch(
        Uri.parse('${_config.apiBase}/me/preferences'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
      final token = await _auth.readAccessToken();
      final response = await http.patch(
        Uri.parse('${_config.apiBase}/me/body'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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