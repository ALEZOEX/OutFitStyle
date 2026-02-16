import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'analytics_event.dart';
import 'analytics_service.dart';
import 'local_analytics_database.dart';

/// Сервис для локального логирования аналитических событий и их отправки при восстановлении соединения
class LocalAnalyticsService implements IAnalyticsService {
  final LocalAnalyticsStorage _storage;
  final Dio _dio;
  final Connectivity _connectivity;
  String? _userId;

  LocalAnalyticsService({
    LocalAnalyticsStorage? storage,
    required Dio dio,
    Connectivity? connectivity,
  })  : _storage = storage ?? LocalAnalyticsStorage(),
        _dio = dio,
        _connectivity = connectivity ?? Connectivity();

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    try {
      await _storage.addEvent(
        eventType: event.type.value,
        properties: event.properties,
        timestamp: event.timestamp ?? DateTime.now(),
        userId: event.userId ?? _userId,
      );
      // Проверяем подключение и пробуем отправить события
      await _trySendStoredEvents();
    } catch (e) {
      debugPrint('Local Analytics Service Error: ${e.toString()}');
    }
  }

  @override
  Future<void> logEventSimple(String eventName,
      {Map<String, dynamic>? parameters}) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.values.firstWhere(
        (element) => element.value == eventName,
        orElse: () => AnalyticsEventType.settingsUpdate,
      ),
      properties: parameters ?? {},
      userId: _userId,
      timestamp: DateTime.now(),
    );
    await logEvent(event);
  }

  @override
  Future<void> logScreenView(String screenName) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.settingsUpdate,
      properties: {'screen_name': screenName},
      userId: _userId,
      timestamp: DateTime.now(),
    );
    await logEvent(event);
  }

  @override
  Future<void> logError(String error, {String? stackTrace}) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.settingsUpdate,
      properties: {
        'error': error,
        if (stackTrace != null) 'stack_trace': stackTrace,
      },
      userId: _userId,
      timestamp: DateTime.now(),
    );
    await logEvent(event);
  }

  @override
  Future<void> logException(Exception exception, {String? stackTrace}) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.settingsUpdate,
      properties: {
        'exception_type': exception.runtimeType.toString(),
        'exception_message': exception.toString(),
        if (stackTrace != null) 'stack_trace': stackTrace,
      },
      userId: _userId,
      timestamp: DateTime.now(),
    );
    await logEvent(event);
  }

  @override
  Future<void> logPurchase({
    required double amount,
    required String currency,
    String? itemId,
    String? itemName,
  }) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.settingsUpdate,
      properties: {
        'amount': amount,
        'currency': currency,
        if (itemId != null) 'item_id': itemId,
        if (itemName != null) 'item_name': itemName,
      },
      userId: _userId,
      timestamp: DateTime.now(),
    );
    await logEvent(event);
  }

  @override
  Future<void> setUserId(String? userId) async {
    _userId = userId;
  }

  @override
  String? getUserId() {
    return _userId;
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    // Local analytics не поддерживает свойства пользователя
    // Можно сохранить в хранилище при необходимости
  }

  @override
  Future<void> dispose() async {
    // Освобождение ресурсов при необходимости
  }

  /// Попробовать отправить сохраненные события при наличии подключения
  Future<void> _trySendStoredEvents() async {
    final connectivityResults = await _connectivity.checkConnectivity();

    if (!connectivityResults.contains(ConnectivityResult.none)) {
      await _sendStoredEvents();
    }
  }

  /// Отправить все сохраненные события
  Future<void> _sendStoredEvents() async {
    try {
      final unsentEvents = await _storage.getEventsQueue();

      if (unsentEvents.isEmpty) {
        return;
      }

      final eventsToSync = <Map<String, dynamic>>[];
      final eventIds = <String>[];

      for (final event in unsentEvents) {
        eventsToSync.add({
          'type': event['type'],
          'properties': event['properties'],
          'timestamp': event['timestamp'],
          'userId': event['userId'],
        });
        eventIds.add(event['id']);
      }

      // Отправляем события на сервер
      try {
        await _dio.post('/api/v1/analytics/batch', data: {
          'events': eventsToSync,
        });

        // Удаляем успешно отправленные события
        await _storage.removeEventsByIds(eventIds);
      } catch (e) {
        debugPrint('Failed to send stored analytics events: ${e.toString()}');
        // Не удаляем события, если не удалось отправить
      }
    } catch (e) {
      debugPrint('Local Analytics Service Error: ${e.toString()}');
    }
  }

  /// Принудительно синхронизировать события
  Future<void> syncEvents() async {
    await _sendStoredEvents();
  }

  /// Получить количество неотправленных событий
  Future<int> getUnsentEventsCount() async {
    return await _storage.getEventsCount();
  }

  /// Очистить локальное хранилище
  Future<void> clearStorage() async {
    await _storage.clearEventsQueue();
  }
}
