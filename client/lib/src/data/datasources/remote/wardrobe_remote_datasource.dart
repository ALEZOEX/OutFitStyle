import 'dart:convert';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import '../../../domain/entities/wardrobe_item.dart';

abstract class IWardrobeRemoteDataSource {
  Future<List<WardrobeItem>> getAllWardrobeItems(String userId);
  Future<WardrobeItem?> getWardrobeItemById(String id);
  Future<void> addWardrobeItem(WardrobeItem item);
  Future<void> updateWardrobeItem(WardrobeItem item);
  Future<void> deleteWardrobeItem(String id);
  Future<void> archiveWardrobeItem(String id);
  Future<void> restoreWardrobeItem(String id);
}

class WardrobeRemoteDataSource implements IWardrobeRemoteDataSource {
  final ApiClient _apiClient;

  WardrobeRemoteDataSource(this._apiClient);

  @override
  Future<List<WardrobeItem>> getAllWardrobeItems(String userId) async {
    final response = await _apiClient.get(
      '/wardrobe',
      params: {'user_id': userId},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map((item) => WardrobeItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw WardrobeRemoteException('Не удалось загрузить элементы гардероба');
  }

  @override
  Future<WardrobeItem?> getWardrobeItemById(String id) async {
    final response = await _apiClient.get('/wardrobe/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      return WardrobeItem.fromJson(data);
    }
    return null;
  }

  @override
  Future<void> addWardrobeItem(WardrobeItem item) async {
    final response = await _apiClient.post(
      '/wardrobe',
      data: item.toJson(),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw WardrobeRemoteException('Не удалось добавить элемент гардероба');
    }
  }

  @override
  Future<void> updateWardrobeItem(WardrobeItem item) async {
    final id = item.id ?? item.serverId;
    if (id == null) {
      throw WardrobeRemoteException('ID элемента не указан');
    }
    final response = await _apiClient.put(
      '/wardrobe/$id',
      data: item.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw WardrobeRemoteException('Не удалось обновить элемент гардероба');
    }
  }

  @override
  Future<void> deleteWardrobeItem(String id) async {
    final response = await _apiClient.delete('/wardrobe/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw WardrobeRemoteException('Не удалось удалить элемент гардероба');
    }
  }

  @override
  Future<void> archiveWardrobeItem(String id) async {
    final response = await _apiClient.post('/wardrobe/$id/archive');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw WardrobeRemoteException('Не удалось архивировать элемент');
    }
  }

  @override
  Future<void> restoreWardrobeItem(String id) async {
    final response = await _apiClient.post('/wardrobe/$id/restore');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw WardrobeRemoteException('Не удалось восстановить элемент из архива');
    }
  }
}

/// Исключение remote datasource гардероба
class WardrobeRemoteException implements Exception {
  final String message;
  const WardrobeRemoteException(this.message);

  @override
  String toString() => 'WardrobeRemoteException: $message';
}