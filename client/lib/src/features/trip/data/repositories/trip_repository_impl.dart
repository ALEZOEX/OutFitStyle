import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';
import '../models/trip_dto.dart';

/// Реализация репозитория поездок
class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _remoteDataSource;

  TripRepositoryImpl({required TripRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Trip>> getTrips() async {
    final dtos = await _remoteDataSource.getTrips();
    return dtos.map(_mapToEntity).toList();
  }

  @override
  Future<Trip?> getTripById(String id) async {
    try {
      final dto = await _remoteDataSource.getTripById(id);
      return _mapToEntity(dto);
    } catch (e) {
      // Если поездка не найдена (404), возвращаем null
      return null;
    }
  }

  @override
  Future<Trip> createTrip(CreateTripRequest request) async {
    final dto = await _remoteDataSource.createTrip(request.toJson());
    return _mapToEntity(dto);
  }

  @override
  Future<Trip> updateTrip(String id, UpdateTripRequest request) async {
    final dto = await _remoteDataSource.updateTrip(id, request.toJson());
    return _mapToEntity(dto);
  }

  @override
  Future<void> deleteTrip(String id) async {
    await _remoteDataSource.deleteTrip(id);
  }

  @override
  Future<Trip> addPackingItem(String tripId, String wardrobeItemId) async {
    final dto = await _remoteDataSource.addPackingItem(tripId, wardrobeItemId);
    return _mapToEntity(dto);
  }

  @override
  Future<Trip> removePackingItem(String tripId, String itemId) async {
    final dto = await _remoteDataSource.removePackingItem(tripId, itemId);
    return _mapToEntity(dto);
  }

  @override
  Future<Trip> togglePackingItem(String tripId, String itemId, bool isPacked) async {
    final dto = await _remoteDataSource.togglePackingItem(tripId, itemId, isPacked);
    return _mapToEntity(dto);
  }

  @override
  Future<Trip> refreshWeather(String tripId) async {
    final dto = await _remoteDataSource.refreshWeather(tripId);
    return _mapToEntity(dto);
  }

  /// Преобразовать DTO в Entity
  Trip _mapToEntity(TripDto dto) {
    return Trip(
      id: dto.id,
      userId: dto.userId,
      name: dto.name,
      destination: dto.destination,
      startDate: _parseDate(dto.startDate),
      endDate: _parseDate(dto.endDate),
      occasions: dto.occasions,
      packingList: _parsePackingList(dto.packingList),
      status: TripStatusExtension.fromCode(dto.status),
      weather: dto.weather != null ? _mapWeatherToEntity(dto.weather!) : null,
      destinationLat: dto.destinationLat,
      destinationLon: dto.destinationLon,
      createdAt: dto.createdAt,
    );
  }

  DateTime _parseDate(String dateString) {
    // Формат YYYY-MM-DD
    final parts = dateString.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  List<TripPackingItem> _parsePackingList(dynamic packingList) {
    if (packingList == null) return const [];
    if (packingList is! List) return const [];
    
    return packingList.map((item) {
      if (item is Map<String, dynamic>) {
        return TripPackingItem(
          id: item['id'] as String? ?? '',
          wardrobeItemId: item['wardrobe_item_id'] as String? ?? '',
          name: item['name'] as String? ?? 'Без названия',
          category: item['category'] as String?,
          imageUrl: item['image_url'] as String?,
          isPacked: item['is_packed'] as bool? ?? false,
          isRecommended: item['is_recommended'] as bool? ?? false,
        );
      }
      // Если элемент не Map, создаём заглушку
      return const TripPackingItem(
        id: '',
        wardrobeItemId: '',
        name: 'Неизвестный элемент',
      );
    }).toList();
  }

  TripWeather _mapWeatherToEntity(WeatherDto dto) {
    return TripWeather(
      temperature: dto.temperature,
      condition: dto.condition,
      feelsLike: dto.feelsLike,
      humidity: dto.humidity,
      windSpeed: dto.windSpeed,
      iconUrl: dto.iconUrl,
    );
  }
}
