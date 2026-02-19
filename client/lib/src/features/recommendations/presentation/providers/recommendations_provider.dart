import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/outfit_recommendation.dart';

/// Mock данные для рекомендаций
final mockRecommendations = <OutfitRecommendation>[
  OutfitRecommendation(
    id: '1',
    title: 'Повседневный образ для прохладной погоды',
    description: 'Комфортный outfit для прогулки в прохладный день. Сочетание стиля и практичности.',
    imageUrl: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600',
    recommendedItems: ['Худи серое', 'Джинсы Slim Fit', 'Кроссовки белые'],
    temperature: 12.0,
    weatherCondition: 'cloudy',
    createdAt: DateTime(2024, 2, 15),
  ),
  OutfitRecommendation(
    id: '2',
    title: 'Деловой стиль для офиса',
    description: 'Классический образ для рабочей встречи. Элегантность и профессионализм.',
    imageUrl: 'https://images.unsplash.com/photo-1487222477894-8943e31ef7b2?w=600',
    recommendedItems: ['Рубашка оксфорд', 'Брюки классические', 'Ботинки кожаные'],
    temperature: 18.0,
    weatherCondition: 'sunny',
    createdAt: DateTime(2024, 2, 14),
  ),
  OutfitRecommendation(
    id: '3',
    title: 'Зимний комплект',
    description: 'Тёплый и стильный образ для холодной зимней погоды.',
    imageUrl: 'https://images.unsplash.com/photo-1485968579580-b6d095142e6e?w=600',
    recommendedItems: ['Куртка зимняя', 'Пальто шерстяное', 'Шапка вязаная', 'Шарф шерстяной'],
    temperature: -5.0,
    weatherCondition: 'snowy',
    createdAt: DateTime(2024, 2, 13),
  ),
  OutfitRecommendation(
    id: '4',
    title: 'Спортивный образ для выходного',
    description: 'Удобный outfit для активного отдыха на свежем воздухе.',
    imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600',
    recommendedItems: ['Белая футболка Basic', 'Шорты летние', 'Кроссовки белые', 'Кепка бейсбольная'],
    temperature: 25.0,
    weatherCondition: 'sunny',
    createdAt: DateTime(2024, 2, 12),
  ),
  OutfitRecommendation(
    id: '5',
    title: 'Вечерний выход',
    description: 'Изысканный образ для особого случая. Будьте в центре внимания.',
    imageUrl: 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=600',
    recommendedItems: ['Рубашка оксфорд', 'Пальто шерстяное', 'Ботинки кожаные'],
    temperature: 10.0,
    weatherCondition: 'partly_cloudy',
    createdAt: DateTime(2024, 2, 11),
  ),
  OutfitRecommendation(
    id: '6',
    title: 'Дождливый день',
    description: 'Практичный outfit для дождливой погоды. Оставайтесь сухим и стильным.',
    imageUrl: 'https://images.unsplash.com/photo-1512413914633-b5043f4041ea?w=600',
    recommendedItems: ['Куртка зимняя', 'Джинсы Slim Fit', 'Ботинки кожаные'],
    temperature: 8.0,
    weatherCondition: 'rainy',
    createdAt: DateTime(2024, 2, 10),
  ),
];

/// Запись запланированного образа
class PlannedOutfit {
  final String id;
  final String recommendationId;
  final DateTime date;
  final String? title;
  final String? description;
  final List<String>? items;

  const PlannedOutfit({
    required this.id,
    required this.recommendationId,
    required this.date,
    this.title,
    this.description,
    this.items,
  });

  PlannedOutfit copyWith({
    String? id,
    String? recommendationId,
    DateTime? date,
    String? title,
    String? description,
    List<String>? items,
  }) {
    return PlannedOutfit(
      id: id ?? this.id,
      recommendationId: recommendationId ?? this.recommendationId,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
    );
  }
}

/// Состояние загрузки и рекомендаций
enum RecommendationsLoadStatus {
  initial,
  loading,
  success,
  error,
}

/// Состояние рекомендаций
class RecommendationsState {
  final List<OutfitRecommendation> recommendations;
  final RecommendationsLoadStatus status;
  final String? error;
  final Set<String> usedIds;
  final Map<DateTime, PlannedOutfit> plannedOutfits;
  final bool isGenerating;

  const RecommendationsState({
    this.recommendations = const [],
    this.status = RecommendationsLoadStatus.initial,
    this.error,
    this.usedIds = const {},
    this.plannedOutfits = const {},
    this.isGenerating = false,
  });

