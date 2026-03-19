import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api/api_config.dart';

/// HTTP клиент с JWT авторизацией для Market Service API
///
/// @Deprecated Используйте ApiClient с Firebase ID Token авторизацией
@Deprecated('Используйте ApiClient с Firebase ID Token. JWT auth устарел.')
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final ApiConfig _apiConfig;

  AuthenticatedHttpClient(this._inner, this._apiConfig);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await ApiConfig.getAccessToken();
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

    final newToken = await ApiConfig.getAccessToken();
    if (newToken == null || newToken.isEmpty) {
      // Refresh прошёл, но токен не получен — возвращаем 401
      return http.StreamedResponse(
        Stream.value(utf8.encode('{"error":"unauthorized"}')),
        401,
        request: request,
        headers: {'Content-Type': 'application/json'},
      );
    }

    final retry =
        http.Request(request.method, request.url)
          ..headers.addAll(request.headers)
          ..headers['Authorization'] = 'Bearer $newToken'
          ..bodyBytes = originalBodyBytes ?? const <int>[];

    if (originalEncoding != null) {
      retry.encoding = originalEncoding;
    }

    return _inner.send(retry);
  }

  Future<bool> _tryRefreshToken() async {
    // Refresh token больше не используется — Firebase ID Token
    return false;
  }
}
