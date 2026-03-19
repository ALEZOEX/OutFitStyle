import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'analytics_event.dart';
import 'analytics_service.dart';

/// Реализация сервиса аналитики с использованием Firebase Analytics
class FirebaseAnalyticsService implements IAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  String? _userId;

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    try {
      await _analytics.logEvent(
        name: event.type.value,
        parameters: _convertParameters(event.properties),
      );
    } catch (e) {
      // Логируем ошибку, но не прерываем выполнение
      debugPrint('Firebase Analytics Error: ${e.toString()}');
    }
  }

  @override
  Future<void> logEventSimple(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters != null ? _convertParameters(parameters) : null,
      );
    } catch (e) {
      debugPrint('Firebase Analytics Error: ${e.toString()}');
    }
  }

  @override
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Firebase Analytics Error: ${e.toString()}');
    }
  }

  @override
  Future<void> logError(String error, {String? stackTrace}) async {
    try {
      await _analytics.logEvent(
        name: 'error',
        parameters: {'error_message': error, 'stack_trace': stackTrace ?? ''},
      );
    } catch (e) {
      debugPrint('Firebase Analytics Error: ${e.toString()}');
    }
  }

  @override
  Future<void> logException(Exception exception, {String? stackTrace}) async {
    try {
      await _analytics.logEvent(
        name: 'exception',
        parameters: {
          'exception_type': exception.runtimeType.toString(),
          'exception_message': exception.toString(),
          'stack_trace': stackTrace ?? '',
        },
      );
    } catch (e) {
      debugPrint('Firebase Analytics Error: ${e.toString()}');
    }
  }

  @override
  Future<void> logPurchase({
    required double amount,
    required String currency,
    String? itemId,
    String? itemName,
  }) async {
    try {
      await _analytics.logPurchase(
        currency: currency,
        value: amount,
        items: itemId != null ? [AnalyticsEventItem(itemId: itemId)] : [],
      );
    } catch (e) {
      debugPrint('Firebase Analytics Error: ${e.toString()}');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      _userId = userId;
      await _analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('Firebase Analytics Error: ${e.toString()}');
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Firebase Analytics Error: ${e.toString()}');
    }
  }

  @override
  String? getUserId() {
    return _userId;
  }

  @override
  Future<void> dispose() async {
    // Firebase Analytics не требует специального освобождения ресурсов
  }

  /// Конвертирует параметры в формат, поддерживаемый Firebase Analytics
  Map<String, Object> _convertParameters(Map<String, dynamic> parameters) {
    final converted = <String, Object>{};

    for (final entry in parameters.entries) {
      final key = entry.key;
      final value = entry.value;

      // Firebase Analytics поддерживает только определенные типы данных
      if (value is String || value is int || value is double || value is bool) {
        converted[key] = value;
      } else if (value is List<String>) {
        // Firebase Analytics поддерживает списки строк
        converted[key] = value.join(',');
      } else if (value is Map<String, dynamic>) {
        // Для вложенных объектов конвертируем в JSON строку
        converted[key] = _mapToJson(value);
      } else {
        // Для других типов конвертируем в строку
        converted[key] = value.toString();
      }
    }

    return converted;
  }

  /// Конвертирует Map в JSON строку
  String _mapToJson(Map<String, dynamic> map) {
    final jsonParts = <String>[];
    map.forEach((key, value) {
      final valueStr = value is String ? '"$value"' : value.toString();
      jsonParts.add('"$key":$valueStr');
    });
    return '{${jsonParts.join(',')}}';
  }
}
