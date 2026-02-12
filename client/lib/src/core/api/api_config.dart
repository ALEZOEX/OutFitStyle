class ApiConfig {
  static const String baseUrl = 'https://api.outfitstyle.com';
  static const String apiBase = baseUrl; // Добавляем недостающее свойство
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}