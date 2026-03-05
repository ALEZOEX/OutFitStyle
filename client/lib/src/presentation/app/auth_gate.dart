import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routing/router.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../providers/auth_provider.dart';

/// AuthGate контролирует startup flow приложения
///
/// Flow:
/// 1. При старте вызывается refresh (1 раз)
/// 2. Если refresh 200 → сохраняем access в память → запускаем загрузку данных
/// 3. Если refresh 401 → НЕ считаем ошибкой → показываем login screen
/// 4. Notifications polling запускаем только когда access token != null
class AuthGate extends ConsumerWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AuthGateInitializer(
      ref: ref,
      child: child,
    );
  }
}

class _AuthGateInitializer extends StatefulWidget {
  final Widget child;
  final WidgetRef ref;

  const _AuthGateInitializer({required this.child, required this.ref});

  @override
  State<_AuthGateInitializer> createState() => _AuthGateInitializerState();
}

class _AuthGateInitializerState extends State<_AuthGateInitializer> {
  bool _isInitialized = false;
  bool _isRefreshed = false;

  @override
  void initState() {
    super.initState();
    // Откладываем инициализацию до следующего кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  Future<void> _initializeAuth() async {
    // Проверяем, не инициализировали ли уже
    if (!mounted || _isRefreshed) return;

    print('[AuthGate] Инициализация...');

    try {
      // Используем widget.ref — он доступен в initState!
      final authRepo = widget.ref.read(authRepositoryProvider);
      final refreshed = await authRepo.refreshToken();

      if (refreshed) {
        print('[AuthGate] Refresh успешен — access token обновлён');

        // Обновляем состояние авторизации
        final authStateNotifier = widget.ref.read(authStateProvider.notifier);
        await authStateNotifier.checkAuth();

        // Уведомляем роутер
        final refreshStream = widget.ref.read(goRouterRefreshProvider);
        refreshStream.notifyAuthChanged();

        // Запускаем загрузку данных и polling только если авторизованы
        _startDataLoading();
      } else {
        print('[AuthGate] Refresh не удался (пользователь не авторизован)');
        // НЕ считаем это ошибкой — просто показываем login screen
      }
    } catch (e) {
      print('[AuthGate] Ошибка при refresh: $e');
      // НЕ считаем это ошибкой — просто показываем login screen
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isRefreshed = true;
        });
      }
    }
  }

  void _startDataLoading() {
    print('[AuthGate] Запуск загрузки данных...');

    // Загружаем уведомления
    final notificationsNotifier = widget.ref.read(notificationsProvider.notifier);
    notificationsNotifier.loadNotifications(refresh: true);

    // Запускаем polling
    notificationsNotifier.startPolling();
  }

  @override
  Widget build(BuildContext context) {
    // Показывем loading пока не инициализировались
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Показываем основное приложение
    return widget.child;
  }

  @override
  void dispose() {
    // Останавливаем polling при уничтожении
    if (_isInitialized) {
      final notificationsNotifier = widget.ref.read(notificationsProvider.notifier);
      notificationsNotifier.stopPolling();
    }
    super.dispose();
  }
}
