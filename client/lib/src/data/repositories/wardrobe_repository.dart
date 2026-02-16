import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';

import '../../data/remote/api_client.dart';
import '../../domain/entities/wardrobe_item.dart';
import '../../domain/repositories/i_wardrobe_repository.dart';
import '../db/mappers.dart';
import '../db/wardrobe_database.dart';

/// Репозиторий гардероба с поддержкой offline-first
class WardrobeRepository implements IWardrobeRepository {
  final ApiClient apiClient;
  final WardrobeDatabase database;
  final Logger _logger;

  WardrobeRepository({
    required this.apiClient,
    required this.database,
    Logger? logger,
  }) : _logger = logger ?? Logger();

  @override
  Future<List<WardrobeItem>> getAllWardrobeItems({
    bool includeArchived = false,
  }) async {
    try {
      // Сначала пробуем получить из локальной БД
      final localItems = await database.getAllClothingItems(
        includeArchived: includeArchived,
      );
      
      if (localItems.isNotEmpty) {
        return localItems.map(WardrobeItemMapper.toEntity).toList();
      }

      // Если локальная БД пуста, загружаем с сервера
      await syncFromServer();
      final refreshedItems = await database.getAllClothingItems(
        includeArchived: includeArchived,
      );
      return refreshedItems.map(WardrobeItemMapper.toEntity).toList();
    } catch (e, st) {
      _logger.e('Ошибка получения элементов гардероба', error: e, stackTrace: st);
      // Возвращаем пустой список при ошибке
      return [];
    }
  }

  @override
  Stream<List<WardrobeItem>> watchWardrobe({bool includeArchived = false}) {
    return database
        .watchAllClothingItems(includeArchived: includeArchived)
        .map((items) => items.map(WardrobeItemMapper.toEntity).toList());
  }

