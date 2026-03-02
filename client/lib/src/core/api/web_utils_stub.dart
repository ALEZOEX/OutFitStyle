/// Stub for non-web platforms
library;

/// Reloads the current page (no-op on non-web)
void reloadPage() {
  // No-op on non-web platforms
}

/// Gets query parameters from URL (empty on non-web)
Map<String, String> getQueryParameters() {
  return {};
}

/// Sets hash in URL (no-op on non-web)
void setHash(String hash) {
  // No-op on non-web platforms
}

/// Gets hash from URL (empty on non-web)
String getHash() {
  return '';
}
