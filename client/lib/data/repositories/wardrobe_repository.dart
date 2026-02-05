import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/app_database.dart';
import '../remote/wardrobe_remote_ds.dart';
import '../../domain/entities/wardrobe_entity.dart' as domain;
import '../../domain/entities/wardrobe_request_entities.dart';

class WardrobeRepository {
  final AppDatabase _db;
  final WardrobeRemoteDataSource _remote;

  WardrobeRepository(this._db, this._remote);

  // Получить все элементы гардероба
  Stream<List<domain.WardrobeEntry>> watchWardrobe(
      {bool includeArchived = false}) {
    if (includeArchived) {
      return _db.wardrobeDao.watchAll();
    } else {
      // Фильтруем архивные элементы
      return _db.wardrobeDao.watchAll().map((entries) => entries
          .where((entry) => !entry.isArchived)
          .toList());
    }
  }

  // Получить элемент по ID
  Stream<domain.WardrobeEntry?> watchById(String id) {
    return _db.wardrobeDao.watchById(id);
  }

  // Получить элемент по ID (однократно)
  Future<domain.WardrobeEntry?> getById(String id) async {
    return await _db.wardrobeDao.getById(id);
  }

  // Получить все элементы гардероба (однократно)
  Future<List<domain.WardrobeEntry>> getAll({bool includeArchived = false}) async {
    final allItems = await _db.wardrobeDao.getAll();
    if (includeArchived) {
      return allItems;
    } else {
      // Фильтруем архивные элементы
      return allItems.where((entry) => !entry.isArchived).toList();
    }
  }

  // Синхронизировать с сервера
  Future<void> syncFromServer() async {
    try {
      final items = await _remote.fetchAll();
      final wardrobeEntries = <domain.WardrobeEntry>[];
      for (final item in items) {
        // Convert from API model to domain entity
        final entry = domain.WardrobeEntry(
          id: item.id,
          serverId: item.id, // API ID becomes serverId
          name: item.customName ?? item.item.name,
          category: item.item.category,
          subcategory: item.item.subcategory,
          style: item.item.style,
          iconEmoji: item.item.iconEmoji ?? '',
          imageUrl: item.item.imageUrl,
          blurHash: null, // blurHash не доступен в ClothingItem
          minTemp: item.minTemp,
          maxTemp: item.maxTemp,
          warmthLevel: item.warmthLevel,
          rainOk: item.rainOk,
          snowOk: item.snowOk,
          windOk: item.windOk,
          usage: item.notes,
          materials: item.item.materials.isNotEmpty ? item.item.materials.join(',') : null, // Преобразуем List<String> в String
          wearCount: item.wearCount,
          lastWornAt: item.lastWornAt,
          isFavorite: item.isFavorite,
          isArchived: item.isArchived,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
          lastSyncedAt: DateTime.now(),
          dirty: false, // Already synchronized
          season: item.season,
          gender: item.item.gender,
          fit: item.item.fit,
          pattern: item.item.pattern,
          localImagePath: null,
        );
        wardrobeEntries.add(entry);
      }
      await upsertMany(wardrobeEntries);
    } catch (e) {
      // Логируем ошибку синхронизации
      // print('Wardrobe sync error: $e'); // В реальном приложении используйте proper logging
      rethrow;
    }
  }

  // Вставить или обновить несколько элементов
  Future<void> upsertMany(List<domain.WardrobeEntry> items) async {
    await _db.transaction(() async {
      for (final item in items) {
        await _db.wardrobeDao.upsertOne(WardrobeEntriesCompanion(
          id: Value(item.id),
          serverId: Value(item.serverId),
          name: Value(item.name),
          category: Value(item.category),
          subcategory: Value(item.subcategory),
          style: Value(item.style),
          iconEmoji: Value(item.iconEmoji),
          imageUrl: Value(item.imageUrl),
          blurHash: Value(item.blurHash),
          minTemp: Value(item.minTemp),
          maxTemp: Value(item.maxTemp),
          warmthLevel: Value(item.warmthLevel),
          rainOk: Value(item.rainOk),
          snowOk: Value(item.snowOk),
          windOk: Value(item.windOk),
          usage: Value(item.usage),
          materials: Value(item.materials),
          wearCount: Value(item.wearCount),
          lastWornAt: Value(item.lastWornAt),
          isFavorite: Value(item.isFavorite),
          isArchived: Value(item.isArchived),
          createdAt: Value(item.createdAt),
          updatedAt: Value(item.updatedAt),
          lastSyncedAt: Value(item.lastSyncedAt),
          dirty: Value(item.dirty),
          season: Value(item.season),
          gender: Value(item.gender),
          fit: Value(item.fit),
          pattern: Value(item.pattern),
          localImagePath: Value(item.localImagePath),
        ));
      }
    });
  }

