import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../services/auth_storage.dart';
import '../../data/datasources/trip_remote_data_source.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

/// Статус загрузки
enum TripLoadStatus {
  initial,
  loading,
  refreshing,
  success,
  error,
}

/// Состояние списка поездок
class TripListState {
  final List<Trip> trips;
  final TripLoadStatus status;
  final TripStatus? filterStatus;
  final String? error;

  const TripListState({
    this.trips = const [],
    this.status = TripLoadStatus.initial,
    this.filterStatus,
    this.error,
  });

  TripListState copyWith({
    List<Trip>? trips,
    TripLoadStatus? status,
    TripStatus? filterStatus,
    String? error,
  }) {
    return TripListState(
      trips: trips ?? this.trips,
      status: status ?? this.status,
      filterStatus: filterStatus ?? this.filterStatus,
      error: error ?? this.error,
    );
  }

  /// Отфильтрованные поездки
  List<Trip> get filteredTrips {
    if (filterStatus == null) return trips;
    return trips.where((trip) => trip.status == filterStatus).toList();
  }

  /// Активные поездки
  List<Trip> get activeTrips => trips.where((t) => t.status == TripStatus.active).toList();

  /// Запланированные поездки
  List<Trip> get plannedTrips => trips.where((t) => t.status == TripStatus.planned).toList();

  /// Завершённые поездки
  List<Trip> get completedTrips => trips.where((t) => t.status == TripStatus.completed).toList();
}

/// Состояние детальной страницы поездки
class TripDetailState {
  final Trip? trip;
  final TripLoadStatus status;
  final String? error;
  final bool isUpdating;

  const TripDetailState({
    this.trip,
    this.status = TripLoadStatus.initial,
    this.error,
    this.isUpdating = false,
  });

  TripDetailState copyWith({
    Trip? trip,
    TripLoadStatus? status,
    String? error,
    bool? isUpdating,
  }) {
    return TripDetailState(
      trip: trip ?? this.trip,
      status: status ?? this.status,
      error: error ?? this.error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

/// Провайдер ApiClient для trip фичи
final _tripApiClientProvider = Provider<ApiClient>((ref) {
  final storage = AuthStorage();
  return ApiClient(storage: storage);
});

/// Провайдер TripRemoteDataSource
final tripRemoteDataSourceProvider = Provider<TripRemoteDataSource>((ref) {
  final apiClient = ref.watch(_tripApiClientProvider);
  return TripRemoteDataSource(apiClient: apiClient);
});

/// Провайдер TripRepository
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final remoteDataSource = ref.watch(tripRemoteDataSourceProvider);
  return TripRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Провайдер состояния списка поездок
final tripListProvider = StateNotifierProvider<TripListNotifier, TripListState>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripListNotifier(repository: repository);
});

class TripListNotifier extends StateNotifier<TripListState> {
  final TripRepository _repository;

  TripListNotifier({required TripRepository repository})
      : _repository = repository,
        super(const TripListState()) {
    loadTrips();
  }

