import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Локальное хранилище для событий аналитики в оффлайн-режиме
class LocalAnalyticsStorage {
  static const String _storageKey = 'analytics_events_queue';

  /// Добавить событие в очередь
  Future<void> addEvent({
    required String eventType,
    required Map<String, dynamic> properties,
    required DateTime timestamp,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsQueue = await getEventsQueue();

    final event = {
      'id':
          DateTime.now().millisecondsSinceEpoch
              .toString(), // простой ID на основе времени
      'type': eventType,
      'properties': properties,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };

    eventsQueue.add(event);

    await prefs.setStringList(
      _storageKey,
      eventsQueue.map((e) => jsonEncode(e)).toList(),
    );
  }

  /// Получить все неотправленные события
  Future<List<Map<String, dynamic>>> getEventsQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final rawEvents = prefs.getStringList(_storageKey) ?? [];

    return rawEvents
        .map((str) => jsonDecode(str) as Map<String, dynamic>)
        .toList();
  }

  /// Удалить события из очереди по ID
  Future<void> removeEventsByIds(List<String> idsToRemove) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsQueue = await getEventsQueue();

    final filteredEvents =
        eventsQueue
            .where((event) => !idsToRemove.contains(event['id']))
            .toList();

    await prefs.setStringList(
      _storageKey,
      filteredEvents.map((e) => jsonEncode(e)).toList(),
    );
  }

  /// Очистить всю очередь событий
  Future<void> clearEventsQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Получить количество неотправленных событий
  Future<int> getEventsCount() async {
    final events = await getEventsQueue();
    return events.length;
  }
}
