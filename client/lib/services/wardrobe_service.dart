import '../models/wardrobe_models.dart';
import 'api_service.dart';
import 'auth_storage.dart';

class WardrobeService {
  final ApiService _api;

  WardrobeService({
    required String baseUrl,
    required AuthStorage authStorage,
  }) : _api = ApiService(baseUrl: baseUrl, authStorage: authStorage);

  Future<(List<WardrobeItem>, int total)> list({
    int page = 1,
    int limit = 20,
    String? category,
    String? style,
    String? season,
    bool? isFavorite,
    bool? isArchived,
    String? search,
    String? sort,
    String? order,
  }) async {
    final q = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (category != null) 'category': category,
      if (style != null) 'style': style,
      if (season != null) 'season': season,
      if (isFavorite != null) 'is_favorite': isFavorite.toString(),
      if (isArchived != null) 'is_archived': isArchived.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
      if (order != null && order.isNotEmpty) 'order': order,
    };

    final data = await _api.getJson('/wardrobe', query: q) as Map<String, dynamic>;
    final itemsJson = (data['items'] as List).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    final items = itemsJson.map(WardrobeItem.fromJson).toList();

    final pagination = (data['pagination'] as Map?)?.cast<String, dynamic>() ?? {};
    final total = (pagination['total'] ?? items.length) as int;

    return (items, total);
  }

  Future<WardrobeItem> createManual({
    required String name,
    required String category,
    required String subcategory,
    required String style,
    String? baseColour,
    String? customName,
    String? notes,
    List<String>? tags,
  }) async {
    final data = await _api.postJson('/wardrobe', body: {
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'style': style,
      if (baseColour != null) 'base_colour': baseColour,
      if (customName != null) 'custom_name': customName,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
    }) as Map<String, dynamic>;

    final wi = (data['wardrobe_item'] as Map).cast<String, dynamic>();
    return WardrobeItem.fromJson(wi);
  }

  Future<void> setFavorite(String wardrobeId, bool isFavorite) async {
    await _api.postJson('/wardrobe/$wardrobeId/favorite', body: {'is_favorite': isFavorite});
  }

  Future<void> setArchived(String wardrobeId, bool isArchived) async {
    await _api.postJson('/wardrobe/$wardrobeId/archive', body: {'is_archived': isArchived});
  }

  Future<void> worn(String wardrobeId) async {
    await _api.postJson('/wardrobe/$wardrobeId/worn');
  }

  Future<void> delete(String wardrobeId) async {
    await _api.deleteJson('/wardrobe/$wardrobeId');
  }
}