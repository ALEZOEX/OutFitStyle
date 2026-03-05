import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api/api_config.dart';
import 'package:outfitstyle_client/src/services/auth_storage.dart';

/// HTTP-клиент для API запросов с авторизацией
class ApiClient {
  final ApiConfig config;
  final AuthStorage storage;

  ApiClient({required this.config, required this.storage});

  /// GET-запрос с опциональными query параметрами
  Future<http.Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    final token = await storage.readAccessToken();
    final uri = Uri.parse('${config.apiBase}$endpoint').replace(
      queryParameters: params?.map((k, v) => MapEntry(k, v.toString())),
    );

    return await http.get(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  /// POST-запрос с опциональным body
  Future<http.Response> post(String endpoint, {dynamic body}) async {
    final token = await storage.readAccessToken();
    final uri = Uri.parse('${config.apiBase}$endpoint');

    return await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// PUT-запрос с опциональным body
  Future<http.Response> put(String endpoint, {dynamic body}) async {
    final token = await storage.readAccessToken();
    final uri = Uri.parse('${config.apiBase}$endpoint');

    return await http.put(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// DELETE-запрос
  Future<http.Response> delete(String endpoint) async {
    final token = await storage.readAccessToken();
    final uri = Uri.parse('${config.apiBase}$endpoint');

    return await http.delete(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}