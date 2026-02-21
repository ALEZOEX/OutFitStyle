import '../../../../core/api/api_client.dart';
import '../models/trip_dto.dart';

/// Удалённый источник данных для работы с поездками
class TripRemoteDataSource {
  final ApiClient _apiClient;

  TripRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Получить список всех поездок
  Future<List<TripDto>> getTrips() async {
    final response = await _apiClient.get('/api/v1/trips');
    final data = response.data as Map<String, dynamic>;
    final tripsJson = data['trips'] as List<dynamic>;
    return tripsJson.map((json) => TripDto.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Получить поездку по ID
  Future<TripDto> getTripById(String id) async {
    final response = await _apiClient.get('/api/v1/trips/$id');
    final data = response.data as Map<String, dynamic>;
    return TripDto.fromJson(data);
  }

  /// Создать новую поездку
  Future<TripDto> createTrip(Map<String, dynamic> requestData) async {
    final response = await _apiClient.post('/api/v1/trips', data: requestData);
    final data = response.data as Map<String, dynamic>;
    return TripDto.fromJson(data['trip'] as Map<String, dynamic>);
  }

  /// Обновить поездку
  Future<TripDto> updateTrip(String id, Map<String, dynamic> requestData) async {
    final response = await _apiClient.put('/api/v1/trips/$id', data: requestData);
    final data = response.data as Map<String, dynamic>;
    return TripDto.fromJson(data['trip'] as Map<String, dynamic>);
  }

  /// Удалить поездку
  Future<void> deleteTrip(String id) async {
    await _apiClient.delete('/api/v1/trips/$id');
  }

  /// Добавить вещь в список вещей поездки
  Future<TripDto> addPackingItem(String tripId, String wardrobeItemId) async {
    final response = await _apiClient.post(
      '/api/v1/trips/$tripId/packing-list',
      data: {'wardrobe_item_id': wardrobeItemId},
    );
    final data = response.data as Map<String, dynamic>;
    return TripDto.fromJson(data['trip'] as Map<String, dynamic>);
  }

  /// Удалить вещь из списка вещей поездки
  Future<TripDto> removePackingItem(String tripId, String itemId) async {
    final response = await _apiClient.delete(
      '/api/v1/trips/$tripId/packing-list/$itemId',
    );
    final data = response.data as Map<String, dynamic>;
    return TripDto.fromJson(data['trip'] as Map<String, dynamic>);
  }

  /// Отметить вещь как собранную/разобранную
  Future<TripDto> togglePackingItem(
    String tripId,
    String itemId,
    bool isPacked,
  ) async {
    final response = await _apiClient.put(
      '/api/v1/trips/$tripId/packing-list/$itemId',
      data: {'is_packed': isPacked},
    );
    final data = response.data as Map<String, dynamic>;
    return TripDto.fromJson(data['trip'] as Map<String, dynamic>);
  }

  /// Обновить погоду для поездки
  Future<TripDto> refreshWeather(String tripId) async {
    final response = await _apiClient.post(
      '/api/v1/trips/$tripId/weather/refresh',
    );
    final data = response.data as Map<String, dynamic>;
    return TripDto.fromJson(data['trip'] as Map<String, dynamic>);
  }
}
