import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../providers/session_provider.dart';

/// AuthGate контролирует startup flow приложения для Firebase Auth
///
/// Flow:
/// 1. Firebase Auth автоматически управляет сессией (refresh внутри SDK)
/// 2. Слушаем authStateChanges из SessionManager
/// 3. При авторизации → запускаем notifications polling
/// 4. При разавторизации → останавливаем polling
class AuthGate extends ConsumerStatefulWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _isInitialized = false;
  bool _isAuthenticated = false;
  StreamSubscription<bool>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Откладываем инициализацию до следующего кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  Future<void> _initializeAuth() async {
    if (!mounted || _isInitialized) return;

    print('[AuthGate] Инициализация...');

    try {
      // Получаем SessionManager
      final sessionManager = ref.read(sessionManagerProvider);

      // СНАЧАЛА проверяем текущее состояние auth
      // Это важно: если пользователь уже авторизован до подписки
      final currentAuth = sessionManager.isAuthenticated;
      print('[AuthGate] Текущее состояние auth: $currentAuth');

      // Подписываемся на authStateChanges
      _authSubscription = sessionManager.authStateChanges.listen(
        (isAuthenticated) {
          if (!mounted) return;

          print('[AuthGate] Auth state changed: $isAuthenticated');
          setState(() => _isAuthenticated = isAuthenticated);

          if (isAuthenticated) {
            _startDataLoading();
          } else {
            _stopDataLoading();
          }
        },
        onError: (error) {
          print('[AuthGate] Ошибка auth stream: $error');
        },
        onDone: () {
          print('[AuthGate] Auth stream closed');
        },
      );

      // Инициализируем состояние
      // Если уже авторизован — запускаем загрузку данных
      setState(() {
        _isAuthenticated = currentAuth;
        _isInitialized = true;
      });

      if (currentAuth) {
        print('[AuthGate] Пользователь уже авторизован, запускаем загрузку данных');
        _startDataLoading();
      }
    } catch (e) {
      print('[AuthGate] Ошибка при инициализации: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isAuthenticated = false;
        });
      }
    }
  }

  void _startDataLoading() {
    print('[AuthGate] Запуск загрузки данных...');

    // Загружаем уведомления
    try {
      final notificationsNotifier = ref.read(notificationsProvider.notifier);
      notificationsNotifier.loadNotifications(refresh: true);

      // Запускаем polling
      notificationsNotifier.startPolling();
    } catch (e) {
      print('[AuthGate] Ошибка при запуске polling: $e');
    }
  }

  void _stopDataLoading() {
    print('[AuthGate] Остановка загрузки данных...');

    // Останавливаем polling
    final notificationsNotifier = ref.read(notificationsProvider.notifier);
    notificationsNotifier.stopPolling();
  }

  @override
  Widget build(BuildContext context) {
    // Показываем loading пока не инициализировались
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Возвращаем child (основное приложение)
    // Роутер внутри child сам разберётся с auth state через GoRouter redirect
    return widget.child;
  }

  @override
  void dispose() {
    // Останавливаем polling и отменяем подписку при уничтожении
    _stopDataLoading();
    _authSubscription?.cancel();
    super.dispose();
  }
}
