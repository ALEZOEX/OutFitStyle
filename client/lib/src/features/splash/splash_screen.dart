import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../onboarding/onboarding_storage.dart' as onboarding_storage;
import '../../presentation/providers/session_provider.dart'
    show sessionManagerProvider;
import '../../theme/app_theme.dart';

/// Провайдер для отслеживания состояния проверки onboarding
final splashInitProvider = FutureProvider<String>((ref) async {
  final storage = onboarding_storage.OnboardingStorage();
  final onboardingDone = await storage.isDone();

  final sessionManager = ref.read(sessionManagerProvider);
  final isAuthenticated = sessionManager.isAuthenticated;

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
    ref.watch(splashInitProvider).whenData((route) {
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
              // Градиентный логотип
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'OS',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'OutFitStyle',
                style: AppTypography.headlineMedium(
                  context,
                ).copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.huge),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Загрузка...', style: AppTypography.bodyMedium(context)),
            ],
          ),
        ),
      ),
    );
  }
}