  @override
  Future<WardrobeItem?> getWardrobeItemById(String id) async {
    try {
      // Пробуем найти по serverId
      var dbItem = await database.getClothingItemByServerId(id);
      if (dbItem != null) {
        return WardrobeItemMapper.toEntity(dbItem);
      }

      // Пробуем найти по internal id
      final internalId = int.tryParse(id);
      if (internalId != null) {
        dbItem = await database.getClothingItemById(internalId);
        if (dbItem != null) {
          return WardrobeItemMapper.toEntity(dbItem);
        }
      }

      // Если не найдено локально, пробуем загрузить с сервера
      try {
        final response = await apiClient.get('/wardrobe/$id');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final item = WardrobeItem.fromJson(data);
          await _saveLocal(item);
          return item;
        }
      } catch (_) {
        // Игнорируем ошибку сервера
      }

      return null;
    } catch (e, st) {
      _logger.e('Ошибка получения элемента по ID', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<void> addWardrobeItem(WardrobeItem item) async {
    try {
      final companion = WardrobeItemMapper.toCompanionForInsert(item);
      await database.insertClothingItem(companion);

      // Отправляем на сервер асинхронно
      _syncToServer(item).catchError((e) {
        _logger.w('Ошибка синхронизации с сервером', error: e);
      });
    } catch (e, st) {
      _logger.e('Ошибка добавления элемента', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateWardrobeItem(WardrobeItem item) async {
    try {
      final id = item.id ?? item.serverId;
      if (id == null) {
        throw const WardrobeException('ID элемента не указан');
      }

      // Находим локальный элемент
      DbClothingItem? localItem;
      final internalId = int.tryParse(id);
      if (internalId != null) {
        localItem = await database.getClothingItemById(internalId);
      }
      
      if (localItem == null && item.serverId != null) {
        localItem = await database.getClothingItemByServerId(item.serverId!);
      }

      if (localItem == null) {
        // Если элемента нет локально, добавляем
        await addWardrobeItem(item);
        return;
      }

      // Обновляем локально
      final companion = WardrobeItemMapper.toCompanionForUpdate(
        item.copyWith(dirty: true),
      );
      await database.updateClothingItemById(localItem.id, companion);

      // Отправляем на сервер асинхронно
      _syncToServer(item).catchError((e) {
        _logger.w('Ошибка синхронизации с сервером', error: e);
      });
    } catch (e, st) {
      _logger.e('Ошибка обновления элемента', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteWardrobeItem(String id) async {
    try {
      // Находим локальный элемент
      DbClothingItem? localItem;
      final internalId = int.tryParse(id);
      if (internalId != null) {
        localItem = await database.getClothingItemById(internalId);
      }

      localItem ??= await database.getClothingItemByServerId(id);

      if (localItem != null) {
        await database.deleteClothingItem(localItem.id);
      }

      // Удаляем с сервера
      try {
        final serverId = localItem?.serverId ?? id;
        await apiClient.delete('/wardrobe/$serverId');
      } catch (_) {
        // Игнорируем ошибку сервера
      }
    } catch (e, st) {
      _logger.e('Ошибка удаления элемента', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> archiveWardrobeItem(String id) async {
    try {
      final item = await getWardrobeItemById(id);
      if (item != null) {
        await updateWardrobeItem(item.copyWith(isArchived: true));
      }
    } catch (e, st) {
      _logger.e('Ошибка архивирования элемента', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> restoreWardrobeItem(String id) async {
    try {
      final item = await getWardrobeItemById(id);
      if (item != null) {
        await updateWardrobeItem(item.copyWith(isArchived: false));
      }
    } catch (e, st) {
      _logger.e('Ошибка восстановления элемента', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> syncFromServer() async {
    try {
      final params = <String, dynamic>{'include_archived': 'true'};
      final response = await apiClient.get('/wardrobe', params: params);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? data as List<dynamic>;
        
        await database.batch((batch) async {
          for (final itemJson in items) {
            final item = WardrobeItem.fromJson(itemJson as Map<String, dynamic>);
            final companion = WardrobeItemMapper.toCompanionForInsert(
              item.copyWith(dirty: false, lastSyncedAt: DateTime.now()),
            );
            
            // Проверяем, существует ли уже элемент
            final existing = item.serverId != null
                ? await database.getClothingItemByServerId(item.serverId!)
                : null;
            
            if (existing != null) {
              final updateCompanion = companion.copyWith(
                updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
              );
              // Обновляем существующий элемент
              await database.updateClothingItemById(existing.id, updateCompanion);
            } else {
              batch.insert(database.clothingItems, companion);
            }
          }
        });

        _logger.i('Синхронизация с сервером завершена: ${items.length} элементов');
      }
    } catch (e, st) {
      _logger.e('Ошибка синхронизации с сервером', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> prefetchMissingImages() async {
    // Предзагрузка отсутствующих изображений
    // Реализуется через flutter_cache_manager
    _logger.d('Предзагрузка изображений...');
  }

  @override
  Future<List<WardrobeItem>> getUnsynced() async {
    try {
      final unsynced = await database.getUnsyncedClothingItems();
      return unsynced.map(WardrobeItemMapper.toEntity).toList();
    } catch (e, st) {
      _logger.e('Ошибка получения несинхронизированных элементов', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<void> markAsSynced(String id, String serverId) async {
    try {
      final internalId = int.tryParse(id);
      if (internalId != null) {
        await database.markClothingItemAsSynced(internalId, serverId);
      } else {
        final item = await database.getClothingItemByServerId(id);
        if (item != null) {
          await database.markClothingItemAsSynced(item.id, serverId);
        }
      }
    } catch (e, st) {
      _logger.e('Ошибка отметки элемента как синхронизированного', error: e, stackTrace: st);
    }
  }

  // ==================== Private Methods ====================

  /// Сохранить элемент локально
  Future<void> _saveLocal(WardrobeItem item) async {
    final existing = item.serverId != null
        ? await database.getClothingItemByServerId(item.serverId!)
        : null;
    
    if (existing != null) {
      final companion = WardrobeItemMapper.toCompanionForUpdate(
        item.copyWith(dirty: false, lastSyncedAt: DateTime.now()),
      );
      await database.updateClothingItemById(existing.id, companion);
    } else {
      final companion = WardrobeItemMapper.toCompanionForInsert(
        item.copyWith(dirty: false, lastSyncedAt: DateTime.now()),
      );
      await database.insertClothingItem(companion);
    }
  }

  /// Синхронизировать элемент с сервером
  Future<void> _syncToServer(WardrobeItem item) async {
    try {
      if (item.serverId != null) {
        // Обновление существующего
        await apiClient.put(
          '/wardrobe/${item.serverId}',
          body: item.toJson(),
        );
        await markAsSynced(item.id ?? item.serverId!, item.serverId!);
      } else {
        // Создание нового
        final response = await apiClient.post(
          '/wardrobe',
          body: item.toJson(),
        );
        
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final serverId = data['id'] as String? ?? data['server_id'] as String?;
          if (serverId != null) {
            await markAsSynced(item.id ?? '', serverId);
          }
        }
      }
    } catch (e) {
      _logger.w('Ошибка синхронизации элемента с сервером', error: e);
      // Помечаем как dirty для последующей синхронизации
      final internalId = int.tryParse(item.id ?? '');
      if (internalId != null) {
        await database.markClothingItemAsDirty(internalId);
      }
    }
  }
}

/// Исключение репозитория гардероба
class WardrobeException implements Exception {
  final String message;
  const WardrobeException(this.message);

  @override
  String toString() => 'WardrobeException: $message';
}
