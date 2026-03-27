// Web-specific token storage utilities
// Only available when compiling for web
import 'package:web/web.dart' as web;
import 'dart:developer' as developer;

/// Получение access_token из localStorage (только для Web)
/// SharedPreferences на Web может быть не инициализирован вовремя
/// 
/// Порядок чтения (приоритет):
/// 1. 'access_token' - основной ключ (используется SessionManager)
/// 2. 'flutter.access_token' - ключ SharedPreferences на Web
String? getAccessTokenFromLocalStorage() {
  try {
    final timestamp = DateTime.now().toIso8601String();
    
    // Приоритет 1: основной ключ 'access_token'
    final token1 = web.window.localStorage.getItem('access_token');
    if (token1 != null && token1.isNotEmpty) {
      developer.log(
        '[$timestamp] [WebTokenStorage] ✅ Token read from localStorage with key "access_token" (${token1.length} chars)',
        name: 'WebTokenStorage',
      );
      return token1;
    }
    
    // Приоритет 2: ключ 'flutter.access_token' (SharedPreferences на Web)
    final token2 = web.window.localStorage.getItem('flutter.access_token');
    if (token2 != null && token2.isNotEmpty) {
      developer.log(
        '[$timestamp] [WebTokenStorage] ✅ Token read from localStorage with key "flutter.access_token" (${token2.length} chars)',
        name: 'WebTokenStorage',
      );
      return token2;
    }
    
    // Токен не найден
    developer.log(
      '[$timestamp] [WebTokenStorage] ⚠️ No token found in localStorage (checked both keys)',
      name: 'WebTokenStorage',
    );
    return null;
  } catch (e) {
    developer.log(
      '❌ [$timestamp] [WebTokenStorage] ERROR reading token from localStorage: $e',
      name: 'WebTokenStorage',
      level: 1000,
    );
    return null;
  }
}
