import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/session_provider.dart';

/// Обёртка для защиты маршрутов, требующих аутентификации
///
/// Если пользователь не авторизован, показывает экран загрузки.
/// Если авторизован — показывает дочерний виджет.
class AuthWrapper extends ConsumerWidget {
  final Widget child;
  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (isAuthenticated) {
        if (!isAuthenticated) {
          return const Scaffold(
            body: Center(child: Text('Требуется авторизация')),
          );
        }
        return child;
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) =>
              Scaffold(body: Center(child: Text('Ошибка авторизации: $error'))),
    );
  }
}
