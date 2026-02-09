import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di.dart'; // Import the main DI file to access shared providers

// Import usecase interfaces and implementations
import 'package:outfitstyle_client/domain/usecases/weather_usecases.dart';
import 'package:outfitstyle_client/domain/usecases/wardrobe_usecases.dart';

// Domain use case providers
// Weather use cases
final getWeatherUsecaseProvider = Provider<GetWeatherUsecase>(
  (ref) => GetWeatherUsecaseImpl(
    ref.watch(weatherRepositoryProvider),
    ref.watch(loggerProvider),
  ),
);

final getWeatherForecastUsecaseProvider = Provider<GetWeatherForecastUsecase>(
  (ref) => GetWeatherForecastUsecaseImpl(
    ref.watch(weatherRepositoryProvider),
    ref.watch(loggerProvider),
  ),
);

final getHistoricalWeatherUsecaseProvider = Provider<GetHistoricalWeatherUsecase>(
  (ref) => GetHistoricalWeatherUsecaseImpl(
    ref.watch(weatherRepositoryProvider),
    ref.watch(loggerProvider),
  ),
);

// Wardrobe use case providers
final getAllWardrobeItemsUsecaseProvider = Provider<GetWardrobeItemsUsecase>(
  (ref) => GetWardrobeItemsUsecaseImpl(
    ref.watch(wardrobeRepositoryProvider),
  ),
);

final addWardrobeItemUsecaseProvider = Provider<AddWardrobeItemUsecase>(
  (ref) => AddWardrobeItemUsecaseImpl(
    ref.watch(wardrobeRepositoryProvider),
  ),
);

final updateWardrobeItemUsecaseProvider = Provider<UpdateWardrobeItemUsecase>(
  (ref) => UpdateWardrobeItemUsecaseImpl(
    ref.watch(wardrobeRepositoryProvider),
  ),
);

final deleteWardrobeItemUsecaseProvider = Provider<DeleteWardrobeItemUsecase>(
  (ref) => DeleteWardrobeItemUsecaseImpl(
    ref.watch(wardrobeRepositoryProvider),
  ),
);

final getWardrobeItemByIdUsecaseProvider = Provider<GetWardrobeItemByIdUsecase>(
  (ref) => GetWardrobeItemByIdUsecaseImpl(
    ref.watch(wardrobeRepositoryProvider),
  ),
);

final filterWardrobeItemsUsecaseProvider = Provider<FilterWardrobeItemsUsecase>(
  (ref) => FilterWardrobeItemsUsecaseImpl(
    ref.watch(wardrobeRepositoryProvider),
  ),
);