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
import '../../features/onboarding/presentation/onboarding_wizard_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/wardrobe/presentation/screens/add_wardrobe_item_screen.dart';
import '../../features/outfit_details/presentation/outfit_details_screen.dart';
import '../../features/onboarding/onboarding_providers.dart' as onboarding_prov;
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

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding', // Начинаем с онбординга
    // redirect временно отключен для отладки
    // redirect: (BuildContext context, GoRouterState state) async {
    //   // Получаем статус онбординга через FutureProvider
    //   final onboardingDone = await ref.read(onboarding_prov.onboardingDoneProvider.future);

    //   // Если онбординг не пройден, перенаправляем на него
    //   if (!onboardingDone &&
    //       !state.uri.toString().startsWith('/onboarding') &&
    //       !state.uri.toString().startsWith('/auth')) {
    //     return '/onboarding';
    //   }

    //   // Проверяем сессию пользователя
    //   final userId = await ref.read(userIdProvider.future);
    //   final isAuthPath = state.uri.toString().startsWith('/auth');

    //   // Если нет сессии и пользователь пытается войти в защищённый раздел
    //   if (userId == null && !isAuthPath && onboardingDone) {
    //     return '/auth';
    //   }

    //   // Если пользователь авторизован и пытается войти на страницу авторизации
    //   if (userId != null && isAuthPath && onboardingDone) {
    //     return '/home';
    //   }

    //   return null; // Не перенаправляем, если все условия соблюдены
    // },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/onboarding',
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
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingWizardScreen(),
      ),
    ],
  );
});
