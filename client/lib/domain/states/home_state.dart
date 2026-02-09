import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/recommendation_entity.dart';
import '../entities/wardrobe.dart' as domain;
import '../entities/weather_entity.dart';
import '../entities/outfit_entity.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(AsyncValue.loading())
    AsyncValue<List<RecommendationRow>> todayRecommendations,
    @Default(AsyncValue.loading())
    AsyncValue<List<domain.WardrobeItem>> wardrobeStats,
    @Default(AsyncValue.data(null))
    AsyncValue<WeatherEntity?> currentWeather,
    @Default(AsyncValue.data(null))
    AsyncValue<OutfitEntity?> currentOutfit,
    @Default(false) bool isLoading,
    String? error,
  }) = _HomeState;

  const HomeState._();
}