  RecommendationsState copyWith({
    List<OutfitRecommendation>? recommendations,
    RecommendationsLoadStatus? status,
    String? error,
    Set<String>? usedIds,
    Map<DateTime, PlannedOutfit>? plannedOutfits,
    bool? isGenerating,
  }) {
    return RecommendationsState(
      recommendations: recommendations ?? this.recommendations,
      status: status ?? this.status,
      error: error ?? this.error,
      usedIds: usedIds ?? this.usedIds,
      plannedOutfits: plannedOutfits ?? this.plannedOutfits,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }

  bool isUsed(String id) => usedIds.contains(id);

  /// Получить использованные рекомендации
  List<OutfitRecommendation> getUsed() {
    return recommendations.where((r) => usedIds.contains(r.id)).toList();
  }

  /// Получить запланированные образы на дату
  PlannedOutfit? getPlannedOutfit(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return plannedOutfits[normalizedDate];
  }

  /// Получить все запланированные образы
  List<PlannedOutfit> getAllPlannedOutfits() {
    return plannedOutfits.values.toList();
  }

  /// Получить запланированные образы на неделю
  List<PlannedOutfit> getPlannedForWeek(DateTime startDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = start.add(const Duration(days: 6));
    
    return plannedOutfits.values
        .where((outfit) => outfit.date.isAfter(start.subtract(const Duration(days: 1))) && 
                           outfit.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}

/// Провайдер рекомендаций
final recommendationsProvider =
    StateNotifierProvider<RecommendationsNotifier, RecommendationsState>((ref) {
  return RecommendationsNotifier();
});

class RecommendationsNotifier extends StateNotifier<RecommendationsState> {
  RecommendationsNotifier() : super(const RecommendationsState()) {
    _loadRecommendations();
  }

  /// Загрузить рекомендации (с mock данными)
  Future<void> _loadRecommendations() async {
    state = state.copyWith(status: RecommendationsLoadStatus.loading);

    try {
      // Имитация задержки загрузки
      await Future.delayed(const Duration(milliseconds: 1000));

      state = state.copyWith(
        recommendations: mockRecommendations,
        status: RecommendationsLoadStatus.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: RecommendationsLoadStatus.error,
        error: 'Ошибка загрузки: $e',
      );
    }
  }

  /// Отметить рекомендацию как использованную
  void markAsUsed(String id) {
    final usedIds = Set<String>.from(state.usedIds);
    usedIds.add(id);
    state = state.copyWith(usedIds: usedIds);
  }

  /// Запланировать образ на дату
  void planOutfit({
    required String recommendationId,
    required DateTime date,
    String? title,
    String? description,
  }) {
    final recommendation = state.recommendations.firstWhere(
      (r) => r.id == recommendationId,
      orElse: () => throw Exception('Recommendation not found'),
    );

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final plannedOutfit = PlannedOutfit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recommendationId: recommendationId,
      date: normalizedDate,
      title: title ?? recommendation.title,
      description: description ?? recommendation.description,
      items: recommendation.recommendedItems,
    );

    final plannedOutfits = Map<DateTime, PlannedOutfit>.from(state.plannedOutfits);
    plannedOutfits[normalizedDate] = plannedOutfit;
    
    state = state.copyWith(plannedOutfits: plannedOutfits);
  }

  /// Отменить запланированный образ
  void cancelPlannedOutfit(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final plannedOutfits = Map<DateTime, PlannedOutfit>.from(state.plannedOutfits);
    plannedOutfits.remove(normalizedDate);
    state = state.copyWith(plannedOutfits: plannedOutfits);
  }

  /// Сгенерировать новую рекомендацию
  Future<OutfitRecommendation?> generateRecommendation({
    double? temperature,
    String? weatherCondition,
    String? occasion,
  }) async {
    state = state.copyWith(isGenerating: true);

    try {
      // Имитация генерации рекомендации
      await Future.delayed(const Duration(seconds: 2));

      final newRecommendation = OutfitRecommendation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _generateTitle(occasion, weatherCondition),
        description: _generateDescription(occasion, weatherCondition),
        imageUrl: 'https://images.unsplash.com/photo-1550614000-4b9519e02d48?w=600',
        recommendedItems: _getRandomItems(),
        temperature: temperature ?? 15.0,
        weatherCondition: weatherCondition ?? 'sunny',
        createdAt: DateTime.now(),
      );

      final recommendations = [newRecommendation, ...state.recommendations];
      state = state.copyWith(
        recommendations: recommendations,
        status: RecommendationsLoadStatus.success,
        isGenerating: false,
      );

      return newRecommendation;
    } catch (e) {
      state = state.copyWith(
        status: RecommendationsLoadStatus.error,
        error: 'Ошибка генерации: $e',
        isGenerating: false,
      );
      return null;
    }
  }

  /// Удалить рекомендацию
  void removeRecommendation(String id) {
    final recommendations = state.recommendations.where((r) => r.id != id).toList();
    state = state.copyWith(recommendations: recommendations);
  }

  /// Перезагрузить рекомендации
  Future<void> refresh() async {
    await _loadRecommendations();
  }

  /// Получить рекомендации по погоде
  List<OutfitRecommendation> getByWeather(String condition) {
    return state.recommendations
        .where((r) => r.weatherCondition?.toLowerCase() == condition.toLowerCase())
        .toList();
  }

  /// Получить использованные рекомендации
  List<OutfitRecommendation> getUsed() {
    return state.recommendations.where((r) => state.usedIds.contains(r.id)).toList();
  }

  // ==================== Private Methods ====================

  String _generateTitle(String? occasion, String? weather) {
    final titles = [
      'Персональная рекомендация',
      'Ваш идеальный образ',
      'Стильный outfit дня',
      'Рекомендация на основе погоды',
    ];
    return titles[DateTime.now().millisecond % titles.length];
  }

  String _generateDescription(String? occasion, String? weather) {
    return 'Индивидуально подобранный outfit с учётом ваших предпочтений и текущих условий.';
  }

  List<String> _getRandomItems() {
    const items = [
      'Белая футболка Basic',
      'Джинсы Slim Fit',
      'Кроссовки белые',
      'Худи серое',
      'Рубашка оксфорд',
      'Куртка зимняя',
      'Шапка вязаная',
    ];
    final shuffled = List<String>.from(items)..shuffle();
    return shuffled.sublist(0, shuffled.length < 3 ? shuffled.length : 3);
  }
}

/// Провайдер для получения отфильтрованных рекомендаций
final filteredRecommendationsProvider =
    Provider<List<OutfitRecommendation>>((ref) {
  final state = ref.watch(recommendationsProvider);
  return state.recommendations;
});

/// Провайдер для получения статистики рекомендаций
final recommendationsStatsProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(recommendationsProvider);
  return {
    'total': state.recommendations.length,
    'planned': state.plannedOutfits.length,
    'used': state.usedIds.length,
  };
});
