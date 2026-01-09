import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/wardrobe/presentation/wardrobe_screen.dart';
import '../features/generator/presentation/generator_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/outfit_details/presentation/outfit_details_screen.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/onboarding/presentation/onboarding_wizard_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/achievements/presentation/achievements_screen.dart';
import 'widgets/tab_swipe_container.dart';
import 'di.dart';
import 'onboarding/onboarding_providers.dart';

final _homeNavKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _wardrobeNavKey = GlobalKey<NavigatorState>(debugLabel: 'wardrobeNav');
final _generatorNavKey = GlobalKey<NavigatorState>(debugLabel: 'generatorNav');
final _profileNavKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);
  // onboarding done читаем асинхронно: делаем provider
  final onboardingDone = ref.watch(onboardingDoneProvider);

  return GoRouter(
    initialLocation: '/auth', // Изменили начальный маршрут на аутентификацию
    redirect: (context, state) {
      final loc = state.matchedLocation;

      final goingAuth = loc.startsWith('/auth');
      final goingOnboarding = loc.startsWith('/onboarding');

      // пока не знаем — не редиректим
      if (session == SessionStatus.unknown || onboardingDone.isLoading) {
        // Если состояние неизвестно, направляем на аутентификацию
        if (!goingAuth) return '/auth';
        return null;
      }

      final isAuthed = session == SessionStatus.authed;
      final done = onboardingDone.value ?? false;

      if (!isAuthed) {
        return goingAuth ? null : '/auth';
      }

      // залогинен, но онбординг не пройден
      if (!done) {
        return goingOnboarding ? null : '/onboarding';
      }

      // залогинен и онбординг пройден
      if (goingAuth || goingOnboarding) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingWizardScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _AppScaffold(shell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/wardrobe', builder: (_, __) => const WardrobeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/generator', builder: (_, __) => const GeneratorScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
                routes: [
                  GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/outfit/:id',
        builder: (_, state) => OutfitDetailsScreen(outfitId: state.pathParameters['id']!),
      ),
    ],
  );
});

class _AppScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _AppScaffold({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Домой'),
          NavigationDestination(icon: Icon(Icons.checkroom_rounded), label: 'Шкаф'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_rounded), label: 'Подбор'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профиль'),
        ],
      ),
    );
  }
}