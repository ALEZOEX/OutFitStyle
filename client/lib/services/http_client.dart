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
    final accessToken = await _authStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Content-Type ставим только если не задан (и не мешаем multipart).
    request.headers.putIfAbsent('Content-Type', () => 'application/json');

    // Сохраняем тело ДО отправки, иначе повторить запрос будет нельзя.
    List<int>? originalBodyBytes;
    Encoding? originalEncoding;
    if (request is http.Request) {
      originalBodyBytes = request.bodyBytes;
      originalEncoding = request.encoding;
    }

    final response = await _inner.send(request);
    if (response.statusCode != 401) return response;

    // Освобождаем соединение, если собираемся ретраить.
    await response.stream.drain();

    final refreshed = await _tryRefreshToken();
    if (!refreshed) return response;

    final newToken = await _authStorage.readAccessToken();
    if (newToken == null || newToken.isEmpty) return response;

    // Ретраим только http.Request (JSON-запросы). Multipart/другие типы — отдельно.
    if (request is! http.Request) {
      return response;
    }

    final retry = http.Request(request.method, request.url)
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection
      ..headers.addAll(request.headers)
      ..headers['Authorization'] = 'Bearer $newToken'
      ..bodyBytes = originalBodyBytes ?? const <int>[];

    // encoding есть только у http.Request
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
