import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../../domain/entities/outfit_recommendation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../presentation/providers/session_provider.dart';
import '../../../../utils/logger.dart';

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
enum RecommendationsLoadStatus { initial, loading, success, error }

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
        .where(
          (outfit) =>
              outfit.date.isAfter(start.subtract(const Duration(days: 1))) &&
              outfit.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}

/// Провайдер рекомендаций (использует глобальный ApiClient)
final recommendationsProvider =
    StateNotifierProvider<RecommendationsNotifier, RecommendationsState>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return RecommendationsNotifier(apiClient: apiClient);
    });

class RecommendationsNotifier extends StateNotifier<RecommendationsState> {
  final ApiClient _apiClient;

  RecommendationsNotifier({required ApiClient apiClient})
    : _apiClient = apiClient,
      super(const RecommendationsState()) {
    _loadRecommendations();
  }

  /// Загрузить рекомендации с API
  Future<void> _loadRecommendations() async {
    state = state.copyWith(status: RecommendationsLoadStatus.loading);

    try {
      // GET /api/v1/recommendations - получаем рекомендации
      final response = await _apiClient.get('/api/v1/recommendations');

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.data.toString()) as Map<String, dynamic>;
        final items =
            data['recommendations'] as List<dynamic>? ??
            data['items'] as List<dynamic>? ??
            [];

        final recommendations =
            items
                .map(
                  (item) => OutfitRecommendation.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();

        state = state.copyWith(
          recommendations: recommendations,
          status: RecommendationsLoadStatus.success,
        );
      } else {
        state = state.copyWith(
          status: RecommendationsLoadStatus.error,
          error: 'Ошибка загрузки рекомендаций (${response.statusCode})',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: RecommendationsLoadStatus.error,
        error: 'Ошибка загрузки рекомендаций',
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

    final plannedOutfits = Map<DateTime, PlannedOutfit>.from(
      state.plannedOutfits,
    );
    plannedOutfits[normalizedDate] = plannedOutfit;

    state = state.copyWith(plannedOutfits: plannedOutfits);
  }

  /// Отменить запланированный образ
  void cancelPlannedOutfit(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final plannedOutfits = Map<DateTime, PlannedOutfit>.from(
      state.plannedOutfits,
    );
    plannedOutfits.remove(normalizedDate);
    state = state.copyWith(plannedOutfits: plannedOutfits);
  }

  /// Сгенерировать новую рекомендацию через API
  Future<OutfitRecommendation?> generateRecommendation({
    double? temperature,
    String? weatherCondition,
    String? occasion,
  }) async {
    AppLogger.info('[RecommendationsProvider] generateRecommendation вызван');
    AppLogger.info('[RecommendationsProvider] temperature: $temperature, weatherCondition: $weatherCondition, occasion: $occasion');
    
    state = state.copyWith(isGenerating: true);

    try {
      final body = <String, dynamic>{};
      if (occasion != null) body['occasion'] = occasion;
      if (temperature != null) body['temperature'] = temperature;

      AppLogger.info('[RecommendationsProvider] Отправка POST /api/v1/recommendations: $body');
      final response = await _apiClient.post(
        '/api/v1/recommendations',
        data: body,
      );

      AppLogger.info('[RecommendationsProvider] Response statusCode: ${response.statusCode}');
      AppLogger.info('[RecommendationsProvider] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data =
            response.data is Map
                ? response.data as Map<String, dynamic>
                : jsonDecode(response.data.toString()) as Map<String, dynamic>;

        AppLogger.info('[RecommendationsProvider] Распарсенные данные: $data');
        final recommendation = OutfitRecommendation.fromJson(data);

        AppLogger.info('[RecommendationsProvider] Рекомендация создана: $recommendation');
        final recommendations = [recommendation, ...state.recommendations];
        state = state.copyWith(
          recommendations: recommendations,
          status: RecommendationsLoadStatus.success,
          isGenerating: false,
        );

        return recommendation;
      } else {
        AppLogger.error('[RecommendationsProvider] Ошибка генерации: statusCode=${response.statusCode}');
        state = state.copyWith(
          status: RecommendationsLoadStatus.error,
          error: 'Ошибка генерации (${response.statusCode})',
          isGenerating: false,
        );
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('[RecommendationsProvider] Исключение: $e', e, stackTrace);
      state = state.copyWith(
        status: RecommendationsLoadStatus.error,
        error: 'Ошибка генерации рекомендации',
        isGenerating: false,
      );
      return null;
    }
  }

  /// Удалить рекомендацию
  void removeRecommendation(String id) {
    final recommendations =
        state.recommendations.where((r) => r.id != id).toList();
    state = state.copyWith(recommendations: recommendations);
  }

  /// Перезагрузить рекомендации
  Future<void> refresh() async {
    await _loadRecommendations();
  }

  /// Получить рекомендации по погоде
  List<OutfitRecommendation> getByWeather(String condition) {
    return state.recommendations
        .where(
          (r) => r.weatherCondition?.toLowerCase() == condition.toLowerCase(),
        )
        .toList();
  }

  /// Получить использованные рекомендации
  List<OutfitRecommendation> getUsed() {
    return state.recommendations
        .where((r) => state.usedIds.contains(r.id))
        .toList();
  }
}

/// Провайдер для получения отфильтрованных рекомендаций
final filteredRecommendationsProvider = Provider<List<OutfitRecommendation>>((
  ref,
) {
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
