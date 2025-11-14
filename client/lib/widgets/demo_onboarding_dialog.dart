import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../screens/profile_screen.dart';

class DemoOnboardingDialog extends StatefulWidget {
  const DemoOnboardingDialog({Key? key}) : super(key: key);

  @override
  State<DemoOnboardingDialog> createState() => _DemoOnboardingDialogState();

  static Future<void> showEveryTime(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const DemoOnboardingDialog(),
      );
    }
  }
}

class _DemoOnboardingDialogState extends State<DemoOnboardingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;

  final List<_OnboardingStep> _steps = [
    _OnboardingStep(
      icon: Icons.waving_hand,
      title: 'Добро пожаловать!',
      description:
          'OutfitStyle поможет вам подобрать идеальный комплект одежды на основе погоды',
      gradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
    ),
    _OnboardingStep(
      icon: Icons.psychology,
      title: 'AI Персонализация',
      description:
          'Наш умный алгоритм учитывает ваши предпочтения и обучается на ваших оценках',
      gradient: const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
      ),
    ),
    _OnboardingStep(
      icon: Icons.settings,
      title: 'Настройте профиль',
      description:
          'Укажите ваш стиль, чувствительность к температуре и другие предпочтения для точных рекомендаций',
      gradient: const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
      setState(() {
        _currentStep++;
      });
      _controller.forward(from: 0);
    } else {
      _finish();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _controller.forward(from: 0);
    }
  }

  void _finish() {
    if (mounted) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  void _skip() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final currentStep = _steps[_currentStep];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: currentStep.gradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Step indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_steps.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == _currentStep ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == _currentStep
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 32),

                      // Icon
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                currentStep.icon,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Content
                SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Text(
                          currentStep.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textPrimary : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          currentStep.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppTheme.textSecondary
                                : Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Buttons
                        Row(
                          children: [
                            // Skip/Back button
                            if (_currentStep == 0)
                              TextButton(
                                onPressed: _skip,
                                child: Text(
                                  'Пропустить',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppTheme.textSecondary
                                        : Colors.grey[600],
                                  ),
                                ),
                              )
                            else
                              TextButton.icon(
                                onPressed: _previousStep,
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Назад'),
                              ),

                            const Spacer(),

                            // Next/Finish button
                            ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                                      fontSize: 16,
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

class _OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;

  _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}