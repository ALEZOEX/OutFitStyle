import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart' show UnauthorizedException;
import '../../../../data/remote/outfit_api_service.dart';
import '../../../../domain/entities/saved_outfit.dart';
import '../../../../presentation/providers/session_provider.dart';

/// Состояние загрузки образов
enum OutfitLoadStatus { initial, loading, success, error }

/// Состояние конструктора/планировщика образов
class OutfitState {
  final List<SavedOutfit> outfits;
  final OutfitLoadStatus status;
  final String? error;
  final bool isSaving;
  final bool isDeleting;
  final bool isAuthError;

  const OutfitState({
    this.outfits = const [],
    this.status = OutfitLoadStatus.initial,
    this.error,
    this.isSaving = false,
    this.isDeleting = false,
    this.isAuthError = false,
  });

  OutfitState copyWith({
    List<SavedOutfit>? outfits,
    OutfitLoadStatus? status,
    String? error,
    bool? isSaving,
    bool? isDeleting,
    bool? isAuthError,
  }) {
    return OutfitState(
      outfits: outfits ?? this.outfits,
      status: status ?? this.status,
      error: error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      isAuthError: isAuthError ?? this.isAuthError,
    );
  }

  /// Получить образы для конкретной даты
  List<SavedOutfit> getOutfitsForDate(DateTime date) {
    return outfits.where((outfit) {
      return outfit.createdAt.year == date.year &&
          outfit.createdAt.month == date.month &&
          outfit.createdAt.day == date.day;
    }).toList();
  }

  /// Получить образ по ID
  SavedOutfit? getOutfitById(String id) {
    try {
      return outfits.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Провайдер OutfitApiService
final outfitApiServiceProvider = Provider<OutfitApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OutfitApiService(apiClient: apiClient);
});

/// Провайдер состояния образов
final outfitProvider =
    StateNotifierProvider<OutfitNotifier, OutfitState>((ref) {
      final apiService = ref.watch(outfitApiServiceProvider);
      return OutfitNotifier(apiService: apiService);
    });

class OutfitNotifier extends StateNotifier<OutfitState> {
  final OutfitApiService _apiService;

  OutfitNotifier({required OutfitApiService apiService})
    : _apiService = apiService,
      super(const OutfitState()) {
    _loadOutfits();
  }

  /// Загрузить список образов с сервера
  Future<void> _loadOutfits() async {
    state = state.copyWith(status: OutfitLoadStatus.loading, isAuthError: false);

    try {
      final response = await _apiService.getOutfits(page: 1, limit: 100);

      state = state.copyWith(
        outfits: response.outfits,
        status: OutfitLoadStatus.success,
        error: null,
        isAuthError: false,
      );
    } catch (e) {
      final isAuth = _isAuthError(e);
      state = state.copyWith(
        status: OutfitLoadStatus.error,
        error: _extractErrorMessage(e),
        isAuthError: isAuth,
      );
    }
  }

  /// Создать новый образ
  Future<SavedOutfit?> createOutfit(SavedOutfitCreateRequest request) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final newOutfit = await _apiService.createOutfit(request);

      final outfits = List<SavedOutfit>.from(state.outfits)..add(newOutfit);
      state = state.copyWith(outfits: outfits, isSaving: false);

      return newOutfit;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: _extractErrorMessage(e));
      rethrow;
    }
  }

  /// Обновить образ
  Future<SavedOutfit?> updateOutfit(
    String id,
    SavedOutfitUpdateRequest request,
  ) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final updatedOutfit = await _apiService.updateOutfit(id, request);

      final outfits = List<SavedOutfit>.from(state.outfits);
      final index = outfits.indexWhere((o) => o.id == id);
      if (index != -1) {
        outfits[index] = updatedOutfit;
        state = state.copyWith(outfits: outfits, isSaving: false);
      }

      return updatedOutfit;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: _extractErrorMessage(e));
      rethrow;
    }
  }

  /// Удалить образ
  Future<void> deleteOutfit(String id) async {
    state = state.copyWith(isDeleting: true, error: null);

    try {
      await _apiService.deleteOutfit(id);

      final outfits = List<SavedOutfit>.from(state.outfits)
        ..removeWhere((o) => o.id == id);
      state = state.copyWith(outfits: outfits, isDeleting: false);
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: _extractErrorMessage(e));
      rethrow;
    }
  }

  /// Отметить образ как «надетый»
  Future<void> markAsWorn(String id) async {
    try {
      final result = await _apiService.markAsWorn(id);

      final outfits = List<SavedOutfit>.from(state.outfits);
      final index = outfits.indexWhere((o) => o.id == id);
      if (index != -1) {
        outfits[index] = outfits[index].copyWith(
          timesWorn: result['times_worn'] as int? ?? outfits[index].timesWorn,
          lastWornAt: result['last_worn_at'] != null
              ? DateTime.parse(result['last_worn_at'] as String)
              : outfits[index].lastWornAt,
        );
        state = state.copyWith(outfits: outfits);
      }
    } catch (e) {
      state = state.copyWith(error: _extractErrorMessage(e));
      rethrow;
    }
  }

  /// Переключить избранное
  Future<void> toggleFavorite(String id) async {
    final outfits = List<SavedOutfit>.from(state.outfits);
    final index = outfits.indexWhere((o) => o.id == id);
    if (index == -1) return;

    final current = outfits[index];
    final newFavorite = !current.isFavorite;

    // Оптимистичное обновление
    outfits[index] = current.copyWith(isFavorite: newFavorite);
    state = state.copyWith(outfits: outfits);

    try {
      await _apiService.updateOutfit(
        id,
        SavedOutfitUpdateRequest(isFavorite: newFavorite),
      );
    } catch (e) {
      // Откат при ошибке
      outfits[index] = current;
      state = state.copyWith(outfits: outfits);
    }
  }

  /// Перезагрузить данные
  Future<void> refresh() async {
    await _loadOutfits();
  }

  bool _isAuthError(Object error) {
    if (error is UnauthorizedException) return true;
    if (error is OutfitApiException) {
      final msg = error.message.toLowerCase();
      return msg.contains('авторизац') || msg.contains('auth');
    }
    return false;
  }
}

/// Провайдер для получения отфильтрованных образов по дате
final outfitsForDateProvider = Provider.family<List<SavedOutfit>, DateTime>((
  ref,
  date,
) {
  final state = ref.watch(outfitProvider);
  return state.getOutfitsForDate(date);
});

/// Извлечь человекочитаемое сообщение из любого исключения
String _extractErrorMessage(Object error) {
  if (error is OutfitApiException) return error.message;
  if (error is UnauthorizedException) return 'Требуется авторизация';
  if (error is DioException) return error.message ?? error.type.name;
  if (error is FormatException) return error.message;
  if (error is TypeError) return 'Ошибка типа данных';
  try {
    final s = error.toString();
    if (s.startsWith('Instance of')) {
      return error.runtimeType.toString();
    }
    return s;
  } catch (_) {
    return 'Неизвестная ошибка';
  }
}
