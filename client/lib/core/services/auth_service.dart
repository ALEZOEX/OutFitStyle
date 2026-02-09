import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:outfitstyle_client/core/services/auth_storage.dart';

class AuthService {
  final String apiBase;
  final AuthStorage authStorage;
  final http.Client httpClient;

  AuthService({
    required this.apiBase,
    required this.authStorage,
    required this.httpClient,
  });

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await httpClient.post(
      Uri.parse('$apiBase/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await authStorage.saveTokens(data['accessToken'], data['refreshToken']);
      return data;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await httpClient.post(
      Uri.parse('$apiBase/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await authStorage.saveTokens(data['accessToken'], data['refreshToken']);
      return data;
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> logout() async {
    await authStorage.clearSession();
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await authStorage.getAccessToken();
    if (token == null) {
      throw Exception('No access token available');
    }

    final response = await httpClient.get(
      Uri.parse('$apiBase/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user profile');
    }
  }

  Future<Map<String, dynamic>> silentLogin() async {
    final refreshToken = await authStorage.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await httpClient.post(
      Uri.parse('$apiBase/auth/refresh'),
      headers: {
        'Authorization': 'Bearer $refreshToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await authStorage.saveTokens(data['accessToken'], data['refreshToken']);
      return data;
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}