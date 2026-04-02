/// Репозиторий гардероба
abstract class WardrobeRepository {
  const WardrobeRepository();

  /// Получить список вещей
  Future<List<dynamic>> getWardrobeItems(String userId);

  /// Добавить вещь
  Future<bool> addItem(String userId, Map<String, dynamic> item);

  /// Обновить вещь
  Future<bool> updateItem(String userId, String itemId, Map<String, dynamic> data);

  /// Удалить вещь
  Future<bool> deleteItem(String userId, String itemId);
}
