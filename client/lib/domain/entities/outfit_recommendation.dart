import 'package:equatable/equatable.dart';
import 'wardrobe.dart'; // Updated import to use the unified WardrobeItem

// Доменная сущность для рекомендации образа
class OutfitRecommendation extends Equatable {
  final String id;
  final String userId;
  final String occasion;
  final List<WardrobeItem> recommendedItems; // Список объектов WardrobeItem
  final double confidenceScore;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<double> temperatureRange;
  final String weatherCondition;
  final String season;
  final String style;
  final String notes;
  final bool isFavorite;
  final bool isActive;

  const OutfitRecommendation({
    required this.id,
    required this.userId,
    required this.occasion,
    required this.recommendedItems,
    required this.confidenceScore,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.temperatureRange,
    required this.weatherCondition,
    required this.season,
    required this.style,
    required this.notes,
    required this.isFavorite,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        occasion,
        recommendedItems,
        confidenceScore,
        metadata,
        createdAt,
        updatedAt,
        temperatureRange,
        weatherCondition,
        season,
        style,
        notes,
        isFavorite,
        isActive,
      ];

  OutfitRecommendation copyWith({
    String? id,
    String? userId,
    String? occasion,
    List<WardrobeItem>? recommendedItems,
    double? confidenceScore,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<double>? temperatureRange,
    String? weatherCondition,
    String? season,
    String? style,
    String? notes,
    bool? isFavorite,
    bool? isActive,
  }) {
    return OutfitRecommendation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      occasion: occasion ?? this.occasion,
      recommendedItems: recommendedItems ?? this.recommendedItems,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      temperatureRange: temperatureRange ?? this.temperatureRange,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      season: season ?? this.season,
      style: style ?? this.style,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      isActive: isActive ?? this.isActive,
    );
  }

  // Методы бизнес-логики
  bool isSuitableForWeather(double temperature, String weather) {
    final tempInRange = temperature >= temperatureRange.first && temperature <= temperatureRange.last;
    final weatherMatch = weather.toLowerCase().contains(weatherCondition.toLowerCase());
    return tempInRange && weatherMatch;
  }

  bool isSuitableForOccasion(String occasion) {
    return this.occasion.toLowerCase().contains(occasion.toLowerCase()) ||
        occasion.toLowerCase().contains(this.occasion.toLowerCase());
  }

  bool isHighConfidence() {
    return confidenceScore >= 0.8;
  }

  bool isExpired([int hours = 24]) {
    final expirationTime = DateTime.now().subtract(Duration(hours: hours));
    return createdAt.isBefore(expirationTime);
  }

  // Helper methods
  List<String> getItemIds() {
    return recommendedItems.map((item) => item.id).toList();
  }

  int getTotalItems() {
    return recommendedItems.length;
  }

  List<String> getItemCategories() {
    return recommendedItems.map((item) => item.category).toSet().toList();
  }

  List<String> getItemStyles() {
    return recommendedItems.map((item) => item.style).toSet().toList();
  }
}