  /// Загрузить список поездок
  Future<void> loadTrips() async {
    state = state.copyWith(status: TripLoadStatus.loading);

    try {
      final trips = await _repository.getTrips();
      state = state.copyWith(
        trips: trips,
        status: TripLoadStatus.success,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: TripLoadStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Обновить список (pull-to-refresh)
  Future<void> refresh() async {
    state = state.copyWith(status: TripLoadStatus.refreshing);

    try {
      final trips = await _repository.getTrips();
      state = state.copyWith(
        trips: trips,
        status: TripLoadStatus.success,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: TripLoadStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Установить фильтр по статусу
  void setFilter(TripStatus? status) {
    state = state.copyWith(filterStatus: status);
  }

  /// Очистить фильтр
  void clearFilter() {
    state = state.copyWith(filterStatus: null);
  }

  /// Добавить поездку в список (после создания)
  void addTrip(Trip trip) {
    final trips = List<Trip>.from(state.trips)..insert(0, trip);
    state = state.copyWith(trips: trips);
  }

  /// Обновить поездку в списке
  void updateTrip(Trip updatedTrip) {
    final trips = List<Trip>.from(state.trips)
      ..removeWhere((t) => t.id == updatedTrip.id);
    trips.insert(0, updatedTrip);
    state = state.copyWith(trips: trips);
  }

  /// Удалить поездку из списка
  void removeTrip(String tripId) {
    final trips = List<Trip>.from(state.trips)..removeWhere((t) => t.id == tripId);
    state = state.copyWith(trips: trips);
  }
}

/// Провайдер состояния детальной страницы поездки
final tripDetailProvider = StateNotifierProvider.family<TripDetailNotifier, TripDetailState, String>((ref, tripId) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripDetailNotifier(repository: repository, tripId: tripId);
});

class TripDetailNotifier extends StateNotifier<TripDetailState> {
  final TripRepository _repository;
  final String _tripId;

  TripDetailNotifier({
    required TripRepository repository,
    required String tripId,
  })  : _repository = repository,
        _tripId = tripId,
        super(const TripDetailState()) {
    loadTrip();
  }

  /// Загрузить поездку
  Future<void> loadTrip() async {
    state = state.copyWith(status: TripLoadStatus.loading);

    try {
      final trip = await _repository.getTripById(_tripId);
      state = state.copyWith(
        trip: trip,
        status: trip != null ? TripLoadStatus.success : TripLoadStatus.error,
        error: trip == null ? 'Поездка не найдена' : null,
      );
    } catch (e) {
      state = state.copyWith(
        status: TripLoadStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Обновить поездку
  Future<Trip?> updateTrip(UpdateTripRequest request) async {
    state = state.copyWith(isUpdating: true);

    try {
      final updatedTrip = await _repository.updateTrip(_tripId, request);
      state = state.copyWith(
        trip: updatedTrip,
        isUpdating: false,
        error: null,
      );
      return updatedTrip;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Удалить поездку
  Future<void> deleteTrip() async {
    try {
      await _repository.deleteTrip(_tripId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Добавить вещь в список
  Future<Trip?> addPackingItem(String wardrobeItemId) async {
    state = state.copyWith(isUpdating: true);

    try {
      final updatedTrip = await _repository.addPackingItem(_tripId, wardrobeItemId);
      state = state.copyWith(
        trip: updatedTrip,
        isUpdating: false,
        error: null,
      );
      return updatedTrip;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Удалить вещь из списка
  Future<Trip?> removePackingItem(String itemId) async {
    state = state.copyWith(isUpdating: true);

    try {
      final updatedTrip = await _repository.removePackingItem(_tripId, itemId);
      state = state.copyWith(
        trip: updatedTrip,
        isUpdating: false,
        error: null,
      );
      return updatedTrip;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Переключить статус вещи (собрана/не собрана)
  Future<Trip?> togglePackingItem(String itemId, bool isPacked) async {
    try {
      final updatedTrip = await _repository.togglePackingItem(_tripId, itemId, isPacked);
      // Обновляем локально без флага isUpdating для лучшей отзывчивости
      state = state.copyWith(trip: updatedTrip);
      return updatedTrip;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Обновить погоду
  Future<Trip?> refreshWeather() async {
    try {
      final updatedTrip = await _repository.refreshWeather(_tripId);
      state = state.copyWith(trip: updatedTrip);
      return updatedTrip;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

/// Провайдер для создания новой поездки
final createTripProvider = StateNotifierProvider<CreateTripNotifier, TripLoadStatus>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return CreateTripNotifier(repository: repository);
});

class CreateTripNotifier extends StateNotifier<TripLoadStatus> {
  final TripRepository _repository;
  Trip? _createdTrip;

  CreateTripNotifier({required TripRepository repository})
      : _repository = repository,
        super(TripLoadStatus.initial);

  Trip? get createdTrip => _createdTrip;

  /// Создать поездку
  Future<Trip?> createTrip(CreateTripRequest request) async {
    state = TripLoadStatus.loading;

    try {
      _createdTrip = await _repository.createTrip(request);
      state = TripLoadStatus.success;
      return _createdTrip;
    } catch (e) {
      state = TripLoadStatus.error;
      return null;
    }
  }

  /// Сбросить состояние
  void reset() {
    state = TripLoadStatus.initial;
    _createdTrip = null;
  }
}
