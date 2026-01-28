import 'dart:convert';
import 'package:http/http.dart' as http;

import '../app/api/api_config.dart';
import '../models/token_pair.dart';
import 'auth_storage.dart';

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

    // Теперь мы исходный response НЕ возвращаем, можно освободить соединение
    await response.stream.drain();

    final newToken = await _authStorage.readAccessToken();
    if (newToken == null || newToken.isEmpty) {
      return response; // тут response уже drained, но это крайний случай; лучше не доходить
    }

    if (request is! http.Request) {
      // Для MultipartRequest и т.п. нужен отдельный клонер
      return response;
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

    final uri = Uri.parse('${_apiConfig.apiBase}/auth/refresh');

    final resp = await _inner.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (resp.statusCode != 200) return false;

    final data = jsonDecode(resp.body);
    // подстрой под фактический формат ответа API:
    // либо { "tokens": {...} }, либо { "access_token": "...", "refresh_token": "..." }
    final tokensJson = data['tokens'];

    if (tokensJson == null) {
      // Если формат ответа не соответствует ожидаемому, возвращаем false
      return false;
    }

    try {
      final tokens = TokenPair.fromJson(tokensJson);
      await _authStorage.writeTokenPair(tokens);
      return true;
    } catch (e) {
      // Если не удалось распарсить токены, возвращаем false
      return false;
    }
  }
}
