import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api/api_config.dart';

/// HTTP-клиент для API запросов с Firebase ID Token авторизацией
/// @Deprecated Используйте ApiClient из core/api/api_client.dart
@Deprecated('Используйте ApiClient из core/api/api_client.dart')
class ApiClient {
  final ApiConfig config;

  ApiClient({required this.config});

  /// GET-запрос с опциональными query параметрами
  Future<http.Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    final uri = Uri.parse('${config.apiBase}$endpoint').replace(
      queryParameters: params?.map((k, v) => MapEntry(k, v.toString())),
    );

    return await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  /// POST-запрос с опциональным body
  Future<http.Response> post(String endpoint, {dynamic body}) async {
    final uri = Uri.parse('${config.apiBase}$endpoint');

    return await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// PUT-запрос с опциональным body
  Future<http.Response> put(String endpoint, {dynamic body}) async {
    final uri = Uri.parse('${config.apiBase}$endpoint');

    return await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// DELETE-запрос
  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('${config.apiBase}$endpoint');

    return await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }
}