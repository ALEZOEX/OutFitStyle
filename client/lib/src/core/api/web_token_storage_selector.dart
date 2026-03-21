/// Conditional export for web token storage
/// @defaultExport: web_token_storage_stub.dart (для всех платформ)
/// @web: web_token_storage.dart (только для web)

export 'web_token_storage_stub.dart'
    if (dart.library.html) 'web_token_storage.dart';
