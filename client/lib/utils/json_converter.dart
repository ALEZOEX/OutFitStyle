// Вспомогательные методы для безопасной конвертации типов JSON
class JsonConverter {
  static int? toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Попробуем конвертировать строку в число
      try {
        return int.tryParse(value);
      } catch (e) {
        return null;
      }
    }
    // Если все остальное не сработало, возвращаем null
    return null;
  }

  static double? toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Попробуем конвертировать строку в число
      try {
        return double.tryParse(value);
      } catch (e) {
        return null;
      }
    }
    // Если все остальное не сработало, возвращаем null
    return null;
  }
}