import 'analytics_event.dart';
import 'analytics_service.dart';
import 'firebase_analytics_service.dart';
import 'local_analytics_service.dart';

/// Комбинированный сервис аналитики, который использует Firebase Analytics и локальное хранилище
class CombinedAnalyticsService implements AnalyticsService {
  final FirebaseAnalyticsService _firebaseService;
  final LocalAnalyticsService _localService;

  String? _currentUserId;

  CombinedAnalyticsService({
    required FirebaseAnalyticsService firebaseService,
    required LocalAnalyticsService localService,
  })  : _firebaseService = firebaseService,
        _localService = localService;

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    // Устанавливаем userId в событии, если он не установлен
    final eventWithUserId =
        event.userId != null ? event : event.copyWith(userId: _currentUserId);

    try {
      // Отправляем событие в Firebase Analytics
      await _firebaseService.logEvent(eventWithUserId);
    } catch (e) {
      // Если не удалось отправить в Firebase, сохраняем локально
      await _localService.logEvent(eventWithUserId);
    }
  }

  @override
  Future<void> logEventSimple(String eventName,
      {Map<String, dynamic>? parameters}) async {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.values.firstWhere(
        (element) => element.value == eventName,
        orElse: () => AnalyticsEventType.settingsUpdate, // fallback
      ),
      properties: parameters ?? {},
      userId: _currentUserId,
      timestamp: DateTime.now(),
    );

    await logEvent(event);
  }

  @override
  Future<void> logScreenView(String screenName) async {
    try {
      await _firebaseService.logScreenView(screenName);
    } catch (e) {
      // Если не удалось отправить в Firebase, создаем локальное событие
      final event = AnalyticsEvent(
        type: AnalyticsEventType.settingsUpdate, // используем подходящий тип
        properties: {'screen_name': screenName},
        userId: _currentUserId,
        timestamp: DateTime.now(),
      );
      await _localService.logEvent(event);
    }
  }

  @override
  Future<void> logError(String error, {String? stackTrace}) async {
    try {
      await _firebaseService.logError(error, stackTrace: stackTrace);
    } catch (e) {
      final event = AnalyticsEvent(
        type: AnalyticsEventType
            .settingsUpdate, // используем подходящий тип для ошибки
        properties: {
          'error': error,
          if (stackTrace != null) 'stack_trace': stackTrace,
        },
        userId: _currentUserId,
        timestamp: DateTime.now(),
      );
      await _localService.logEvent(event);
    }
  }

  @override
  Future<void> logException(Exception exception, {String? stackTrace}) async {
    try {
      await _firebaseService.logException(exception, stackTrace: stackTrace);
    } catch (e) {
      final event = AnalyticsEvent(
        type: AnalyticsEventType
            .settingsUpdate, // используем подходящий тип для исключения
        properties: {
          'exception_type': exception.runtimeType.toString(),
          'exception_message': exception.toString(),
          if (stackTrace != null) 'stack_trace': stackTrace,
        },
        userId: _currentUserId,
        timestamp: DateTime.now(),
      );
      await _localService.logEvent(event);
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
      await _firebaseService.logPurchase(
        amount: amount,
        currency: currency,
        itemId: itemId,
        itemName: itemName,
      );
    } catch (e) {
      final event = AnalyticsEvent(
        type: AnalyticsEventType
            .settingsUpdate, // используем подходящий тип для покупки
        properties: {
          'amount': amount,
          'currency': currency,
          if (itemId != null) 'item_id': itemId,
          if (itemName != null) 'item_name': itemName,
        },
        userId: _currentUserId,
        timestamp: DateTime.now(),
      );
      await _localService.logEvent(event);
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    _currentUserId = userId;
    await _firebaseService.setUserId(userId);
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    await _firebaseService.setUserProperty(name, value);
  }

  @override
  String? getUserId() {
    return _currentUserId;
  }

  @override
  Future<void> dispose() async {
    await _firebaseService.dispose();
  }

  /// Синхронизировать локальные события
  Future<void> syncLocalEvents() async {
    await _localService.syncEvents();
  }

  /// Получить количество неотправленных событий
  Future<int> getUnsentEventsCount() async {
    return await _localService.getUnsentEventsCount();
  }
}
