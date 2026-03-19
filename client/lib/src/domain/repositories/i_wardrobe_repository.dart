import '../entities/wardrobe_item.dart';

/// Интерфейс репозитория гардероба
abstract class IWardrobeRepository {
  /// Получить все элементы гардероба
  Future<List<WardrobeItem>> getAllWardrobeItems({
    bool includeArchived = false,
  });

  /// Получить поток изменений гардероба
  Stream<List<WardrobeItem>> watchWardrobe({bool includeArchived = false});

  /// Получить элемент по ID
  Future<WardrobeItem?> getWardrobeItemById(String id);

  /// Добавить элемент
  Future<void> addWardrobeItem(WardrobeItem item);

  /// Обновить элемент
  Future<void> updateWardrobeItem(WardrobeItem item);

  /// Удалить элемент
  Future<void> deleteWardrobeItem(String id);

  /// Архивировать элемент
  Future<void> archiveWardrobeItem(String id);

  /// Восстановить элемент из архива
  Future<void> restoreWardrobeItem(String id);

  /// Синхронизировать с сервером
  Future<void> syncFromServer();

  /// Предварительно загрузить отсутствующие изображения
  Future<void> prefetchMissingImages();

  // Методы для синхронизации
  /// Получить несинхронизированные элементы
  Future<List<WardrobeItem>> getUnsynced();

  /// Отметить элемент как синхронизированный
  Future<void> markAsSynced(String id, String serverId);
}
