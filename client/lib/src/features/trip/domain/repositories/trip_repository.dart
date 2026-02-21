import '../entities/trip.dart';

/// Запрос на создание поездки
class CreateTripRequest {
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> occasions;
  final double? destinationLat;
  final double? destinationLon;

  CreateTripRequest({
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.occasions = const [],
    this.destinationLat,
    this.destinationLon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'destination': destination,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      if (occasions.isNotEmpty) 'occasions': occasions,
      if (destinationLat != null) 'destination_lat': destinationLat,
      if (destinationLon != null) 'destination_lon': destinationLon,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Запрос на обновление поездки
class UpdateTripRequest {
  final String? name;
  final String? destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? occasions;
  final TripStatus? status;
  final double? destinationLat;
  final double? destinationLon;

  UpdateTripRequest({
    this.name,
    this.destination,
    this.startDate,
    this.endDate,
    this.occasions,
    this.status,
    this.destinationLat,
    this.destinationLon,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (destination != null) 'destination': destination,
      if (startDate != null) 'start_date': _formatDate(startDate!),
      if (endDate != null) 'end_date': _formatDate(endDate!),
      if (occasions != null) 'occasions': occasions,
      if (status != null) 'status': status!.code,
      if (destinationLat != null) 'destination_lat': destinationLat,
      if (destinationLon != null) 'destination_lon': destinationLon,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Интерфейс репозитория для работы с поездками
abstract class TripRepository {
  /// Получить список всех поездок пользователя
  Future<List<Trip>> getTrips();

  /// Получить поездку по ID
  Future<Trip?> getTripById(String id);

  /// Создать новую поездку
  Future<Trip> createTrip(CreateTripRequest request);

  /// Обновить поездку
  Future<Trip> updateTrip(String id, UpdateTripRequest request);

  /// Удалить поездку
  Future<void> deleteTrip(String id);

  /// Добавить вещь в список вещей поездки
  Future<Trip> addPackingItem(String tripId, String wardrobeItemId);

  /// Удалить вещь из списка вещей поездки
  Future<Trip> removePackingItem(String tripId, String itemId);

  /// Отметить вещь как собранную/разобранную
  Future<Trip> togglePackingItem(String tripId, String itemId, bool isPacked);

  /// Обновить погоду для поездки
  Future<Trip> refreshWeather(String tripId);
}
