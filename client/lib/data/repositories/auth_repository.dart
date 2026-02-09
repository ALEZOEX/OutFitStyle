import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:outfitstyle_client/core/services/auth_service.dart';
import 'package:outfitstyle_client/core/services/auth_storage.dart';
import 'package:outfitstyle_client/app/api/api_config.dart';

class AuthRepository implements IAuthRepository {
  final ApiConfig config;
  final AuthStorage authStorage;
  final http.Client httpClient;

  AuthRepository(this.config, this.authStorage, this.httpClient);

  @override
  Future<bool> isAuthed() async {
    final token = await authStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    final authService = AuthService(
      apiBase: config.apiBase,
      authStorage: authStorage,
      httpClient: httpClient,
    );
    await authService.logout();
  }

  @override
  Future<void> login(String email, String password) async {
    final authService = AuthService(
      apiBase: config.apiBase,
      authStorage: authStorage,
      httpClient: httpClient,
    );
    await authService.login(email, password);
  }

  @override
  Future<void> register(String email, String password, String name) async {
    final authService = AuthService(
      apiBase: config.apiBase,
      authStorage: authStorage,
      httpClient: httpClient,
    );
    await authService.register(email, password, name);
  }

  @override
  Future<void> forgotPassword(String email) async {
    final authService = AuthService(
      apiBase: config.apiBase,
      authStorage: authStorage,
      httpClient: httpClient,
    );
    await authService.forgotPassword(email);
  }

  @override
  Future<String?> getAuthToken() async {
    return await authStorage.getAccessToken();
  }

  @override
  Future<void> refreshToken() async {
    final authService = AuthService(
      apiBase: config.apiBase,
      authStorage: authStorage,
      httpClient: httpClient,
    );
    await authService.refreshToken();
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    final authService = AuthService(
      apiBase: config.apiBase,
      authStorage: authStorage,
      httpClient: httpClient,
    );
    await authService.updateProfile(profileData);
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final authService = AuthService(
      apiBase: config.apiBase,
      authStorage: authStorage,
      httpClient: httpClient,
    );
    return await authService.getUserProfile();
  }

  void dispose() {
    httpClient.close();
  }
}