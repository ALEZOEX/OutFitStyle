/// Сервис гардероба
class WardrobeDomainService {
  /// Валидировать вещь
  bool validateItem(Map<String, dynamic> item) {
    return item.containsKey('name') && item.containsKey('category');
  }

  /// Получить категорию вещи
  String? getCategory(Map<String, dynamic> item) {
    return item['category'] as String?;
  }
}
