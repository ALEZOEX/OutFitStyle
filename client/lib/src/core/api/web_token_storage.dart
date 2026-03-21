/// Web-specific token storage utilities
/// Only available when compiling for web
import 'package:web/web.dart' as web;

/// Получение access_token из localStorage (только для Web)
/// SharedPreferences на Web может быть не инициализирован вовремя
String? getAccessTokenFromLocalStorage() {
  try {
    return web.window.localStorage.getItem('flutter.access_token');
  } catch (_) {
    // Игнорируем ошибки для non-web платформ
  }
  return null;
}
