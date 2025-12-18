import '../models/tokens.dart';
import 'api_service.dart';
import 'auth_storage.dart';

class AuthService {
  final String baseUrl; // includes /api/v1
  final AuthStorage authStorage;
  late final ApiService _api;

  AuthService({
    required this.baseUrl,
    required this.authStorage,
  }) {
    _api = ApiService(baseUrl: baseUrl, authStorage: authStorage);
  }

  Future<TokenPair> register({
    required String email,
    required String password,
    String? username,
    String? displayName,
    String? locale,
  }) async {
    final data = await _api.postJson('/auth/register', body: {
      'email': email,
      'password': password,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (locale != null) 'locale': locale,
    }) as Map<String, dynamic>;

    final tokens = TokenPair.fromJson(data['tokens'] as Map<String, dynamic>);

    await authStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );

    return tokens;
  }

  Future<TokenPair> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  }) async {
    final data = await _api.postJson('/auth/login', body: {
      'email': email,
      'password': password,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
    }) as Map<String, dynamic>;

    final tokens = TokenPair.fromJson(data['tokens'] as Map<String, dynamic>);

    await authStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );

    return tokens;
  }

  /// Optional manual refresh (ApiService does it automatically on 401).
  Future<TokenPair?> refresh() async {
    final refresh = await authStorage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return null;

    final data = await _api.postJson('/auth/refresh', body: {
      'refresh_token': refresh,
    }) as Map<String, dynamic>;

    final tokens = TokenPair.fromJson(data['tokens'] as Map<String, dynamic>);

    await authStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );

    return tokens;
  }

  Future<void> logout({bool allDevices = false}) async {
    // logout требует Authorization (ApiService добавит)
    await _api.postJson('/auth/logout', body: {'all_devices': allDevices});
    await authStorage.clear();
  }

  Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final data = await _api.postJson('/auth/verify-code', body: {
        'email': email,
        'code': code,
      }) as Map<String, dynamic>;
      return data;
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
  }

  Future<TokenPair> signInWithGoogle({
    required String idToken,
  }) async {
    final data = await _api.postJson('/auth/google', body: {
      'id_token': idToken,
    }) as Map<String, dynamic>;

    final tokens = TokenPair.fromJson(data['tokens'] as Map<String, dynamic>);

    await authStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );

    return tokens;
  }

  Future<void> requestPasswordReset({
    required String email,
  }) async {
    await _api.postJson('/auth/reset-password/request', body: {
      'email': email,
    });
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _api.postJson('/auth/reset-password', body: {
      'token': token,
      'new_password': newPassword,
    });
  }
}