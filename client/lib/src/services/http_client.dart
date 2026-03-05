import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api/api_config.dart';
import 'package:outfitstyle_client/src/core/models/token_pair.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart';

class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final ApiConfig _apiConfig;
  final AuthStorage _authStorage;

  AuthenticatedHttpClient(this._inner, this._apiConfig, this._authStorage);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _authStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.headers.putIfAbsent('Content-Type', () => 'application/json');

    // Сохраняем body ДО отправки (иначе повторить не получится)
    List<int>? originalBodyBytes;
    Encoding? originalEncoding;
    if (request is http.Request) {
      originalBodyBytes = request.bodyBytes;
      originalEncoding = request.encoding;
    }

    final response = await _inner.send(request);

    if (response.statusCode != 401) {
      return response;
    }

    // ВАЖНО: если refresh НЕ удался — возвращаем исходный response
    // и НЕ читаем response.stream, иначе словим "Stream has already been listened to".
    final refreshed = await _tryRefreshToken();
    if (!refreshed) {
      return response;
    }

    // Проверяем ДО drain — если не можем повторить, не портим response
    if (request is! http.Request) {
      // Не можем клонировать MultipartRequest — возвращаем оригинальный 401
      // НЕ вызываем drain(), чтобы caller мог прочитать тело ошибки
      return response;
    }

    // Теперь точно будем повторять — можно drain
    await response.stream.drain();

    final newToken = await _authStorage.readAccessToken();
    if (newToken == null || newToken.isEmpty) {
      // Refresh прошёл, но токен не получен — возвращаем 401
      return http.StreamedResponse(
        Stream.value(utf8.encode('{"error":"unauthorized"}')),
        401,
        request: request,
        headers: {'Content-Type': 'application/json'},
      );
    }

    final retry = http.Request(request.method, request.url)
      ..headers.addAll(request.headers)
      ..headers['Authorization'] = 'Bearer $newToken'
      ..bodyBytes = originalBodyBytes ?? const <int>[];

    if (originalEncoding != null) {
      retry.encoding = originalEncoding;
    }

    return _inner.send(retry);
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _authStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    // Используем /api/v1/auth/refresh
    final uri = Uri.parse('${_apiConfig.apiBase}/api/v1/auth/refresh');

    final resp = await _inner.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (resp.statusCode != 200) return false;

    final data = jsonDecode(resp.body);
    // подстрой под фактический формат ответа API:
    // либо { "tokens": {...} }, либо { "access_token": "...", "refresh_token": "..." }

    // Проверяем, является ли 'tokens' мапом
    if (data['tokens'] != null && data['tokens'] is Map<String, dynamic>) {
      try {
        final tokens = TokenPair.fromJson(data['tokens']);
        await _authStorage.writeTokenPair(tokens);
        return true;
      } catch (e) {
        // Если не удалось распарсить токены, возвращаем false
        return false;
      }
    } else if (data is Map<String, dynamic> &&
        data.containsKey('access_token') &&
        data.containsKey('refresh_token') &&
        data.containsKey('expires_at')) {
      // Альтернативный формат: прямой объект с токенами
      try {
        final tokens = TokenPair.fromJson(data);
        await _authStorage.writeTokenPair(tokens);
        return true;
      } catch (e) {
        // Если не удалось распарсить токены, возвращаем false
        return false;
      }
    } else {
      // Если формат ответа не соответствует ожидаемому, возвращаем false
      return false;
    }
  }
}
