import 'auth_storage.dart';

class GeoService {
  final String baseUrl;
  final AuthStorage authStorage;

  GeoService({
    required this.baseUrl,
    required this.authStorage,
  });

  // TODO: Implement geo service
  // This service will handle geolocation-related operations
  // For now, we'll provide a basic structure

  Future<List<Map<String, dynamic>>> autocomplete(String q) async {
    // TODO: Implement actual autocomplete using the backend API
    // For now returning an empty list
    return [];
  }
}