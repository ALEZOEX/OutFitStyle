import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_shell.dart';
import '../../features/wardrobe/presentation/wardrobe_screen.dart';
import '../../features/recommendations/presentation/recommendations_screen.dart';
import '../../features/recommendations/presentation/screens/outfit_planner_screen.dart';
import '../../features/recommendations/presentation/screens/outfit_builder_screen.dart';
import '../../features/recommendations/presentation/screens/recommendation_detail_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_item_detail_screen.dart';
import '../../features/wardrobe/presentation/screens/add_wardrobe_item_screen.dart';
import '../../features/generator/presentation/generator_screen.dart';
import '../../features/settings/presentation/screens/profile_settings_screen.dart';
import '../../features/settings/presentation/screens/preferences_screen.dart';
import '../../features/settings/presentation/screens/security_screen.dart';
import '../../features/settings/presentation/screens/language_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_screen.dart';
import '../../features/achievements/presentation/pages/achievements_page.dart';
import '../../features/achievements/presentation/pages/achievement_detail_page.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/onboarding_providers.dart' as onboarding_providers;
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/admin_user_detail_page.dart';
import '../../features/outfit_details/presentation/outfit_details_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateCompatProvider);
  final onboardingDone = ref.watch(onboarding_providers.isOnboardingDoneProvider);
  final isAdminAsync = ref.watch(adminAccessProvider);
  final refreshListenable = ref.watch(goRouterRefreshProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (BuildContext context, GoRouterState state) {
      final path = state.uri.toString();

      // Splash экран - всегда разрешаем
      if (path == '/splash') {
        return null;
      }

      // Если загрузка состояния - не редиректим кроме splash
      if (authState.isLoading) {
        return '/splash';
      }

      // 1. Если onboarding не пройден - показываем onboarding (кроме splash)
      if (!onboardingDone && path != '/onboarding') {
        return '/onboarding';
      }

      // Онбординг - разрешаем доступ только если не пройден
      if (path.startsWith('/onboarding')) {
        if (onboardingDone) {
          // Если уже пройден, редиректим на home или auth
          return authState.isAuthenticated ? '/home' : '/auth';
        }
        return null;
      }

      // 2. Если не авторизован - показываем auth
      if (path.startsWith('/auth')) {
        if (authState.isAuthenticated) {
          return '/home';
        }
        return null;
      }

      // Восстановление пароля доступно без авторизации
      if (path == '/forgot-password') {
        return null;
      }

      // Проверка доступа к админ-панели
      if (path.startsWith('/admin')) {
        // Если не авторизован - редирект на auth
        if (!authState.isAuthenticated) {
          return '/auth?redirect=/admin';
        }
        // Проверяем роль администратора
        final isAdmin = isAdminAsync.valueOrNull ?? false;
        if (!isAdmin) {
          return '/home'; // или специальная страница "доступ запрещён"
        }
      }

      // Авторизация не нужна для splash и onboarding
      if (path == '/splash' || path == '/onboarding') {
        return null;
      }

      // 3. Для всех остальных маршрутов проверяем авторизацию
      if (!authState.isAuthenticated) {
        return '/auth';
      }

      return null;
    },
    routes: [
      // Splash экран - начальная точка
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Корневой маршрут - редирект на splash
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),
      // Онбординг
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) {
          return OnboardingScreen(
            onComplete: () async {
              // Флаг уже установлен в onboardingNotifier
              if (!context.mounted) return;
              // После онбординга переходим на авторизацию
              context.go('/auth');
            },
          );
        },
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      // Восстановление пароля
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Экран заполнения профиля (после регистрации через Google)
      GoRoute(
        path: '/complete-profile',
        name: 'complete_profile',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          final name = extra?['name'] as String?;
          return CompleteProfileScreen(
            email: email,
            googleName: name,
          );
        },
      ),
      // Главный экран с shell навигацией
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeShellWrapper(),
      ),
      // Гардероб
      GoRoute(
        path: '/wardrobe',
        name: 'wardrobe',
        builder: (context, state) => const WardrobeScreen(),
      ),
      GoRoute(
        path: '/wardrobe/add',
        name: 'wardrobe_add',
        builder: (context, state) => const AddWardrobeItemScreen(),
      ),
      GoRoute(
        path: '/wardrobe/item/:id',
        name: 'wardrobe_item_detail',
        builder: (context, state) => WardrobeItemDetailScreen(
          itemId: state.pathParameters['id']!,
        ),
      ),
      // Рекомендации
      GoRoute(
        path: '/recommendations',
        name: 'recommendations',
        builder: (context, state) => const RecommendationsScreen(),
      ),
      GoRoute(
        path: '/recommendations/:id',
        name: 'recommendation_detail',
        builder: (context, state) => RecommendationDetailScreen(
          recommendationId: state.pathParameters['id']!,
        ),
      ),
      // Планировщик образов
      GoRoute(
        path: '/recommendations/planner',
        name: 'outfit_planner',
        builder: (context, state) {
          final recommendationId = state.extra as String?;
          return OutfitPlannerScreen(
            initialRecommendationId: recommendationId,
          );
        },
      ),
      // Конструктор образов
      GoRoute(
        path: '/recommendations/builder',
        name: 'outfit_builder',
        builder: (context, state) => const OutfitBuilderScreen(),
      ),
      // Профиль
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // Настройки
      GoRoute(
        path: '/settings/profile',
        name: 'profile_settings',
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/preferences',
        name: 'preferences',
        builder: (context, state) => const PreferencesScreen(),
      ),
      // Безопасность
      GoRoute(
        path: '/settings/security',
        name: 'security',
        builder: (context, state) => const SecurityScreen(),
      ),
      // Язык
      GoRoute(
        path: '/settings/language',
        name: 'language',
        builder: (context, state) => const LanguageScreen(),
      ),
      // О приложении
      GoRoute(
        path: '/settings/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      // Настройки уведомлений
      GoRoute(
        path: '/settings/notifications',
        name: 'notification_settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      // Конфиденциальность
      GoRoute(
        path: '/settings/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      // Достижения
      GoRoute(
        path: '/achievements',
        name: 'achievements',
        builder: (context, state) => const AchievementsPage(),
      ),
      // Детали достижения
      GoRoute(
        path: '/achievements/:id',
        name: 'achievement_detail',
        builder: (context, state) => AchievementDetailPage(
          achievementId: state.pathParameters['id']!,
        ),
      ),
      // Generator
      GoRoute(
        path: '/generator',
        name: 'generator',
        builder: (context, state) => const GeneratorScreen(),
      ),
      // Outfit details
      GoRoute(
        path: '/outfit/:id',
        name: 'outfit_detail',
        builder: (context, state) => OutfitDetailsScreen(
          outfitId: state.pathParameters['id']!,
        ),
      ),
      // Admin - Dashboard
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      // Admin - Users
      GoRoute(
        path: '/admin/users',
        name: 'admin_users',
        builder: (context, state) => const AdminUsersPage(),
      ),
      // Admin - User Detail
      GoRoute(
        path: '/admin/users/:id',
        name: 'admin_user_detail',
        builder: (context, state) => AdminUserDetailPage(
          userId: state.pathParameters['id']!,
        ),
      ),
      // Уведомления
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
});

/// Утилита для обновления роутера при изменении состояния авторизации
/// Используется ChangeNotifierProvider для уведомления роутера
final goRouterRefreshProvider = ChangeNotifierProvider((ref) {
  final notifier = GoRouterRefreshStream();

  // Слушаем изменения authState и уведомляем роутер
  ref.listen<AuthState>(authStateCompatProvider, (prev, next) {
    notifier.notifyAuthChanged();
  });

  return notifier;
});

class GoRouterRefreshStream extends ChangeNotifier {
  void notifyAuthChanged() {
    notifyListeners();
  }
}
