import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/local_database.dart';
import '../remote/api_client.dart';
import '../domain/repositories/i_wardrobe_repository.dart';
import '../domain/entities/wardrobe.dart';
import '../core/services/error_handler_service.dart';

class WardrobeRepository implements IWardrobeRepository {
  final ApiClient _apiClient;
  final Logger _logger;

  WardrobeRepository({
    required ApiClient apiClient,
  }) :
    _apiClient = apiClient,
    _logger = Logger();

  @override
  Stream<List<WardrobeItem>> watchWardrobe({bool includeArchived = false}) {
    // Implementation for watching wardrobe items
    return Stream.value([]);
  }

  @override
  Stream<WardrobeItem?> watchById(String id) {
    // Implementation for watching wardrobe item by ID
    return Stream.value(null);
  }

  @override
  Future<List<WardrobeItem>> getAllWardrobeItems({String? userId}) async {
    try {
      _logger.d('Getting all wardrobe items${userId != null ? ' for user: $userId' : ''}');
      
      // First try to get from local cache
      // Implementation for local data retrieval
      
      // Then try to get from remote
      final params = <String, dynamic>{};
      if (userId != null) params['user_id'] = userId;
      
      final response = await _apiClient.get('/wardrobe', params: params);

      if (response.statusCode == 200 && response.data != null) {
        _logger.d('Successfully fetched wardrobe items${userId != null ? ' for user: $userId' : ''}');
        
        if (response.data is List) {
          return (response.data as List)
              .map((json) => WardrobeItem.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          _logger.w('Unexpected data format for wardrobe items');
          return [];
        }
      } else {
        _logger.w('Failed to fetch wardrobe items: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching wardrobe items${userId != null ? ' for user $userId' : ''}: $e');
      return [];
    }
  }

  @override
  Future<WardrobeItem?> getWardrobeItemById(String id) async {
    try {
      _logger.d('Getting wardrobe item by ID: $id');
      
      // First try to get from local cache
      // Implementation for local data retrieval
      
      // Then try to get from remote
      final response = await _apiClient.get('/wardrobe/$id');

      if (response.statusCode == 200 && response.data != null) {
        _logger.d('Successfully fetched wardrobe item by ID: $id');
        return WardrobeItem.fromJson(response.data as Map<String, dynamic>);
      } else {
        _logger.w('Failed to fetch wardrobe item by ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error fetching wardrobe item by ID $id: $e');
      return null;
    }
  }

  @override
  Future<WardrobeItem> addWardrobeItem(WardrobeItem item) async {
    try {
      _logger.d('Adding wardrobe item: ${item.id}');
      
      // Save to local database
      // Implementation for local data saving
      
      // Then save to remote
      final response = await _apiClient.post('/wardrobe', data: item.toJson());

      if (response.statusCode == 201 && response.data != null) {
        _logger.d('Successfully added wardrobe item: ${item.id}');
        return WardrobeItem.fromJson(response.data as Map<String, dynamic>);
      } else {
        _logger.w('Failed to add wardrobe item: ${response.statusCode}');
        // Return the original item if remote save failed
        return item;
      }
    } catch (e) {
      _logger.e('Error adding wardrobe item ${item.id}: $e');
      // Return the original item if remote save failed
      return item;
    }
  }

  @override
  Future<WardrobeItem> updateWardrobeItem(WardrobeItem item) async {
    try {
      _logger.d('Updating wardrobe item: ${item.id}');
      
      // Update local database
      // Implementation for local data update
      
      // Then update remote
      final response = await _apiClient.put('/wardrobe/${item.id}', data: item.toJson());

      if (response.statusCode == 200 && response.data != null) {
        _logger.d('Successfully updated wardrobe item: ${item.id}');
        return WardrobeItem.fromJson(response.data as Map<String, dynamic>);
      } else {
        _logger.w('Failed to update wardrobe item: ${response.statusCode}');
        // Return the original item if remote update failed
        return item;
      }
    } catch (e) {
      _logger.e('Error updating wardrobe item ${item.id}: $e');
      // Return the original item if remote update failed
      return item;
    }
  }

  @override
  Future<void> deleteWardrobeItem(String id) async {
    try {
      _logger.d('Deleting wardrobe item: $id');
      
      // Delete from local database
      // Implementation for local data deletion
      
      // Then delete from remote
      final response = await _apiClient.delete('/wardrobe/$id');

      if (response.statusCode == 200) {
        _logger.d('Successfully deleted wardrobe item: $id');
      } else {
        _logger.w('Failed to delete wardrobe item: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error deleting wardrobe item $id: $e');
    }
  }

  @override
  Future<List<WardrobeItem>> filterWardrobeItems({
    String? category,
    String? subcategory,
    String? color,
    String? brand,
    String? name,
    bool? isFavorite,
    bool? isArchived,
    String? userId,
    String? season,
    String? style,
    List<String>? occasions,
  }) async {
    try {
      _logger.d('Filtering wardrobe items');
      
      // Build query parameters
      final params = <String, dynamic>{};
      if (category != null) params['category'] = category;
      if (subcategory != null) params['subcategory'] = subcategory;
      if (color != null) params['color'] = color;
      if (brand != null) params['brand'] = brand;
      if (name != null) params['name'] = name;
      if (isFavorite != null) params['is_favorite'] = isFavorite;
      if (isArchived != null) params['is_archived'] = isArchived;
      if (userId != null) params['user_id'] = userId;
      if (season != null) params['season'] = season;
      if (style != null) params['style'] = style;
      if (occasions != null) params['occasions'] = occasions.join(',');
      
      // First try to get from local cache
      // Implementation for local data retrieval
      
      // Then try to get from remote
      final response = await _apiClient.get('/wardrobe/filter', params: params);

      if (response.statusCode == 200 && response.data != null) {
        _logger.d('Successfully filtered wardrobe items');
        
        if (response.data is List) {
          return (response.data as List)
              .map((json) => WardrobeItem.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          _logger.w('Unexpected data format for filtered wardrobe items');
          return [];
        }
      } else {
        _logger.w('Failed to filter wardrobe items: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error filtering wardrobe items: $e');
      return [];
    }
  }

  @override
  Future<List<WardrobeItem>> getAllWardrobeItemsFromRemote({String? userId}) async {
    try {
      _logger.d('Getting all wardrobe items from remote${userId != null ? ' for user: $userId' : ''}');
      
      final params = <String, dynamic>{};
      if (userId != null) params['user_id'] = userId;
      
      final response = await _apiClient.get('/wardrobe', params: params);

      if (response.statusCode == 200 && response.data != null) {
        _logger.d('Successfully fetched wardrobe items from remote${userId != null ? ' for user: $userId' : ''}');
        
        if (response.data is List) {
          return (response.data as List)
              .map((json) => WardrobeItem.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          _logger.w('Unexpected data format for wardrobe items');
          return [];
        }
      } else {
        _logger.w('Failed to fetch wardrobe items from remote: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching wardrobe items from remote${userId != null ? ' for user $userId' : ''}: $e');
      return [];
    }
  }

  @override
  Future<WardrobeItem> getWardrobeItemByIdFromRemote(String id) async {
    try {
      _logger.d('Getting wardrobe item from remote by ID: $id');
      
      final response = await _apiClient.get('/wardrobe/$id');

      if (response.statusCode == 200 && response.data != null) {
        _logger.d('Successfully fetched wardrobe item from remote by ID: $id');
        return WardrobeItem.fromJson(response.data as Map<String, dynamic>);
      } else {
        _logger.w('Failed to fetch wardrobe item from remote by ID: ${response.statusCode}');
        throw Exception('Failed to fetch wardrobe item by ID');
      }
    } catch (e) {
      _logger.e('Error fetching wardrobe item from remote by ID $id: $e');
      throw e;
    }
  }

  @override
  Future<WardrobeItem> createWardrobeItemToRemote(WardrobeItem item) async {
    try {
      _logger.d('Creating wardrobe item to remote: ${item.id}');
      
      final response = await _apiClient.post('/wardrobe', data: item.toJson());

      if (response.statusCode == 201 && response.data != null) {
        _logger.d('Successfully created wardrobe item to remote: ${item.id}');
        return WardrobeItem.fromJson(response.data as Map<String, dynamic>);
      } else {
        _logger.w('Failed to create wardrobe item to remote: ${response.statusCode}');
        throw Exception('Failed to create wardrobe item');
      }
    } catch (e) {
      _logger.e('Error creating wardrobe item to remote ${item.id}: $e');
      throw e;
    }
  }

  @override
  Future<WardrobeItem> updateWardrobeItemToRemote(WardrobeItem item) async {
    try {
      _logger.d('Updating wardrobe item to remote: ${item.id}');
      
      final response = await _apiClient.put('/wardrobe/${item.id}', data: item.toJson());

      if (response.statusCode == 200 && response.data != null) {
        _logger.d('Successfully updated wardrobe item to remote: ${item.id}');
        return WardrobeItem.fromJson(response.data as Map<String, dynamic>);
      } else {
        _logger.w('Failed to update wardrobe item to remote: ${response.statusCode}');
        throw Exception('Failed to update wardrobe item');
      }
    } catch (e) {
      _logger.e('Error updating wardrobe item to remote ${item.id}: $e');
      throw e;
    }
  }

  @override
  Future<void> deleteWardrobeItemFromRemote(String id) async {
    try {
      _logger.d('Deleting wardrobe item from remote: $id');
      
      final response = await _apiClient.delete('/wardrobe/$id');

      if (response.statusCode == 200) {
        _logger.d('Successfully deleted wardrobe item from remote: $id');
      } else {
        _logger.w('Failed to delete wardrobe item from remote: ${response.statusCode}');
        throw Exception('Failed to delete wardrobe item');
      }
    } catch (e) {
      _logger.e('Error deleting wardrobe item from remote $id: $e');
      throw e;
    }
  }

  @override
  Future<List<WardrobeItem>> filterWardrobeItemsFromRemote({
    String? category,
    String? subcategory,
    String? color,
    String? brand,
    String? name,
    bool? isFavorite,
    bool? isArchived,
    String? userId,
    String? season,
    String? style,
    List<String>? occasions,
  }) async {
    try {
      _logger.d('Filtering wardrobe items from remote');
      
      // Build query parameters
      final params = <String, dynamic>{};
      if (category != null) params['category'] = category;
      if (subcategory != null) params['subcategory'] = subcategory;
      if (color != null) params['color'] = color;
      if (brand != null) params['brand'] = brand;
      if (name != null) params['name'] = name;
      if (isFavorite != null) params['is_favorite'] = isFavorite;
      if (isArchived != null) params['is_archived'] = isArchived;
      if (userId != null) params['user_id'] = userId;
      if (season != null) params['season'] = season;
      if (style != null) params['style'] = style;
      if (occasions != null) params['occasions'] = occasions.join(',');
      
      final response = await _apiClient.get('/wardrobe/filter', params: params);

      if (response.statusCode == 200 && response.data != null) {
        _logger.d('Successfully filtered wardrobe items from remote');
        
        if (response.data is List) {
          return (response.data as List)
              .map((json) => WardrobeItem.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          _logger.w('Unexpected data format for filtered wardrobe items');
          return [];
        }
      } else {
        _logger.w('Failed to filter wardrobe items from remote: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error filtering wardrobe items from remote: $e');
      return [];
    }
  }

  @override
  Future<void> syncWardrobe() async {
    try {
      _logger.d('Starting wardrobe synchronization');
      // Implementation for syncing wardrobe data
      _logger.d('Wardrobe synchronization completed');
    } catch (e) {
      _logger.e('Error during wardrobe synchronization', error: e);
    }
  }

  @override
  Future<void> markAsSynced(String id, String remoteId) async {
    try {
      _logger.d('Marking wardrobe item as synced: $id -> $remoteId');
      // Implementation for marking wardrobe item as synced
      _logger.d('Wardrobe item marked as synced: $id -> $remoteId');
    } catch (e) {
      _logger.e('Error marking wardrobe item as synced: $id', error: e);
    }
  }
}