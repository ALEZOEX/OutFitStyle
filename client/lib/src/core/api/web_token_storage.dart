// Web-specific token storage utilities
// Only available when compiling for web
import 'package:web/web.dart' as web;

/// Получение access_token из localStorage (только для Web)
/// SharedPreferences на Web может быть не инициализирован вовремя
String? getAccessTokenFromLocalStorage() {
  try {
    // Приоритет 1: стандартный ключ SharedPreferences на Web
    final token = web.window.localStorage.getItem('flutter.access_token');
    if (token != null && token.isNotEmpty) return token;

    // Приоритет 2: ключ 'access_token' (используется SessionManager)
    final token2 = web.window.localStorage.getItem('access_token');
    if (token2 != null && token2.isNotEmpty) return token2;
  } catch (_) {
    // Игнорируем ошибки для non-web платформ
  }
  return null;
}
