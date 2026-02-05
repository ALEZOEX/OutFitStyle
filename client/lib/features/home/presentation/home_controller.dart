import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/home_state.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../domain/entities/outfit_entity.dart';
import '../../../domain/entities/recommendation_entity.dart';

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(ref),
);

class HomeController extends StateNotifier<HomeState> {
  HomeController(Ref ref) : super(const HomeState());

  /// Инициализация контроллера
  Future<void> bootstrap() async {
    // Здесь может быть логика инициализации, например:
    // await loadUserData();
    // await loadWeatherData();
    // await loadOutfitData();
  }

  /// Парсинг погоды
  WeatherEntity? parseWeather(RecommendationRow recommendationRow) {
    try {
      final weatherData = recommendationRow.weatherDataJson;
      final weather = WeatherEntity.fromJson(
        Map<String, dynamic>.from(
          (jsonDecode(weatherData) as Map).cast<String, dynamic>(),
        ),
      );
      return weather;
    } catch (e) {
      // Логирование ошибки
      debugPrint('Ошибка при парсинге погоды: $e');
      return null;
    }
  }

  /// Парсинг наряда
  Map<String, dynamic>? parseOutfit(RecommendationRow recommendationRow) {
    try {
      final outfitData = recommendationRow.outfitDataJson;
      final outfitMap = jsonDecode(outfitData) as Map<String, dynamic>;
      return outfitMap;
    } catch (e) {
      // Логирование ошибки
      debugPrint('Ошибка при парсинге наряда: $e');
      return null;
    }
  }

  /// Обработка новой рекомендации
  void handleNewRecommendation(RecommendationRow recommendationRow) {
    try {
      // Обработка погоды
      final weatherData = recommendationRow.weatherDataJson;
      final weather = WeatherEntity.fromJson(
        Map<String, dynamic>.from(
          (jsonDecode(weatherData) as Map).cast<String, dynamic>(),
        ),
      );

      // Обработка наряда
      final outfitData = recommendationRow.outfitDataJson;
      final outfitMap = jsonDecode(outfitData) as Map<String, dynamic>;
      final outfit = OutfitEntity.fromJson(outfitMap);

      // Обновляем состояние
      state = state.copyWith(
        currentWeather: AsyncValue.data(weather),
        currentOutfit: AsyncValue.data(outfit),
      );
    } catch (e) {
      // Логирование ошибки
      debugPrint('Ошибка при обработке рекомендации: $e');
      state = state.copyWith(
        currentWeather: AsyncValue.error(e, StackTrace.current),
        currentOutfit: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  /// Переключение избранного
  Future<void> toggleFavorite(String outfitId) async {
    // Логика переключения избранного
    // Обновляем состояние в хранилище избранных нарядов
    // await _ref.read(favoritesRepositoryProvider).toggleFavorite(outfitId);

    // Обновляем локальное состояние, если текущий наряд является избранным
    final currentOutfitState = state.currentOutfit;
    if (currentOutfitState.hasValue) {
      final currentOutfit = currentOutfitState.value!;
      if (currentOutfit.id == outfitId) {
        final updatedOutfit = OutfitEntity(
          id: currentOutfit.id,
          name: currentOutfit.name,
          description: currentOutfit.description,
          items: currentOutfit.items,
          isFavorite: !currentOutfit.isFavorite,
          imageUrl: currentOutfit.imageUrl,
        );

        // Обновляем состояние UI
        state = state.copyWith(currentOutfit: AsyncValue.data(updatedOutfit));
      }
    }
  }

  /// Получение текущей погоды
  WeatherEntity? get currentWeather {
    final currentWeatherState = state.currentWeather;
    if (currentWeatherState.hasValue) {
      return currentWeatherState.value;
    }
    return null;
  }

  /// Получение текущего наряда
  OutfitEntity? get currentOutfit {
    final currentOutfitState = state.currentOutfit;
    if (currentOutfitState.hasValue) {
      return currentOutfitState.value;
    }
    return null;
  }

  Future<void> loadTodayOutfit() async {
    // Логика загрузки сегодняшнего аутфита
  }

  Future<void> loadWardrobeStats() async {
    // Логика загрузки статистики гардероба
  }

  Future<void> loadRecommendations() async {
    // Логика загрузки рекомендаций
  }
}
