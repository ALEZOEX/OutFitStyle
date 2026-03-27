// Web-specific token storage helper
// Импортируется только на Web через conditional import

import 'package:web/web.dart' as web;

/// Сохранение токена в localStorage (Web)
void saveTokenToLocalStorage(String token) {
  try {
    web.window.localStorage.setItem('flutter.access_token', token);
  } catch (e) {
    // Игнорируем ошибки localStorage на Web
  }
}