  // Переключить избранное
  Future<void> toggleFavorite(domain.WardrobeEntry e) async {
    await _db.wardrobeDao.setFavorite(e.id, !e.isFavorite);
  }

  // Переключить архив
  Future<void> toggleArchived(domain.WardrobeEntry e) async {
    await _db.wardrobeDao.setArchived(e.id, !e.isArchived);
  }

  // Отметить как надетое
  Future<void> markWorn(domain.WardrobeEntry e) async {
    await _db.wardrobeDao.incrementWearCount(e.id);
    // Также обновим дату последнего ношения
    await _db.wardrobeDao.updateLastWorn(e.id, DateTime.now());
  }

  // Предзагрузить изображения
  Future<void> prefetchMissingImages({int limit = 30}) async {
    // В реальном приложении здесь будет логика предзагрузки изображений
  }

  // Создать элемент гардероба
  Future<domain.WardrobeEntry> createItem(
      WardrobeItemCreateRequest request) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final item = domain.WardrobeEntry(
      id: id,
      serverId: null,
      name: request.name,
      category: request.category,
      subcategory: request.subcategory,
      style: request.style,
      iconEmoji: request.iconEmoji,
      imageUrl: request.imageUrl,
      blurHash: request.blurHash,
      minTemp: request.minTemp,
      maxTemp: request.maxTemp,
      warmthLevel: request.warmthLevel,
      rainOk: request.rainOk,
      snowOk: request.snowOk,
      windOk: request.windOk,
      usage: request.usage,
      materials: request.materials,
      wearCount: 0,
      lastWornAt: null,
      isFavorite: false,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
      lastSyncedAt: null,
      dirty: true,
      season: request.season,
      gender: request.gender,
      fit: request.fit,
      pattern: request.pattern,
      localImagePath: null,
    );

    await _db.wardrobeDao.insertOne(WardrobeEntriesCompanion.insert(
      id: item.id,
      name: item.name,
      category: item.category,
      subcategory: item.subcategory,
      style: item.style,
      iconEmoji: item.iconEmoji,
      imageUrl: Value(item.imageUrl),
      blurHash: Value(item.blurHash),
      minTemp: Value(item.minTemp),
      maxTemp: Value(item.maxTemp),
      warmthLevel: Value(item.warmthLevel),
      rainOk: item.rainOk,
      snowOk: item.snowOk,
      windOk: item.windOk,
      usage: Value(item.usage),
      materials: Value(item.materials),
      wearCount: item.wearCount,
      lastWornAt: Value(item.lastWornAt),
      isFavorite: item.isFavorite,
      isArchived: item.isArchived,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      dirty: item.dirty,
      season: Value(item.season),
      gender: Value(item.gender),
      fit: Value(item.fit),
      pattern: Value(item.pattern),
      localImagePath: Value(item.localImagePath),
    ));

