/// Web-specific utilities for browser operations
library;

import 'package:web/web.dart' as web;

/// Reloads the current page (web only)
void reloadPage() {
  web.window.location.reload();
}

/// Gets query parameters from URL (web only)
Map<String, String> getQueryParameters() {
  final query = web.window.location.search;
  if (query.isEmpty) return {};
  
  final params = <String, String>{};
  final queryString = query.substring(1); // Remove leading '?'
  
  for (final pair in queryString.split('&')) {
    final parts = pair.split('=');
    if (parts.length == 2) {
      params[parts[0]] = Uri.decodeComponent(parts[1]);
    }
  }
  
  return params;
}

/// Sets hash in URL (web only)
void setHash(String hash) {
  web.window.location.hash = hash;
}

/// Gets hash from URL (web only)
String getHash() {
  return web.window.location.hash;
}
