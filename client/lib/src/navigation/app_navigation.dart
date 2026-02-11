import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/session_manager.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/weather_outfit_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/logger.dart';
import '../features/recommendations/recommendations_screen.dart';
import '../features/recommendations/widgets/recommendation_detail_screen.dart';
import '../domain/entities/recommendation.dart';

// Определение маршрутов приложения
part 'routes.dart';

class AppNavigation {
  late final GoRouter router;

  AppNavigation(SessionManager sessionManager) {
    router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: $appRoutes,
      redirect: (BuildContext context, GoRouterState state) {
        // Проверяем, требует ли маршрут аутентификации
        final location = state.fullPath;
        final requiresAuth = _routeRequiresAuth(location ?? '/');
        final isAuthenticated = sessionManager.isAuthenticated;

        // Если маршрут требует аутентификации, но пользователь не вошел
        if (requiresAuth && !isAuthenticated) {
          return '/login';
        }

        // Если пользователь вошел, но пытается зайти на страницу входа
        if (!requiresAuth &&
            isAuthenticated &&
            (location?.startsWith('/auth') ?? false)) {
          return '/';
        }

        return null;
      },
      observers: [CustomRouteObserver()],
    );
  }

  // Проверяет, требует ли маршрут аутентификации
  bool _routeRequiresAuth(String? location) {
    // Список маршрутов, которые не требуют аутентификации
    const publicRoutes = [
      '/',
      '/login',
      '/register',
      '/forgot-password',
      '/onboarding',
    ];

    return !publicRoutes.contains(location);
  }
}

// Кастомный observer для навигации
class CustomRouteObserver extends RouteObserver<ModalRoute<void>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Логика при переходе на новый маршрут
    AppLogger.info('Переход на маршрут: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Логика при возврате с маршрута
    AppLogger.info('Возврат с маршрута: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    // Логика при замене маршрута
    if (newRoute != null) {
      AppLogger.info('Замена маршрута на: ${newRoute.settings.name}');
    }
  }
}

// Основной виджет навигации
class AppNavigator extends StatelessWidget {
  final Widget child;

  const AppNavigator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
