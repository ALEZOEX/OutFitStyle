import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../local/app_database.dart';
import '../remote/wardrobe_remote_ds.dart';
import '../image_store.dart';
import '../../domain/entities/wardrobe_entity.dart';

class WardrobeRepository {
  final AppDatabase _db;
  final WardrobeRemoteDataSource _remote;
  final ImageStore _imageStore;

  WardrobeRepository(this._db, this._remote, this._imageStore);

  // Получить все элементы гардероба
  Stream<List<WardrobeEntry>> watchWardrobe({bool includeArchived = false}) {
    // Пока DAO не поддерживает фильтрацию по архиву, возвращаем все
    return _db.wardrobeDao.watchAll();
  }

  // Получить элемент по ID
  Stream<WardrobeEntry?> watchById(String id) {
    return _db.wardrobeDao.watchById(id);
  }

  // Получить элемент по ID (однократно)
  Future<WardrobeEntry?> getById(String id) async {
    return await _db.wardrobeDao.getById(id);
  }

  // Синхронизировать с сервера
  Future<void> syncFromServer() async {
    try {
      final items = await _remote.fetchAll();
      await upsertMany(items);
    } catch (e) {
      // Логируем ошибку синхронизации
      // print('Wardrobe sync error: $e'); // В реальном приложении используйте proper logging
      rethrow;
    }
  }

  // Вставить или обновить несколько элементов
  Future<void> upsertMany(List<WardrobeEntry> items) async {
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
  Future<void> toggleFavorite(WardrobeEntry e) async {
    await _db.wardrobeDao.setFavorite(e.id, !e.isFavorite);
  }

  // Переключить архив
  Future<void> toggleArchived(WardrobeEntry e) async {
    await _db.wardrobeDao.setArchived(e.id, !e.isArchived);
  }

  // Отметить как надетое
  Future<void> markWorn(WardrobeEntry e) async {
    await _db.wardrobeDao.incrementWearCount(e.id);
  }

  // Предзагрузить изображения
  Future<void> prefetchMissingImages({int limit = 30}) async {
    // В реальном приложении здесь будет логика предзагрузки изображений
  }

  // Создать элемент гардероба
  Future<WardrobeEntry> createItem(WardrobeItemCreateRequest request) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final item = WardrobeEntry(
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

    await _db.wardrobeDao.insertOne(WardrobeEntriesCompanion(
      id: Value(item.id),
      serverId: const Value.absent(),
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
      lastSyncedAt: const Value.absent(),
      dirty: Value(item.dirty),
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
      name: Value(request.name),
      category: Value(request.category),
      subcategory: Value(request.subcategory),
      style: Value(request.style),
      iconEmoji: Value(request.iconEmoji),
      updatedAt: Value(now),
      dirty: Value(true),
    ));
  }

  // Удалить элемент гардероба
  Future<void> deleteItem(String id) async {
    await _db.wardrobeDao.deleteById(id);
  }

  // Получить элементы для рекомендаций
  Future<List<WardrobeEntry>> getItemsForRecommendation({String? category, String? season, String? weather}) async {
    // Пока возвращаем все элементы, в будущем можно добавить фильтрацию
    final allItems = await _db.wardrobeDao.watchAll().first;
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
  Stream<List<WardrobeEntry>> watchByCategory(String category) {
    return _db.wardrobeDao.watchByCategory(category);
  }
}

// Вспомогательные классы для запросов
class WardrobeItemCreateRequest {
  final String name;
  final String category;
  final String subcategory;
  final String style;
  final String iconEmoji;
  final String? imageUrl;
  final String? blurHash;
  final int? minTemp;
  final int? maxTemp;
  final int? warmthLevel;
  final bool rainOk;
  final bool snowOk;
  final bool windOk;
  final String? usage;
  final String? materials;
  final String? season;
  final String? gender;
  final String? fit;
  final String? pattern;

  WardrobeItemCreateRequest({
    required this.name,
    required this.category,
    required this.subcategory,
    required this.style,
    required this.iconEmoji,
    this.imageUrl,
    this.blurHash,
    this.minTemp,
    this.maxTemp,
    this.warmthLevel,
    this.rainOk = false,
    this.snowOk = false,
    this.windOk = false,
    this.usage,
    this.materials,
    this.season,
    this.gender,
    this.fit,
    this.pattern,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'subcategory': subcategory,
        'style': style,
        'icon_emoji': iconEmoji,
        'image_url': imageUrl,
        'blur_hash': blurHash,
        'min_temp': minTemp,
        'max_temp': maxTemp,
        'warmth_level': warmthLevel,
        'rain_ok': rainOk,
        'snow_ok': snowOk,
        'wind_ok': windOk,
        'usage': usage,
        'materials': materials,
        'season': season,
        'gender': gender,
        'fit': fit,
        'pattern': pattern,
      };
}

class WardrobeItemUpdateRequest {
  final String name;
  final String category;
  final String subcategory;
  final String style;
  final String iconEmoji;

  WardrobeItemUpdateRequest({
    required this.name,
    required this.category,
    required this.subcategory,
    required this.style,
    required this.iconEmoji,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'subcategory': subcategory,
        'style': style,
        'icon_emoji': iconEmoji,
      };
}