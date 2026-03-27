// Web-specific token storage helper
// Импортируется только на Web через conditional import

import 'package:web/web.dart' as web;
import 'dart:developer' as developer;

/// Сохранение токена в localStorage (Web)
/// Сохраняет с обоими ключами для совместимости:
/// - 'access_token' (основной ключ, используется SessionManager)
/// - 'flutter.access_token' (ключ SharedPreferences на Web)
void saveTokenToLocalStorage(String token) {
  try {
    final timestamp = DateTime.now().toIso8601String();
    
    // Сохраняем с основным ключом 'access_token'
    web.window.localStorage.setItem('access_token', token);
    developer.log(
      '[$timestamp] [WebTokenHelper] ✅ Token saved to localStorage with key "access_token" (${token.length} chars)',
      name: 'WebTokenHelper',
    );
    
    // Сохраняем с ключом 'flutter.access_token' для совместимости
    web.window.localStorage.setItem('flutter.access_token', token);
    developer.log(
      '[$timestamp] [WebTokenHelper] ✅ Token saved to localStorage with key "flutter.access_token"',
      name: 'WebTokenHelper',
    );
    
    // Верификация: читаем обратно и проверяем
    final savedToken1 = web.window.localStorage.getItem('access_token');
    final savedToken2 = web.window.localStorage.getItem('flutter.access_token');
    
    if (savedToken1 != null && savedToken1.isNotEmpty) {
      developer.log(
        '[$timestamp] [WebTokenHelper] ✅ Verification: "access_token" key OK (${savedToken1.length} chars)',
        name: 'WebTokenHelper',
      );
    } else {
      developer.log(
        '[$timestamp] [WebTokenHelper] ❌ ERROR: "access_token" key verification FAILED',
        name: 'WebTokenHelper',
        level: 1000,
      );
    }
    
    if (savedToken2 != null && savedToken2.isNotEmpty) {
      developer.log(
        '[$timestamp] [WebTokenHelper] ✅ Verification: "flutter.access_token" key OK (${savedToken2.length} chars)',
        name: 'WebTokenHelper',
      );
    } else {
      developer.log(
        '[$timestamp] [WebTokenHelper] ❌ ERROR: "flutter.access_token" key verification FAILED',
        name: 'WebTokenHelper',
        level: 1000,
      );
    }
  } catch (e) {
    developer.log(
      '❌ [WebTokenHelper] ERROR saving token to localStorage: $e',
      name: 'WebTokenHelper',
      level: 1000,
    );
  }
}
