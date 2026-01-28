import 'package:http/http.dart' as http;
import 'dart:convert';
import '../app/api/api_config.dart';
import 'auth_storage.dart';
import '../models/token_pair.dart';

class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final ApiConfig _apiConfig;
  final AuthStorage _authStorage;

  AuthenticatedHttpClient(this._inner, this._apiConfig, this._authStorage);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Добавляем токен аутентификации к каждому запросу
    final token = await _authStorage.readAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Устанавливаем Content-Type, если его нет
    if (!request.headers.containsKey('Content-Type')) {
      request.headers['Content-Type'] = 'application/json';
    }

    final response = await _inner.send(request);

    // Если получили 401, пробуем обновить токен и повторить запрос
    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Повторяем оригинальный запрос с новым токеном
        // Для этого нужно создать новый запрос с теми же параметрами
        final newToken = await _authStorage.readAccessToken();
        if (newToken != null) {
          // Повторяем тот же самый запрос, но с новым токеном
          final retryRequest = http.Request(request.method, request.url)
            ..headers.addAll(request.headers)
            ..headers['Authorization'] = 'Bearer $newToken';

          // Копируем тело запроса, если оно есть
          if (request.method != 'GET' && request.method != 'HEAD') {
            final bytes = await request.finalize().toBytes();
            retryRequest.bodyBytes = bytes;
          }

          return await _inner.send(retryRequest);
        }
      }
    }

    return response;
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _authStorage.readRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${_apiConfig.apiBase}/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('tokens')) {
          final tokens = TokenPair.fromJson(data['tokens']);
          await _authStorage.writeTokenPair(tokens);
          return true;
        }
      }
    } catch (e) {
      // Игнорируем ошибки обновления токена
      // Token refresh failed: $e - logging would be handled by error handler
    }
    return false;
  }
}