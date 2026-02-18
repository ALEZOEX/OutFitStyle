import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/wardrobe/presentation/wardrobe_screen.dart';
import '../../features/recommendations/presentation/recommendations_screen.dart';
import '../../features/recommendations/presentation/screens/recommendation_detail_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_item_detail_screen.dart';
import '../../features/generator/presentation/generator_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/onboarding_storage.dart' as onboarding_storage;
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/wardrobe/presentation/screens/add_wardrobe_item_screen.dart';
import '../../features/outfit_details/presentation/outfit_details_screen.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../../services/auth_storage.dart';

/// Провайдер для AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authStorage = AuthStorage();
  final apiClient = ApiClient(storage: authStorage);
  final config = ApiConfig(apiBase: ApiConfig.baseUrl);
  return AuthRepository(config, authStorage, apiClient);
});

/// Провайдер для получения userId пользователя
final userIdProvider = FutureProvider<String?>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  return authRepo.getUserId();
});

/// Провайдер состояния авторизации
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.read(authRepositoryProvider));
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthStateNotifier(this._authRepository) : super(const AuthState.loading());

  Future<void> checkAuth() async {
    state = const AuthState.loading();
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      state = isLoggedIn ? const AuthState.authenticated() : const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }
}

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;

  const AuthState._({required this.isLoading, required this.isAuthenticated});
  const AuthState.loading() : this._(isLoading: true, isAuthenticated: false);
  const AuthState.authenticated() : this._(isLoading: false, isAuthenticated: true);
  const AuthState.unauthenticated() : this._(isLoading: false, isAuthenticated: false);
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshStream = ref.watch(goRouterRefreshProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshStream,
    redirect: (BuildContext context, GoRouterState state) async {
      final path = state.uri.toString();
      final authState = ref.read(authStateProvider);

      // Корневой маршрут
      if (path == '/') {
        // Если загрузка, ждём
        if (authState.isLoading) {
          return null;
        }

        // Проверяем онбординг
        final onboardingStorage = onboarding_storage.OnboardingStorage();
        final onboardingDone = await onboardingStorage.isDone();

        if (!onboardingDone) {
          return '/onboarding';
        }

        // Проверяем авторизацию
        if (!authState.isAuthenticated) {
          return '/auth';
        }

        // Всё ок - идём на home
        return '/home';
      }

      // Онбординг
      if (path.startsWith('/onboarding')) {
        // Если уже прошли онбординг и авторизованы - на home
        final onboardingStorage = onboarding_storage.OnboardingStorage();
        final onboardingDone = await onboardingStorage.isDone();

        if (onboardingDone && authState.isAuthenticated) {
          return '/home';
        }
        return null;
      }

      // Авторизация
      if (path.startsWith('/auth')) {
        // Если уже авторизован - на home
        if (authState.isAuthenticated) {
          return '/home';
        }
        return null;
      }

      // Для всех остальных маршрутов проверяем авторизацию
      if (!authState.isAuthenticated) {
        return '/auth';
      }

      return null;
    },
    routes: [
      // Корневой маршрут - теперь redirect обрабатывает логику
      GoRoute(
        path: '/',
        redirect: (context, state) => null, // redirect выше обрабатывает
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) {
          final onboardingStorage = onboarding_storage.OnboardingStorage();
          return OnboardingScreen(
            onComplete: () async {
              await onboardingStorage.setDone();
              if (!context.mounted) return;
              context.go('/home');
            },
          );
        },
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'wardrobe',
            name: 'wardrobe',
            builder: (context, state) => const WardrobeScreen(),
          ),
          GoRoute(
            path: 'recommendations',
            name: 'recommendations',
            builder: (context, state) => const RecommendationsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'recommendation-detail',
                builder: (context, state) => RecommendationDetailScreen(
                  recommendationId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'generator',
            name: 'generator',
            builder: (context, state) => const GeneratorScreen(),
          ),
          GoRoute(
            path: 'outfit/:id',
            name: 'outfit-details',
            builder: (context, state) => OutfitDetailsScreen(
              outfitId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/wardrobe',
        name: 'wardrobe-root',
        builder: (context, state) => const WardrobeScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'wardrobe-add',
            builder: (context, state) => const AddWardrobeItemScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'wardrobe-item-detail',
            builder: (context, state) => WardrobeItemDetailScreen(
              itemId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'admin',
            name: 'admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Утилита для обновления роутера при изменении состояния авторизации
/// Используется ChangeNotifierProvider для уведомления роутера
final goRouterRefreshProvider = ChangeNotifierProvider((ref) {
  return GoRouterRefreshStream();
});

class GoRouterRefreshStream extends ChangeNotifier {
  void notifyAuthChanged() {
    notifyListeners();
  }
}
