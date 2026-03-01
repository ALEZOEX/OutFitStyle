import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/di.dart';
import '../onboarding/onboarding_storage.dart' as onboarding_storage;
import 'package:outfitstyle_client/src/services/auth_storage.dart';

/// Провайдер для отслеживания состояния проверки onboarding
final splashInitProvider = FutureProvider<String>((ref) async {
  // Проверяем, пройден ли onboarding
  final storage = onboarding_storage.OnboardingStorage();
  final onboardingDone = await storage.isDone();

  // Обновляем состояние в ди через update метод
  final notifier = ref.read(onboardingDoneProvider.notifier);
  notifier.updateState(onboardingDone);

  // Проверяем авторизацию напрямую через токен
  final authStorage = AuthStorage();
  final token = await authStorage.readAccessToken();
  final isAuthenticated = token != null && token.isNotEmpty;
  
  // Возвращаем маршрут для редиректа
  if (!onboardingDone) {
    return '/onboarding';
  } else if (isAuthenticated) {
    return '/home';
  } else {
    return '/auth';
  }
});

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Слушаем завершение инициализации и делаем редирект
    ref.watch(splashInitProvider).whenData((route) {
      // Редирект на нужный экран (используем async gap - context может быть неактивен)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(route);
        }
      });
    });
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.checkroom,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              // Название приложения
              Text(
                'OutfitStyle',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 48),
              // Индикатор загрузки
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Загрузка...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
