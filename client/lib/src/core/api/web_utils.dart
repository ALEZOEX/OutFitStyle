/// Web-specific utilities for browser operations
@JS()
library;

import 'dart:js_interop';

@JS('window.location.reload')
external void _reload();

/// Reloads the current page (web only)
void reloadPage() {
  _reload();
}

/// Gets query parameters from URL (web only)
Map<String, String> getQueryParameters() {
  // Stub for now
  return {};
}

/// Sets hash in URL (web only)
void setHash(String hash) {
  // Stub for now
}

/// Gets hash from URL (web only)
String getHash() {
  return '';
}
