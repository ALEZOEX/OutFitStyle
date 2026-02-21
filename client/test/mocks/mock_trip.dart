import 'package:outfitstyle_client/src/features/trip/domain/entities/trip.dart';

/// Тестовые данные для поездок
class MockTrip {
  /// Создать тестовую поездку
  static Trip create({
    String id = 'test_trip',
    String userId = 'test_user',
    String name = 'Тестовая поездка',
    String destination = 'Париж, Франция',
    DateTime? startDate,
    DateTime? endDate,
    List<String>? occasions,
    List<TripPackingItem>? packingList,
    TripStatus status = TripStatus.planned,
    TripWeather? weather,
    double? destinationLat,
    double? destinationLon,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id,
      userId: userId,
      name: name,
      destination: destination,
      startDate: startDate ?? DateTime.now().add(const Duration(days: 7)),
      endDate: endDate ?? DateTime.now().add(const Duration(days: 14)),
      occasions: occasions ?? const ['casual', 'business'],
      packingList: packingList ?? const [],
      status: status,
      weather: weather,
      destinationLat: destinationLat,
      destinationLon: destinationLon,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Список тестовых поездок
  static List<Trip> createList({int count = 5}) {
    final destinations = [
      'Париж, Франция',
      'Лондон, Великобритания',
      'Рим, Италия',
      'Барселона, Испания',
      'Берлин, Германия',
      'Токио, Япония',
      'Нью-Йорк, США',
      'Прага, Чехия',
    ];

    final names = [
      'Отпуск в Европе',
      'Деловая поездка',
      'Каникулы',
      'Путешествие мечты',
      'Выходные в городе',
      'Летний отдых',
      'Зимние каникулы',
      'Весенние каникулы',
    ];

    final statuses = [
      TripStatus.planned,
      TripStatus.active,
      TripStatus.completed,
    ];

    return List.generate(count, (index) => create(
      id: 'trip_$index',
      name: names[index % names.length],
      destination: destinations[index % destinations.length],
      startDate: DateTime.now().add(Duration(days: index * 7)),
      endDate: DateTime.now().add(Duration(days: index * 7 + 7)),
      status: statuses[index % statuses.length],
      createdAt: DateTime.now().subtract(Duration(days: index * 10)),
    ));
  }

  /// Активная поездка
  static Trip active() {
    return create(
      id: 'active_trip',
      name: 'Активная поездка',
      destination: 'Париж, Франция',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      status: TripStatus.active,
      weather: TripWeather(
        temperature: 18,
        condition: 'Cloudy',
        feelsLike: 17,
        humidity: 65,
        windSpeed: 3,
        iconUrl: '04d',
      ),
      packingList: [
        TripPackingItem(
          id: 'item_1',
          wardrobeItemId: 'wardrobe_1',
          name: 'Джинсы',
          category: 'bottoms',
          isPacked: true,
          isRecommended: true,
        ),
        TripPackingItem(
          id: 'item_2',
          wardrobeItemId: 'wardrobe_2',
          name: 'Футболка',
          category: 'tops',
          isPacked: false,
          isRecommended: true,
        ),
      ],
    );
  }

  /// Запланированная поездка
  static Trip planned() {
    return create(
      id: 'planned_trip',
      name: 'Запланированная поездка',
      destination: 'Лондон, Великобритания',
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 37)),
      status: TripStatus.planned,
      occasions: const ['sightseeing', 'casual'],
    );
  }

  /// Завершённая поездка
  static Trip completed() {
    return create(
      id: 'completed_trip',
      name: 'Завершённая поездка',
      destination: 'Рим, Италия',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().subtract(const Duration(days: 23)),
      status: TripStatus.completed,
    );
  }

  /// Поездка с вещами
  static Trip withPackingList() {
    return create(
      id: 'packing_trip',
      name: 'Поездка со списком',
      destination: 'Барселона, Испания',
      status: TripStatus.planned,
      packingList: [
        TripPackingItem(
          id: 'pack_1',
          wardrobeItemId: 'w_1',
          name: 'Плавки',
          category: 'swimwear',
          isPacked: true,
          isRecommended: true,
        ),
        TripPackingItem(
          id: 'pack_2',
          wardrobeItemId: 'w_2',
          name: 'Солнцезащитные очки',
          category: 'accessories',
          isPacked: false,
          isRecommended: true,
        ),
        TripPackingItem(
          id: 'pack_3',
          wardrobeItemId: 'w_3',
          name: 'Крем от загара',
          category: 'toiletries',
          isPacked: false,
          isRecommended: false,
        ),
      ],
    );
  }

  /// Поездка с погодой
  static Trip withWeather() {
    return create(
      id: 'weather_trip',
      name: 'Поездка с погодой',
      destination: 'Токио, Япония',
      status: TripStatus.active,
      weather: TripWeather(
        temperature: 22,
        condition: 'Rain',
        feelsLike: 20,
        humidity: 80,
        windSpeed: 5,
        iconUrl: '10d',
      ),
    );
  }

  /// Поездка на выходные
  static Trip weekend() {
    return create(
      id: 'weekend_trip',
      name: 'Выходные в Праге',
      destination: 'Прага, Чехия',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      status: TripStatus.planned,
      occasions: const ['casual'],
    );
  }

  /// Деловая поездка
  static Trip business() {
    return create(
      id: 'business_trip',
      name: 'Конференция в Берлине',
      destination: 'Берлин, Германия',
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 17)),
      status: TripStatus.planned,
      occasions: const ['business', 'formal'],
    );
  }
}
