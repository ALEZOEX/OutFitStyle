import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'analytics_event.dart';
import 'local_analytics_database.dart';

/// Сервис для локального логирования аналитических событий и их отправки при восстановлении соединения
class LocalAnalyticsService {
  final LocalAnalyticsStorage _storage;
  final Dio _dio;
  final Connectivity _connectivity;

  LocalAnalyticsService({
    LocalAnalyticsStorage? storage,
    required Dio dio,
    Connectivity? connectivity,
  })  : _storage = storage ?? LocalAnalyticsStorage(),
        _dio = dio,
        _connectivity = connectivity ?? Connectivity();

  /// Сохранить событие в локальное хранилище
  Future<void> logEvent(AnalyticsEvent event) async {
    try {
      await _storage.addEvent(
        eventType: event.type.value,
        properties: event.properties,
        timestamp: event.timestamp ?? DateTime.now(),
        userId: event.userId,
      );
      // Проверяем подключение и пробуем отправить события
      await _trySendStoredEvents();
    } catch (e) {
      debugPrint('Local Analytics Service Error: ${e.toString()}');
    }
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
