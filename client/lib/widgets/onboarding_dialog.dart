import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../screens/profile_screen.dart';
import '../utils/dialog_state_manager.dart';

class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({super.key});

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();

  static bool _isShowing = false;

  /// Показывает онбординг один раз, если он ещё не был показан.
  static Future<void> showIfNeeded(BuildContext context) async {
    if (_isShowing) return; // уже показываем

    _isShowing = true;
    try {
      bool alreadyShown = false;
      try {
        alreadyShown = await DialogStateManager.isOnboardingShown();
      } catch (_) {
        alreadyShown = false;
      }

      if (alreadyShown || !context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => const OnboardingDialog(),
      );

      if (!context.mounted) return;

      try {
        await DialogStateManager.setOnboardingShown(true);
      } catch (_) {
        // не критично
      }
    } finally {
      _isShowing = false;
    }
  }
}

class _OnboardingDialogState extends State<OnboardingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  int _currentStep = 0;

  final List<_OnboardingStep> _steps = const [
    _OnboardingStep(
      icon: Icons.waving_hand,
      title: 'Добро пожаловать в OutfitStyle',
      description:
      'Приложение подберёт удобные образы с учётом погоды и ваших предпочтений.',
      gradient: LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
    ),
    _OnboardingStep(
      icon: Icons.psychology,
      title: 'Персональные рекомендации ИИ',
      description:
      'Алгоритм анализирует погоду, ваш стиль и оценки образов, чтобы предлагать всё точнее.',
      gradient: LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
      ),
    ),
    _OnboardingStep(
      icon: Icons.settings,
      title: 'Настройте профиль',
      description:
      'Укажите свой стиль и чувствительность к температуре, чтобы получать максимально точные подсказки.',
      gradient: LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _controller.forward(from: 0);
    } else {
      _finish();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _controller.forward(from: 0);
    }
  }

  void _finish() {
    if (!mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.pop(); // закрываем диалог
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _skip() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentStep = _steps[_currentStep];

    final titleStyle = textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: isDark ? AppTheme.textPrimary : Colors.black87,
    );
    final bodyStyle = textTheme.bodyMedium?.copyWith(
      color: isDark ? AppTheme.textSecondary : Colors.grey[700],
      height: 1.5,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(
                  stepCount: _steps.length,
                  currentStep: _currentStep,
                  step: currentStep,
                ),
                SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(28, 24, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          currentStep.title,
                          style: titleStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentStep.description,
                          style: bodyStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            if (_currentStep == 0)
                              TextButton(
                                onPressed: _skip,
                                child: Text(
                                  'Пропустить',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppTheme.textSecondary
                                        : Colors.grey[600],
                                  ),
                                ),
                              )
                            else
                              TextButton.icon(
                                onPressed: _previousStep,
                                icon: const Icon(Icons.arrow_back, size: 18),
                                label: const Text('Назад'),
                              ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentStep == _steps.length - 1
                                        ? 'Начать'
                                        : 'Далее',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _currentStep == _steps.length - 1
                                        ? Icons.check
                                        : Icons.arrow_forward,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.stepCount,
    required this.currentStep,
    required this.step,
  });

  final int stepCount;
  final int currentStep;
  final _OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: step.gradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(stepCount, (index) {
              final isActive = index == currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin:
                const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isActive ? 1 : 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.icon,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;

  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}