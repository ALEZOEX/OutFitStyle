// Определение всех маршрутов приложения
part of 'app_navigation.dart';

final List<RouteBase> $appRoutes = [
  GoRoute(
    path: '/',
    name: 'home',
    builder: (context, state) => const HomeScreen(),
    routes: [
      GoRoute(
        path: 'profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: 'settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: 'outfit',
        name: 'outfit',
        builder: (context, state) => const WeatherOutfitScreen(),
      ),
      GoRoute(
        path: 'recommendations',
        name: 'recommendations',
        builder: (context, state) => const RecommendationsScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            name: 'recommendation-detail',
            builder: (context, state) {
              final recommendation = state.extra as Recommendation?;
              if (recommendation == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Ошибка: Данные рекомендации отсутствуют'),
                  ),
                );
              }
              return RecommendationDetailScreen(recommendation: recommendation);
            },
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: '/auth',
    name: 'auth',
    builder: (context, state) => const OnboardingScreen(),
    routes: [
      GoRoute(
        path: 'login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: 'register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  ),
];
