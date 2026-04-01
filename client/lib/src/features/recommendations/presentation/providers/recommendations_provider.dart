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
  final Set<String> likedIds;
  final Map<DateTime, PlannedOutfit> plannedOutfits;
  final bool isGenerating;

  const RecommendationsState({
    this.recommendations = const [],
    this.status = RecommendationsLoadStatus.initial,
    this.error,
    this.usedIds = const {},
    this.likedIds = const {},
    this.plannedOutfits = const {},
    this.isGenerating = false,
  });

  RecommendationsState copyWith({
    List<OutfitRecommendation>? recommendations,
    RecommendationsLoadStatus? status,
    String? error,
    Set<String>? usedIds,
    Set<String>? likedIds,
    Map<DateTime, PlannedOutfit>? plannedOutfits,
    bool? isGenerating,
  }) {
    return RecommendationsState(
      recommendations: recommendations ?? this.recommendations,
      status: status ?? this.status,
      error: error ?? this.error,
      usedIds: usedIds ?? this.usedIds,
      likedIds: likedIds ?? this.likedIds,
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
        final rawData = response.data is Map
            ? response.data as Map<String, dynamic>
            : jsonDecode(response.data.toString()) as Map<String, dynamic>;
        final items =
            rawData['recommendations'] as List<dynamic>? ??
            rawData['items'] as List<dynamic>? ??
            [];

        final recommendations = items
            .map(
              (item) =>
                  OutfitRecommendation.fromJson(item as Map<String, dynamic>),
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
    required double latitude,
    required double longitude,
    String? occasion,
  }) async {
    AppLogger.info('[RecommendationsProvider] 🔵 generateRecommendation ВЫЗВАН');
    AppLogger.info(
      '[RecommendationsProvider] 📍 latitude: $latitude, longitude: $longitude, occasion: $occasion',
    );

    state = state.copyWith(isGenerating: true);
    AppLogger.info('[RecommendationsProvider] ⚙️ isGenerating=true');

    try {
      final body = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
      };
      if (occasion != null) body['occasion'] = occasion;

      AppLogger.info(
        '[RecommendationsProvider] 📤 ОТПРАВКА POST /api/v1/recommendations',
      );
      AppLogger.info('[RecommendationsProvider] 📦 Body: $body');
      
      final response = await _apiClient.post(
        '/api/v1/recommendations',
        data: body,
      );

      AppLogger.info(
        '[RecommendationsProvider] 📥 Response statusCode: ${response.statusCode}',
      );
      AppLogger.info(
        '[RecommendationsProvider] 📦 Response data: ${response.data}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = response.data is Map
            ? response.data as Map<String, dynamic>
            : jsonDecode(response.data.toString()) as Map<String, dynamic>;

        // Backend возвращает {"recommendation": {...}, ...} или сразу объект
        final data = rawData.containsKey('recommendation')
            ? rawData['recommendation'] as Map<String, dynamic>
            : rawData;

        AppLogger.info('[RecommendationsProvider] 📋 Распарсенные данные: $data');
        final recommendation = OutfitRecommendation.fromJson(data);

        AppLogger.info(
          '[RecommendationsProvider] ✅ Рекомендация создана: ID=${recommendation.id}, title=${recommendation.title}',
        );
        final recommendations = [recommendation, ...state.recommendations];
        state = state.copyWith(
          recommendations: recommendations,
          status: RecommendationsLoadStatus.success,
          isGenerating: false,
        );
        AppLogger.info('[RecommendationsProvider] 🎉 Возвращаем рекомендацию клиенту');

        return recommendation;
      } else {
        AppLogger.error(
          '[RecommendationsProvider] ❌ Ошибка генерации: statusCode=${response.statusCode}',
        );
        final statusCode = response.statusCode;
        final userMessage = _getUserMessage(statusCode);
        AppLogger.error('[RecommendationsProvider] 💬 User message: $userMessage');
        state = state.copyWith(
          status: RecommendationsLoadStatus.error,
          error: userMessage,
          isGenerating: false,
        );
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '[RecommendationsProvider] 💥 Исключение: $e',
        e,
        stackTrace,
      );
      final userMessage = _getExceptionMessage(e);
      AppLogger.error('[RecommendationsProvider] 💬 User message from exception: $userMessage');
      state = state.copyWith(
        status: RecommendationsLoadStatus.error,
        error: userMessage,
        isGenerating: false,
      );
      return null;
    }
  }

  /// Понятное сообщение для пользователя по коду ошибки
  String _getUserMessage(int? statusCode) {
    switch (statusCode) {
      case 500:
        return 'Сервис временно недоступен. Попробуйте через минуту';
      case 502:
      case 503:
        return 'Сервер перегружен. Подождите немного';
      case 401:
        return 'Сессия истекла. Войдите заново';
      case 400:
        return 'Неверные данные запроса';
      case 429:
        return 'Слишком много запросов. Подождите';
      default:
        return 'Ошибка соединения ($statusCode)';
    }
  }

  /// Понятное сообщение для исключений
  String _getExceptionMessage(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('connection')) {
      return 'Нет соединения с интернетом';
    }
    if (msg.contains('timeout')) {
      return 'Время ожидания истекло. Попробуйте снова';
    }
    return 'Что-то пошло не так. Попробуйте снова';
  }

  /// Удалить рекомендацию
  void removeRecommendation(String id) {
    final recommendations = state.recommendations
        .where((r) => r.id != id)
        .toList();
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

  /// Переключить лайк рекомендации
  void toggleLike(String id) {
    final likedIds = Set<String>.from(state.likedIds);
    if (likedIds.contains(id)) {
      likedIds.remove(id);
    } else {
      likedIds.add(id);
    }
    state = state.copyWith(likedIds: likedIds);
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
