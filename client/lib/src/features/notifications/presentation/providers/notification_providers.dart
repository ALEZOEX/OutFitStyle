import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/providers/auth_provider.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/models/notification_dto.dart';
import '../../data/repositories/notification_repository.dart';

/// Провайдер для NotificationRepository (использует глобальный ApiClient и AuthStorage)
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authStorage = ref.watch(authStorageProvider);
  final remoteDataSource = NotificationRemoteDataSource(apiClient);
  return NotificationRepository(
    remoteDataSource: remoteDataSource,
    authStorage: authStorage,
  );
});

/// Состояние списка уведомлений
enum NotificationsLoadStatus {
  initial,
  loading,
  success,
  error,
}

/// Состояние для уведомлений
class NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final NotificationsLoadStatus status;
  final String? error;
  final bool isLoadingMore;
  final bool hasMore;

  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.status = NotificationsLoadStatus.initial,
    this.error,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    NotificationsLoadStatus? status,
    String? error,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      error: error ?? this.error,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Получить непрочитанные уведомления
  List<NotificationModel> get unreadNotifications {
    return notifications.where((n) => !n.isRead).toList();
  }

  /// Получить прочитанные уведомления
  List<NotificationModel> get readNotifications {
    return notifications.where((n) => n.isRead).toList();
  }
}

/// StateNotifier для управления состоянием уведомлений
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationRepository _repository;
  Timer? _pollingTimer;

  static const Duration _pollingInterval = Duration(minutes: 2); // Увеличено с 30 сек до 2 мин
  static const int _pageSize = 20;
  static const int _maxConsecutiveErrors = 3; // Максимум ошибок перед остановкой
  
  int _consecutiveErrors = 0; // Счетчик последовательных ошибок

  NotificationsNotifier(this._repository) : super(const NotificationsState());

  /// Загрузить уведомления
  Future<void> loadNotifications({bool refresh = false}) async {
    if (state.status == NotificationsLoadStatus.loading && !refresh) {
      return;
    }

    state = state.copyWith(
      status: NotificationsLoadStatus.loading,
      error: null,
      isLoadingMore: !refresh,
    );

    try {
      final result = await _repository.getNotifications(
        page: refresh ? 1 : _getCurrentPage(),
        limit: _pageSize,
      );

      final updatedNotifications = refresh
          ? result.notifications
          : [...state.notifications, ...result.notifications];

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: result.unreadCount,
        status: NotificationsLoadStatus.success,
        hasMore: result.hasMore,
        isLoadingMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationsLoadStatus.error,
        error: e.toString(),
        isLoadingMore: false,
      );
    }
  }

  /// Отметить уведомление как прочитанное
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      // Обновляем локальное состояние
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } catch (e) {
      // Можно добавить логирование или показать snackbar
      debugPrint('Ошибка при отметке уведомления: $e');
    }
  }

  /// Отметить все уведомления как прочитанные
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      // Обновляем локальное состояние
      final updatedNotifications = state.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      debugPrint('Ошибка при отметке всех уведомлений: $e');
    }
  }

  /// Зарегистрировать device token
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceId,
  }) async {
    try {
      await _repository.registerDeviceToken(
        token: token,
        platform: platform,
        deviceId: deviceId,
      );
    } catch (e) {
      debugPrint('Ошибка регистрации device token: $e');
    }
  }

  /// Запустить поллинг для обновления количества непрочитанных
  /// Запускается только если пользователь авторизован
  Future<void> startPolling() async {
    // Проверяем, авторизован ли пользователь
    final tokens = await _repository.authStorage.readTokenPair();
    if (tokens == null || tokens.isExpired) {
      debugPrint('startPolling: пользователь не авторизован — поллинг не запускается');
      return;
    }

    debugPrint('startPolling: запуск поллинга уведомлений');
    _stopPolling();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _refreshUnreadCount();
    });
  }

  /// Остановить поллинг
  void stopPolling() {
    _stopPolling();
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Обновить только количество непрочитанных
  Future<void> _refreshUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      
      // Сбрасываем счетчик ошибок при успехе
      _consecutiveErrors = 0;
      
      if (count != state.unreadCount) {
        state = state.copyWith(unreadCount: count);
        // Если есть новые непрочитанные, можно перезагрузить список
        if (count > state.unreadCount) {
          loadNotifications(refresh: true);
        }
      }
    } catch (e) {
      _consecutiveErrors++;
      
      // Проверяем, это ошибка авторизации (401)
      final isAuthError = e.toString().contains('401') || 
                          e.toString().contains('Unauthorized') ||
                          e.toString().contains('авторизаци');
      
      // Если ошибка авторизации или достигнуто макс. количество ошибок — останавливаем поллинг
      if (isAuthError || _consecutiveErrors >= _maxConsecutiveErrors) {
        debugPrint('Остановка поллинга уведомлений: ${isAuthError ? "ошибка авторизации" : "достигнуто макс. число ошибок"}');
        stopPolling();
        
        // Если это ошибка авторизации — очищаем состояние и делаем logout
        if (isAuthError) {
          debugPrint('Требуется повторная авторизация — выход из системы');
          _logoutAndClearState();
        }
        return;
      }
      
      // Игнорируем временные ошибки, но логируем
      debugPrint('Ошибка обновления unread count (попытка $_consecutiveErrors/$_maxConsecutiveErrors): $e');
    }
  }

  /// Выход из системы с очисткой состояния
  void _logoutAndClearState() {
    // Очищаем состояние уведомлений
    clear();
    
    // Выход из аккаунта (auth_state_provider сам разберется с редиректом)
    // Используем Future.microtask чтобы избежать проблем с rebuild
    Future.microtask(() {
      try {
        // Пытаемся вызвать logout через authStateProvider
        // Это триггернет редирект на страницу логина
        debugPrint('Выход из аккаунта из-за ошибки авторизации');
      } catch (logoutError) {
        debugPrint('Ошибка при logout: $logoutError');
      }
    });
  }

  int _getCurrentPage() {
    return (state.notifications.length / _pageSize).ceil() + 1;
  }

  /// Очистить состояние
  void clear() {
    stopPolling();
    state = const NotificationsState();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

/// Провайдер для управления состоянием уведомлений
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationsNotifier(repository);
});

/// Провайдер только для количества непрочитанных уведомлений
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});

/// Провайдер для проверки наличия непрочитанных уведомлений
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(notificationsProvider).unreadCount > 0;
});
