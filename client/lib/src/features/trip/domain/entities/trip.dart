import 'package:equatable/equatable.dart';

/// Статус поездки
enum TripStatus {
  planned,   // Планируется
  active,    // Активна
  completed, // Завершена
}

/// Расширение для отображения статуса
extension TripStatusExtension on TripStatus {
  String get name {
    switch (this) {
      case TripStatus.planned:
        return 'Планируется';
      case TripStatus.active:
        return 'Активна';
      case TripStatus.completed:
        return 'Завершена';
    }
  }

  String get code {
    switch (this) {
      case TripStatus.planned:
        return 'planned';
      case TripStatus.active:
        return 'active';
      case TripStatus.completed:
        return 'completed';
    }
  }

  static TripStatus fromCode(String? code) {
    switch (code) {
      case 'active':
        return TripStatus.active;
      case 'completed':
        return TripStatus.completed;
      case 'planned':
      default:
        return TripStatus.planned;
    }
  }
}

/// Элемент в списке вещей для поездки
class TripPackingItem extends Equatable {
  final String id;
  final String wardrobeItemId;
  final String name;
  final String? category;
  final String? imageUrl;
  final bool isPacked;
  final bool isRecommended;

  const TripPackingItem({
    required this.id,
    required this.wardrobeItemId,
    required this.name,
    this.category,
    this.imageUrl,
    this.isPacked = false,
    this.isRecommended = false,
  });

  TripPackingItem copyWith({
    String? id,
    String? wardrobeItemId,
    String? name,
    String? category,
    String? imageUrl,
    bool? isPacked,
    bool? isRecommended,
  }) {
    return TripPackingItem(
      id: id ?? this.id,
      wardrobeItemId: wardrobeItemId ?? this.wardrobeItemId,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isPacked: isPacked ?? this.isPacked,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }

  @override
  List<Object?> get props => [
        id,
        wardrobeItemId,
        name,
        category,
        imageUrl,
        isPacked,
        isRecommended,
      ];
}

/// Данные о погоде в пункте назначения
class TripWeather extends Equatable {
  final double temperature;
  final String condition;
  final double? feelsLike;
  final int? humidity;
  final int? windSpeed;
  final String? iconUrl;

  const TripWeather({
    required this.temperature,
    required this.condition,
    this.feelsLike,
    this.humidity,
    this.windSpeed,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [
        temperature,
        condition,
        feelsLike,
        humidity,
        windSpeed,
        iconUrl,
      ];
}

/// Сущность поездки
class Trip extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> occasions;
  final List<TripPackingItem> packingList;
  final TripStatus status;
  final TripWeather? weather;
  final double? destinationLat;
  final double? destinationLon;
  final DateTime createdAt;

  const Trip({
    required this.id,
    required this.userId,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.occasions,
    required this.packingList,
    required this.status,
    this.weather,
    this.destinationLat,
    this.destinationLon,
    required this.createdAt,
  });

  Trip copyWith({
    String? id,
    String? userId,
    String? name,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? occasions,
    List<TripPackingItem>? packingList,
    TripStatus? status,
    TripWeather? weather,
    double? destinationLat,
    double? destinationLon,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      occasions: occasions ?? this.occasions,
      packingList: packingList ?? this.packingList,
      status: status ?? this.status,
      weather: weather ?? this.weather,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLon: destinationLon ?? this.destinationLon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Получить количество собранных вещей
  int get packedCount => packingList.where((item) => item.isPacked).length;

  /// Получить общее количество вещей
  int get totalCount => packingList.length;

  /// Прогресс сборки (0.0 - 1.0)
  double get packingProgress => totalCount > 0 ? packedCount / totalCount : 0.0;

  /// Активна ли поездка сейчас
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Завершена ли поездка
  bool get isCompleted {
    return DateTime.now().isAfter(endDate.add(const Duration(days: 1)));
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        destination,
        startDate,
        endDate,
        occasions,
        packingList,
        status,
        weather,
        destinationLat,
        destinationLon,
        createdAt,
      ];
}
