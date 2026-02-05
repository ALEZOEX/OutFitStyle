import 'dart:convert';

import '../../app/api/api_client.dart';
import '../../models/wardrobe_models.dart' as api_models;

class WardrobeRemoteDataSource {
  final ApiClient _apiClient;

  WardrobeRemoteDataSource(this._apiClient);

  Future<List<api_models.WardrobeItem>> fetchAll() async {
    // тянем постранично, пока есть
    final result = <api_models.WardrobeItem>[];
    var page = 1;
    const limit = 50;

    while (true) {
      final response = await _apiClient.get('/wardrobe', params: {
        'page': page.toString(),
        'limit': limit.toString(),
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = json.decode(response.data);
        final List<dynamic> listJson = decodedJson['items'] as List;
        final List<api_models.WardrobeItem> list = listJson
            .whereType<Map<String, dynamic>>()
            .map((e) => api_models.WardrobeItem.fromJson(e))
            .toList();

        final int total = decodedJson['pagination']['total'] as int;

        result.addAll(list);
        if (result.length >= total) break;
        if (list.isEmpty) break;
        page += 1;
      } else {
        throw Exception('Failed to fetch wardrobe: ${response.statusCode}');
      }
    }

    return result;
  }

  Future<api_models.WardrobeItem> create(
      api_models.WardrobeCreateRequest request) async {
    final response = await _apiClient.post('/wardrobe', data: request.toJson());

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> decodedJson = json.decode(response.data);
      // Handle both direct object response and nested object response
      final Map<String, dynamic> itemData =
          decodedJson.containsKey('wardrobe_item') ? decodedJson['wardrobe_item'] : decodedJson;
      return api_models.WardrobeItem.fromJson(itemData);
    } else {
      throw Exception('Failed to create wardrobe item: ${response.statusCode}');
    }
  }

  Future<api_models.WardrobeItem> update(
      String id, api_models.WardrobeUpdateRequest request) async {
    final response = await _apiClient.put('/wardrobe/$id', data: request.toJson());

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = json.decode(response.data);
      // Handle both direct object response and nested object response
      final Map<String, dynamic> itemData =
          decodedJson.containsKey('wardrobe_item') ? decodedJson['wardrobe_item'] : decodedJson;
      return api_models.WardrobeItem.fromJson(itemData);
    } else {
      throw Exception('Failed to update wardrobe item: ${response.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final response = await _apiClient.delete('/wardrobe/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete wardrobe item: ${response.statusCode}');
    }
  }

  Future<void> setFavorite(String id, bool value) async {
    final response = await _apiClient.post('/wardrobe/$id/favorite',
        data: {'is_favorite': value});

    if (response.statusCode != 200) {
      throw Exception('Failed to update favorite: ${response.statusCode}');
    }
  }

  Future<void> setArchived(String id, bool value) async {
    final response = await _apiClient.post('/wardrobe/$id/archive',
        data: {'is_archived': value});

    if (response.statusCode != 200) {
      throw Exception('Failed to update archived: ${response.statusCode}');
    }
  }

  Future<void> worn(String id) async {
    final response = await _apiClient.post('/wardrobe/$id/worn');

    if (response.statusCode != 200) {
      throw Exception('Failed to update worn count: ${response.statusCode}');
    }
  }

  Future<api_models.WardrobeItem> getById(String id) async {
    final response = await _apiClient.get('/wardrobe/$id');

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = json.decode(response.data);
      // Handle both direct object response and nested object response
      final Map<String, dynamic> itemData =
          decodedJson.containsKey('wardrobe_item') ? decodedJson['wardrobe_item'] : decodedJson;
      return api_models.WardrobeItem.fromJson(itemData);
    } else {
      throw Exception('Failed to get wardrobe item: ${response.statusCode}');
    }
  }
}
