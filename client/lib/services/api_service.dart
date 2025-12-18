import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'auth_storage.dart';
import '../models/tokens.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic body;

  ApiException(this.statusCode, this.message, {this.body});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  final String baseUrl; // expected ".../api/v1"
  final AuthStorage authStorage;
  final http.Client _client;

  Completer<void>? _refreshCompleter;

  ApiService({
    required this.baseUrl,
    required this.authStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath').replace(queryParameters: query);
  }

  Future<Map<String, String>> _authHeaders({Map<String, String>? extra}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (extra != null) ...extra,
    };

    final token = await authStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final res = await _sendWithRetry(() async {
      final headers = await _authHeaders();
      return _client.get(_uri(path, query), headers: headers);
    });
    return _decode(res);
  }

  Future<dynamic> postJson(String path, {Object? body}) async {
    final res = await _sendWithRetry(() async {
      final headers = await _authHeaders();
      return _client.post(_uri(path), headers: headers, body: jsonEncode(body ?? {}));
    });
    return _decode(res);
  }

  Future<dynamic> putJson(String path, {Object? body}) async {
    final res = await _sendWithRetry(() async {
      final headers = await _authHeaders();
      return _client.put(_uri(path), headers: headers, body: jsonEncode(body ?? {}));
    });
    return _decode(res);
  }

  Future<dynamic> deleteJson(String path, {Object? body}) async {
    final res = await _sendWithRetry(() async {
      final headers = await _authHeaders();
      return _client.delete(_uri(path), headers: headers, body: jsonEncode(body ?? {}));
    });
    return _decode(res);
  }

  /// Multipart upload helper. Retry-on-401 works because we build request from bytes.
  Future<dynamic> uploadMultipartBytes({
    required String path,
    required String fieldName,
    required List<int> bytes,
    required String filename,
    String? contentType,
    Map<String, String>? fields,
  }) async {
    Future<http.StreamedResponse> buildAndSend() async {
      final token = await authStorage.readAccessToken();
      final req = http.MultipartRequest('POST', _uri(path));

      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }

      if (fields != null) {
        req.fields.addAll(fields);
      }

      req.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: (contentType != null) ? MediaType.parse(contentType) : null,
        ),
      );

      return req.send();
    }

    final streamed = await _sendStreamedWithRetry(buildAndSend);
    final res = await http.Response.fromStream(streamed);
    return _decode(res);
  }

  // ---------- Internal ----------

  Future<http.Response> _sendWithRetry(Future<http.Response> Function() send) async {
    http.Response res = await send();

    if (res.statusCode != 401) {
      _throwIfNotOk(res);
      return res;
    }

    final refreshed = await _refreshIfNeeded();
    if (!refreshed) {
      await authStorage.clear();
      _throwIfNotOk(res); // will throw 401
      return res;
    }

    res = await send();
    _throwIfNotOk(res);
    return res;
  }

  Future<http.StreamedResponse> _sendStreamedWithRetry(Future<http.StreamedResponse> Function() send) async {
    http.StreamedResponse res = await send();

    if (res.statusCode != 401) {
      return res;
    }

    final refreshed = await _refreshIfNeeded();
    if (!refreshed) {
      await authStorage.clear();
      return res;
    }

    res = await send();
    return res;
  }

  Future<bool> _refreshIfNeeded() async {
    // single-flight refresh
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      final token = await authStorage.readAccessToken();
      return token != null && token.isNotEmpty;
    }

    final completer = Completer<void>();
    _refreshCompleter = completer;

    try {
      final refresh = await authStorage.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        return false;
      }

      final url = _uri('/auth/refresh');
      final res = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refresh}),
      );

      if (res.statusCode ~/ 100 != 2) {
        return false;
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final tokensJson = (data['tokens'] as Map<String, dynamic>);
      final pair = TokenPair.fromJson(tokensJson);

      await authStorage.saveTokens(
        accessToken: pair.accessToken,
        refreshToken: pair.refreshToken,
        expiresAt: pair.expiresAt,
      );

      return true;
    } catch (_) {
      return false;
    } finally {
      completer.complete();
      _refreshCompleter = null;
    }
  }

  dynamic _decode(http.Response res) {
    _throwIfNotOk(res);

    if (res.body.isEmpty) return null;
    final decoded = jsonDecode(res.body);

    return decoded;
  }

  void _throwIfNotOk(http.Response res) {
    if (res.statusCode ~/ 100 == 2) return;

    dynamic body;
    try {
      body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    } catch (_) {
      body = res.body;
    }

    final msg = (body is Map && body['error'] is String) ? body['error'] as String : 'Request failed';
    throw ApiException(res.statusCode, msg, body: body);
  }

}