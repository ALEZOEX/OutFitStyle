import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/di.dart';
import '../../presentation/routing/router.dart';
import '../onboarding/onboarding_storage.dart' as onboarding_storage;

/// Провайдер для отслеживания состояния проверки onboarding
final splashInitProvider = FutureProvider<bool>((ref) async {
  // Проверяем, пройден ли onboarding
  final storage = onboarding_storage.OnboardingStorage();
  final onboardingDone = await storage.isDone();

  // Обновляем состояние в ди через update метод
  final notifier = ref.read(onboardingDoneProvider.notifier);
  notifier.updateState(onboardingDone);

  // Проверяем авторизацию
  await ref.read(authStateProvider.notifier).checkAuth();

  return onboardingDone;
});

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Используем FutureBuilder для отслеживания завершения инициализации
    return ref.watch(splashInitProvider).when(
      data: (_) {
        // Инициализация завершена - роутер сам обработает редирект
        // Показываем пустой экран на время редиректа
        return const Scaffold(body: SizedBox.shrink());
      },
      loading: () => Scaffold(
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
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
      ),
      error: (error, stack) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Ошибка загрузки: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(splashInitProvider),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
