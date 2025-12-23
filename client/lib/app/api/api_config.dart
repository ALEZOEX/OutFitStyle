import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  final Uri host;          // http://10.0.2.2:8080 (без /api/v1)
  final String apiPrefix;  // /api/v1

  const ApiConfig({
    required this.host,
    this.apiPrefix = '/api/v1',
  });

  Uri get apiBase => host.replace(path: apiPrefix);

  /// Собирает endpoint без двойных слешей и без дублирования apiPrefix.
  Uri endpoint(List<String> pathSegments, {Map<String, dynamic>? query}) {
    final baseSegs = <String>[
      ...apiBase.pathSegments.where((s) => s.isNotEmpty),
      ...pathSegments.where((s) => s.isNotEmpty),
    ];

    return apiBase.replace(
      pathSegments: baseSegs,
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }
}

/// Единственное место, где решаем "localhost vs emulator".
Uri normalizeHostForPlatform(Uri uri) {
  // Web: localhost корректен
  if (kIsWeb) return uri;

  // Android emulator: localhost -> 10.0.2.2 (если ты реально хочешь достучаться до хоста)
  if (Platform.isAndroid && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
    return uri.replace(host: '10.0.2.2');
  }

  return uri;
}