    return item;
  }

  // Обновить элемент гардероба
  Future<void> updateItem(String id, WardrobeItemUpdateRequest request) async {
    final now = DateTime.now();
    await _db.wardrobeDao.updateOne(WardrobeEntriesCompanion(
      id: Value(id),
      name: Value(request.name ?? ''),
      category: Value(request.category ?? ''),
      subcategory: Value(request.subcategory ?? ''),
      style: Value(request.style ?? ''),
      iconEmoji: Value(request.iconEmoji ?? ''),
      imageUrl: Value(request.imageUrl),
      blurHash: Value(request.blurHash),
      minTemp: Value(request.minTemp),
      maxTemp: Value(request.maxTemp),
      warmthLevel: Value(request.warmthLevel),
      rainOk: Value(request.rainOk ?? false),
      snowOk: Value(request.snowOk ?? false),
      windOk: Value(request.windOk ?? false),
      usage: Value(request.usage),
      materials: Value(request.materials),
      isFavorite: Value(request.isFavorite ?? false),
      isArchived: Value(request.isArchived ?? false),
      season: Value(request.season),
      gender: Value(request.gender),
      fit: Value(request.fit),
      pattern: Value(request.pattern),
      localImagePath: Value(request.localImagePath),
      updatedAt: Value(now),
      dirty: Value(true),
    ));
  }

  // Удалить элемент гардероба
  Future<void> deleteItem(String id) async {
    await _db.wardrobeDao.deleteById(id);
  }

  // Получить элементы для рекомендаций
  Future<List<domain.WardrobeEntry>> getItemsForRecommendation(
      {String? category, String? season, String? weather}) async {
    // Пока возвращаем все элементы, в будущем можно добавить фильтрацию
    final allItems = await _db.wardrobeDao.getAll();
    return allItems.where((item) {
      // Простая фильтрация по параметрам
      bool matches = true;
      if (category != null && item.category != category) matches = false;
      if (season != null && item.season != season) matches = false;
      if (weather != null) {
        if (weather.contains('rain') && !item.rainOk) matches = false;
        if (weather.contains('snow') && !item.snowOk) matches = false;
        if (weather.contains('wind') && !item.windOk) matches = false;
      }
      return matches && !item.isArchived; // Исключаем архивные элементы
    }).toList();
  }

  // Получить элементы по категории
  Stream<List<domain.WardrobeEntry>> watchByCategory(String category) {
    return _db.wardrobeDao.watchByCategory(category);
  }

  // Получить элементы по категориям
  Future<List<domain.WardrobeEntry>> getByCategories(
      List<String> categories) async {
    return await _db.wardrobeDao.getByCategories(categories);
  }

  // Получить элементы по сезону
  Stream<List<domain.WardrobeEntry>> watchBySeason(String season) {
    return _db.wardrobeDao.watchBySeason(season);
  }

  // Получить элементы по температуре
  Future<List<domain.WardrobeEntry>> getByTemperature(int temperature) async {
    return await _db.wardrobeDao.getByTemperature(temperature);
  }

  // Получить избранные элементы
  Stream<List<domain.WardrobeEntry>> watchFavorites() {
    return _db.wardrobeDao.watchFavorites();
  }

  // Обновить элемент (полное обновление)
  Future<void> updateFullItem(domain.WardrobeEntry item) async {
    final now = DateTime.now();
    await _db.wardrobeDao.updateOne(WardrobeEntriesCompanion(
      id: Value(item.id),
      name: Value(item.name),
      category: Value(item.category),
      subcategory: Value(item.subcategory),
      style: Value(item.style),
      iconEmoji: Value(item.iconEmoji),
      imageUrl: Value(item.imageUrl),
      blurHash: Value(item.blurHash),
      minTemp: Value(item.minTemp),
      maxTemp: Value(item.maxTemp),
      warmthLevel: Value(item.warmthLevel),
      rainOk: Value(item.rainOk),
      snowOk: Value(item.snowOk),
      windOk: Value(item.windOk),
      usage: Value(item.usage),
      materials: Value(item.materials),
      wearCount: Value(item.wearCount),
      lastWornAt: Value(item.lastWornAt),
      isFavorite: Value(item.isFavorite),
      isArchived: Value(item.isArchived),
      season: Value(item.season),
      gender: Value(item.gender),
      fit: Value(item.fit),
      pattern: Value(item.pattern),
      localImagePath: Value(item.localImagePath),
      updatedAt: Value(now),
      dirty: Value(true),
    ));
  }

  // Получить количество элементов
  Future<int> count() async {
    return await _db.wardrobeDao.count();
  }

  // Отметить как синхронизированное
  Future<void> markAsSynced(String id, String serverId) async {
    await _db.wardrobeDao.markAsSynced(id, serverId);
  }

  // Получить несинхронизированные элементы
  Future<List<domain.WardrobeEntry>> getUnsynced() async {
    return await _db.wardrobeDao.getUnsynced();
  }

  // Сбросить счетчик использования
  Future<void> resetWearCount(String id) async {
    await _db.wardrobeDao.resetWearCount(id);
  }

  // Обновить дату последнего ношения
  Future<void> updateLastWorn(String id, DateTime date) async {
    await _db.wardrobeDao.updateLastWorn(id, date);
  }

  // Watch all items (for domain service)
  Stream<List<domain.WardrobeEntry>> watchAll({bool includeArchived = false}) {
    return watchWardrobe(includeArchived: includeArchived);
  }

  // Set favorite status
  Future<void> setFavorite(String id, bool value) async {
    await _db.wardrobeDao.setFavorite(id, value);
  }

  // Set archived status
  Future<void> setArchived(String id, bool value) async {
    await _db.wardrobeDao.setArchived(id, value);
  }

  // Increment wear count
  Future<void> incrementWearCount(String id) async {
    await _db.wardrobeDao.incrementWearCount(id);
  }

  // Insert one item
  Future<void> insertOne(domain.WardrobeEntry item) async {
    await _db.wardrobeDao.insertOne(WardrobeEntriesCompanion.insert(
      id: item.id,
      name: item.name,
      category: item.category,
      subcategory: item.subcategory,
      style: item.style,
      iconEmoji: item.iconEmoji,
      imageUrl: Value(item.imageUrl),
      blurHash: Value(item.blurHash),
      minTemp: Value(item.minTemp),
      maxTemp: Value(item.maxTemp),
      warmthLevel: Value(item.warmthLevel),
      rainOk: item.rainOk,
      snowOk: item.snowOk,
      windOk: item.windOk,
      usage: Value(item.usage),
      materials: Value(item.materials),
      wearCount: item.wearCount,
      lastWornAt: Value(item.lastWornAt),
      isFavorite: item.isFavorite,
      isArchived: item.isArchived,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      dirty: item.dirty,
      season: Value(item.season),
      gender: Value(item.gender),
      fit: Value(item.fit),
      pattern: Value(item.pattern),
      localImagePath: Value(item.localImagePath),
    ));
  }

  // Update one item
  Future<void> updateOne(domain.WardrobeEntry item) async {
    final now = DateTime.now();
    await _db.wardrobeDao.updateOne(WardrobeEntriesCompanion(
      id: Value(item.id),
      name: Value(item.name),
      category: Value(item.category),
      subcategory: Value(item.subcategory),
      style: Value(item.style),
      iconEmoji: Value(item.iconEmoji),
      imageUrl: Value(item.imageUrl),
      blurHash: Value(item.blurHash),
      minTemp: Value(item.minTemp),
      maxTemp: Value(item.maxTemp),
      warmthLevel: Value(item.warmthLevel),
      rainOk: Value(item.rainOk),
      snowOk: Value(item.snowOk),
      windOk: Value(item.windOk),
      usage: Value(item.usage),
      materials: Value(item.materials),
      wearCount: Value(item.wearCount),
      lastWornAt: Value(item.lastWornAt),
      isFavorite: Value(item.isFavorite),
      isArchived: Value(item.isArchived),
      season: Value(item.season),
      gender: Value(item.gender),
      fit: Value(item.fit),
      pattern: Value(item.pattern),
      localImagePath: Value(item.localImagePath),
      updatedAt: Value(now),
      dirty: Value(true),
    ));
  }

  // Delete by ID
  Future<void> deleteById(String id) async {
    await _db.wardrobeDao.deleteById(id);
  }

  // Get items for recommendations
  Future<List<domain.WardrobeEntry>> getForRecommendations(
      {String? category, String? season, String? weather}) async {
    return getItemsForRecommendation(
        category: category, season: season, weather: weather);
  }
}
