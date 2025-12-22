import 'api_service.dart';
import 'auth_storage.dart';

class CatalogService {
  final ApiService _api;
  CatalogService({required String baseUrl, required AuthStorage authStorage}) 
      : _api = ApiService(baseUrl: baseUrl, authStorage: authStorage);

  Future<List<Map<String, dynamic>>> search({String? query, String? category}) async {
    final q = <String, String>{
      if (query != null && query.isNotEmpty) 'q': query,
      if (category != null) 'category': category,
      'limit': '50',
    };
    final data = await _api.getJson('/catalog/search', query: q) as Map<String, dynamic>;
    return (data['items'] as List).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }
}